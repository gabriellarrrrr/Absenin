import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class MapPage extends StatefulWidget {
  final int action;
  final String id, name, outlet, img, shift;
  final DateTime timeSet;

  const MapPage(
      {Key key,
      @required this.action,
      @required this.id,
      @required this.name,
      @required this.outlet,
      @required this.img,
      @required this.shift,
      @required this.timeSet})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapState();
  }
}

class MapState extends State<MapPage> {
  final PanelController _panelController = new PanelController();

  loc.PermissionStatus _permissionGranted;
  loc.Location location = new loc.Location();
  bool androidFusedLocation = false;

  GoogleMapController mapController;
  StreamSubscription<Position> _positionStreamSubscription;
  final List<Position> _positions = <Position>[];
  LatLng _userPosition = LatLng(-7.748832, 110.354541);
  LatLng _dazzleOutlet = LatLng(-7.763148, 110.393545);
  String _userAddress = '';
  String _officeAddress = '';
  double _distace = 0;
  bool _status = false;
  double zoomSize = 20.0;
  Set<Marker> markers = Set();
  double _radiusPanel = 20.0;
  double _initFabHeight = 140.0;
  double _fabHeight;
  String _normalMapStyle;
  String _nightMapStyle;
  String urlImg;
  String outlet;
  File _userImage;
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateTime dt = DateTime.now();
  DateFormat year = DateFormat.y();
  DateFormat month = DateFormat.M();
  DateFormat day = DateFormat.d();

  final Firestore db = Firestore.instance;
  final StorageReference fs = FirebaseStorage.instance.ref();

  @override
  void initState() {
    super.initState();
    getOutlets();
    _fabHeight = _initFabHeight;
    rootBundle.loadString('assets/styles/normal_style_maps.txt').then((string) {
      _normalMapStyle = string;
    });
    rootBundle.loadString('assets/styles/night_style_maps.txt').then((string) {
      _nightMapStyle = string;
    });
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }
    super.dispose();
  }

  void getOutlets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dazzleOutlet = LatLng(prefs.getDouble('latitude'), prefs.getDouble('longtitude'));
      outlet = prefs.getString('outletUser');
    });
  }

  void _clockIn(int diffrence) async {
    if (widget.action == 10) {
      await db
          .collection('schedule')
          .document(outlet)
          .collection('scheduledetail')
          .document(year.format(dt))
          .collection(month.format(dt))
          .document(widget.shift)
          .collection('listday')
          .document(day.format(dt))
          .collection('liststaff')
          .document(widget.id)
          .updateData({
        'clockin': DateTime.now(),
        'late': diffrence,
        'isClockIn': true,
      });
      if(mounted){
        await db.collection('history')
          .document(outlet)
          .collection('listhistory')
          .document('${DateTime.now().year}')
          .collection(widget.id)
          .document('${DateTime.now().month}')
          .get()
          .then((snapshot){
            if(snapshot.exists){
              if(snapshot.data['attend'] != null){
                db.collection('history')
                  .document(outlet)
                  .collection('listhistory')
                  .document('${DateTime.now().year}')
                  .collection(widget.id)
                  .document('${DateTime.now().month}')
                  .updateData({
                    'attend' : snapshot.data['attend'] + 1
                  });
              } else {
                db.collection('history')
                  .document(outlet)
                  .collection('listhistory')
                  .document('${DateTime.now().year}')
                  .collection(widget.id)
                  .document('${DateTime.now().month}')
                  .setData({
                    'attend' : 1
                  }, merge: true);
              }
            } else {
              db.collection('history')
                .document(outlet)
                .collection('listhistory')
                .document('${DateTime.now().year}')
                .collection(widget.id)
                .document('${DateTime.now().month}')
                .setData({
                  'attend' : 1
                }, merge: true);
            }
          });
      }
    } else if (widget.action == 20) {
      await db
          .collection('schedule')
          .document(outlet)
          .collection('scheduledetail')
          .document(year.format(dt))
          .collection(month.format(dt))
          .document(widget.shift)
          .collection('listday')
          .document(day.format(dt))
          .collection('liststaff')
          .document(widget.id)
          .updateData({
        'afterbreak': DateTime.now(),
        'isAfterBreak': true,
      });
    } else {
      await db
          .collection('schedule')
          .document(outlet)
          .collection('scheduledetail')
          .document(year.format(dt))
          .collection(month.format(dt))
          .document(widget.shift)
          .collection('listday')
          .document(day.format(dt))
          .collection('liststaff')
          .document(widget.id)
          .updateData({
        'overtimein': DateTime.now(),
        'isOvertimeIn': true,
      });
    }
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context, true);
    }
  }

  _compressImage(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    var name = path.basename(_userImage.absolute.path);
    var result = await FlutterImageCompress.compressAndGetFile(
      _userImage.absolute.path,
      dir.absolute.path + '/$name',
      quality: 60,
    );
    print('before : ' + _userImage.lengthSync().toString());
    print('after : ' + result.lengthSync().toString());

    setState(() {
      _userImage = result;
    });
  }

  _uploadImageToFirebase() async {
    var diffrence = DateTime.now().difference(widget.timeSet).inMinutes;
    if(diffrence < 0){
      diffrence = 0;
    }
    print('Selisih waktu: $diffrence');

    StorageReference reference = fs.child(
        '${widget.outlet}/clockIn/${dateFormat.format(dt)}/${widget.name}');

    try {
      StorageUploadTask uploadTask = reference.putFile(_userImage);

      if (uploadTask.isInProgress) {
        uploadTask.events.listen((persen) async {
          double persentase = 100 *
              (persen.snapshot.bytesTransferred.toDouble() /
                  persen.snapshot.totalByteCount.toDouble());
          print(persentase);
        });

        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        final String url = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          urlImg = url;
          _clockIn(diffrence);
        });
      } else if (uploadTask.isComplete) {
        final String url = await reference.getDownloadURL();
        print(url);
        setState(() {
          urlImg = url;
          _clockIn(diffrence);
          Navigator.pop(context, true);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _setMarker() async {
    final bitmapStore = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(12, 12), devicePixelRatio: 2.5),
      'assets/images/pin_store.png',
    );
    markers.add(
      Marker(
          markerId: MarkerId(widget.outlet),
          position: _dazzleOutlet,
          icon: bitmapStore,
          infoWindow: InfoWindow(title: widget.outlet)),
    );
  }

  Future<void> _checkPermissions() async {
    final loc.PermissionStatus permissionGrantedResult =
        await location.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
    if (_permissionGranted != loc.PermissionStatus.granted) {
      _requestPermission();
    } else {
      _checkGps();
    }
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != loc.PermissionStatus.granted) {
      final loc.PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
      if (permissionRequestedResult != loc.PermissionStatus.granted) {
        return;
      } else {
        _checkGps();
      }
    }
  }

  Future _checkGps() async {
    var _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        _checkGps();
      } else {
        _initCurrentLocation();
      }
    } else {
      _initCurrentLocation();
    }
  }

  _initCurrentLocation() {
    Geolocator()
      ..forceAndroidLocationManager = androidFusedLocation
      ..getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).then((position) async {
        if (mounted) {
          LatLng newPosition = LatLng(position.latitude, position.longitude);
          final bitmapUser = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(12, 12), devicePixelRatio: 2.5),
            'assets/images/pin_user.png',
          );
          setState(() {
            _userPosition = newPosition;
            markers.add(Marker(
                markerId: MarkerId('User Position'),
                position: _userPosition,
                icon: bitmapUser,
                infoWindow: InfoWindow(title: 'User Position')));
          });
          mapController
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: _userPosition,
            zoom: 18.0,
          )));
          _getAddress(position, 10);
          _calculateLocation(_dazzleOutlet, _userPosition);
          _locationListening();
        }
      }).catchError((e) {
        //
      });
  }

  Future<void> _getAddress(Position _position, int action) async {
    String address = 'unknown';
    final List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(_position.latitude, _position.longitude);

    if (placemarks != null && placemarks.isNotEmpty) {
      address = _buildAddressString(placemarks.first);
    }

    setState(() {
      if (action == 10) {
        _userAddress = '$address';
      } else {
        _officeAddress = '$address';
      }
    });
  }

  static String _buildAddressString(Placemark placemark) {
    final String name = placemark.name ?? '';
    final String city = placemark.locality ?? '';
    final String state = placemark.administrativeArea ?? '';
    final String country = placemark.country ?? '';
    final Position position = placemark.position;

    return '$name, $city, $state, $country';
  }

  Future<void> _calculateLocation(
      LatLng startPosition, LatLng endPosition) async {
    var status = false;
    var distance = await Geolocator().distanceBetween(startPosition.latitude,
        startPosition.longitude, endPosition.latitude, endPosition.longitude);
    if (distance < 100) {
      status = true;
    }
    distance = distance / 1000;
    setState(() {
      _distace = distance;
      _status = status;
    });
  }

  _locationListening() {
    if (_positionStreamSubscription == null) {
      const LocationOptions locationOptions =
          LocationOptions(accuracy: LocationAccuracy.best, timeInterval: 10000);
      final Stream<Position> positionStream =
          Geolocator().getPositionStream(locationOptions);
      _positionStreamSubscription =
          positionStream.listen((Position position) async {
        LatLng newPosition = LatLng(position.latitude, position.longitude);
        final bitmapUser = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(12, 12), devicePixelRatio: 2.5),
          'assets/images/pin_user.png',
        );
        setState(() {
          _positions.add(position);
          _userPosition = newPosition;
          markers.add(Marker(
              markerId: MarkerId('User Position'),
              position: _userPosition,
              icon: bitmapUser,
              infoWindow: InfoWindow(title: 'User Position')));
        });
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: _userPosition,
          zoom: 17.0,
        )));
        _getAddress(position, 10);
        _calculateLocation(_dazzleOutlet, _userPosition);
      });
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
      }
    });
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    
    if (image != null) {
      setState(() {
        _userImage = image;
        _compressImage(_userImage);
        Timer(Duration(milliseconds: 300), () {
          _panelController.open();
        });
      });
    }
  }

  _prosesDialog() {
    showDialog(
        context: context,
        builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                alignment: FractionalOffset.centerLeft,
                width: 190.0,
                height: 60.0,
                margin: EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Please a wait...",
                        style: TextStyle(fontFamily: 'Sans', fontSize: 15.0),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    if (mapController != null) {
      if (isDark) {
        mapController.setMapStyle(_nightMapStyle);
      } else {
        mapController.setMapStyle(_normalMapStyle);
      }
    }

    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.action == 10
                  ? 'Clock In'
                  : widget.action == 20 ? 'After Break' : 'Overtime In'),
            ),
            body: Stack(
              children: <Widget>[
                SlidingUpPanel(
                  minHeight: 120.0,
                  maxHeight: MediaQuery.of(context).size.height,
                  backdropEnabled: true,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(_radiusPanel)),
                  parallaxEnabled: true,
                  parallaxOffset: 0.5,
                  color: Theme.of(context).backgroundColor,
                  isDraggable: true,
                  controller: _panelController,
                  onPanelSlide: (double pos) {
                    setState(() {
                      _fabHeight =
                          pos * (MediaQuery.of(context).size.height - 120.0) +
                              _initFabHeight;
                    });
                  },
                  onPanelClosed: () {
                    setState(() {
                      _radiusPanel = 20.0;
                    });
                  },
                  onPanelOpened: () {
                    setState(() {
                      _radiusPanel = 0.0;
                    });
                  },
                  panelBuilder: (scrollController) {
                    return MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView(
                          controller: scrollController,
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).dividerColor,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(2.0)),
                                width: 40.0,
                                height: 4.0,
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            ListTile(
                              leading: ClipOval(
                                  child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/absenin.png',
                                height: 50.0,
                                width: 50.0,
                                image: widget.img,
                                fadeInDuration: Duration(seconds: 1),
                                fit: BoxFit.cover,
                              )),
                              title: Text(
                                widget.name,
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .subhead
                                      .fontSize,
                                  fontFamily: 'Google',
                                ),
                              ),
                              subtitle: Text(
                                widget.outlet,
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                ),
                              ),
                              trailing: widget.action == 10
                                  ? ClipOval(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: IconButton(
                                            icon: Icon(
                                              FontAwesome.camera,
                                              size: 20.0,
                                              color: Theme.of(context)
                                                  .disabledColor,
                                            ),
                                            onPressed: getImage),
                                      ),
                                    )
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 40.0,
                                  bottom: 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Today, 04 Mei 2020',
                                            style: TextStyle(
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .fontSize,
                                                fontFamily: 'Sans',
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .color),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Text(
                                            '06:55 AM',
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .title
                                                  .fontSize,
                                              fontFamily: 'Sans',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _status
                                            ? widget.action == 10
                                                ? 'Your clock in process\nwas accepted'
                                                : widget.action == 20
                                                    ? 'Your after break process\nwas accepted'
                                                    : 'Your overtime in process\nwas accepted'
                                            : widget.action == 10
                                                ? 'Your clock in process\nwas rejected!'
                                                : widget.action == 20
                                                    ? 'Your after break process\nwas rejected!'
                                                    : 'Your overtime in process\nwas rejected!',
                                        style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .body1
                                              .fontSize,
                                          fontFamily: 'Sans',
                                          color: _status
                                              ? MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.light
                                                  ? Colors.green[800]
                                                  : Colors.green[200]
                                              : MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.light
                                                  ? Colors.red[800]
                                                  : Colors.red[300],
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  if (widget.action == 10)
                                    Column(
                                      children: <Widget>[
                                        Divider(
                                          height: 0.0,
                                        ),
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Photo',
                                            style: TextStyle(
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .subhead
                                                    .fontSize,
                                                fontFamily: 'Google',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: _userImage != null
                                                ? Image.file(
                                                    _userImage,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: 170.0,
                                                    filterQuality:
                                                        FilterQuality.medium,
                                                  )
                                                : Container(
                                                    height: 170.0,
                                                    color: Theme.of(context)
                                                        .dividerColor,
                                                    child: Center(
                                                      child: Text(
                                                        'Take a photo for attendance',
                                                        style: TextStyle(
                                                            fontSize: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .subhead
                                                                .fontSize,
                                                            fontFamily: 'Sans',
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption
                                                                .color),
                                                      ),
                                                    ),
                                                  )),
                                      ],
                                    ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Distance',
                                      style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .fontSize,
                                          fontFamily: 'Google',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Container(
                                    // margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                                    padding: EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Theme.of(context).dividerColor),
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Current Address:',
                                          style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .body1
                                                .fontSize,
                                            fontFamily: 'Google',
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Image.asset(
                                              'assets/images/pin_user.png',
                                              width: 30.0,
                                            ),
                                            SizedBox(
                                              width: 15.0,
                                            ),
                                            Flexible(
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    _userAddress,
                                                    style: TextStyle(
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .body2
                                                              .fontSize,
                                                      fontFamily: 'Sans',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Icon(MaterialIcons.keyboard_arrow_up),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        bottom: 10.0,
                                        top: 10.0),
                                    decoration: BoxDecoration(
                                      // color: !_status ? MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[100] : Colors.green[300] : MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.red[100] : Colors.red[300],
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    child: Text(
                                      '${_distace.toStringAsFixed(2)} Km',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Icon(MaterialIcons.keyboard_arrow_down),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Container(
                                    // margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                                    padding: EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Theme.of(context).dividerColor),
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Office Address:',
                                          style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .body1
                                                .fontSize,
                                            fontFamily: 'Google',
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Image.asset(
                                              'assets/images/pin_store.png',
                                              width: 30.0,
                                            ),
                                            SizedBox(
                                              width: 15.0,
                                            ),
                                            Flexible(
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    '${widget.outlet} \n$_officeAddress',
                                                    style: TextStyle(
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .body2
                                                              .fontSize,
                                                      fontFamily: 'Sans',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50.0,
                                  ),
                                  Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 45.0,
                                        child: FlatButton(
                                          onPressed: widget.action == 10 &&
                                                  _userImage != null
                                              ? () {
                                                  _prosesDialog();
                                                  _uploadImageToFirebase();
                                                }
                                              : widget.action == 20 ||
                                                      widget.action == 30
                                                  ? () {
                                                      _prosesDialog();
                                                      _clockIn(0);
                                                    }
                                                  : null,
                                          // onPressed: () {
                                          //   Navigator.pop(context, true);
                                          // },
                                          child: Text(
                                            widget.action == 10
                                                ? 'Clock In'
                                                : widget.action == 20
                                                    ? 'After Break'
                                                    : 'Overtime In',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Google',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          color: Theme.of(context).buttonColor,
                                          disabledColor:
                                              Theme.of(context).disabledColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          splashColor: Colors.black26,
                                          highlightColor: Colors.black26,
                                        ),
                                      )),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      widget.action == 10 && _userImage != null
                                          ? 'Please check again the accuracy of your current location before completing the clock in process.'
                                          : widget.action == 20
                                              ? 'Please check again the accuracy of your current location before completing the after break process.'
                                              : widget.action == 30
                                                  ? 'Please check again the accuracy of your current location before completing the overtime in process.'
                                                  : 'Please take a picture',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                        fontFamily: 'Sans',
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ));
                  },
                  body: GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: _dazzleOutlet, zoom: zoomSize),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      setState(() {
                        _checkPermissions();
                        _setMarker();
                        _getAddress(
                            Position(
                                latitude: _dazzleOutlet.latitude,
                                longitude: _dazzleOutlet.longitude),
                            20);
                      });
                    },
                    mapType: MapType.normal,
                    markers: markers,
                  ),
                ),
                Positioned(
                  left: 10.0,
                  right: 16.0,
                  bottom: _fabHeight,
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                            left: 10.0, right: 20.0, bottom: 10.0, top: 10.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 8.0,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.light
                                      ? Colors.black12
                                      : Colors.transparent,
                                  offset: Offset(0.0, 3.0))
                            ]),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              MaterialIcons.track_changes,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.indigo[400]
                                      : Colors.indigo[200],
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '${_distace.toStringAsFixed(2)} Km',
                              style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: 10.0, right: 20.0, bottom: 10.0, top: 10.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 8.0,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.light
                                      ? Colors.black12
                                      : Colors.transparent,
                                  offset: Offset(0.0, 3.0))
                            ]),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              _status
                                  ? MaterialIcons.done
                                  : MaterialIcons.close,
                              color: _status
                                  ? MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.green[400]
                                      : Colors.green[200]
                                  : MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.red[400]
                                      : Colors.red[300],
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              _status ? 'Accepted' : 'Rejected',
                              style: TextStyle(
                                fontFamily: 'Sans',
                                fontWeight: FontWeight.bold,
                                color: _status
                                    ? MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.green[400]
                                        : Colors.green[200]
                                    : MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.red[400]
                                        : Colors.red[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      FloatingActionButton(
                        splashColor: Colors.black26,
                        child: Icon(
                          MaterialIcons.gps_fixed,
                          size: 24.0,
                          color: Theme.of(context).buttonColor,
                        ),
                        onPressed: () {
                          Geolocator()
                            ..forceAndroidLocationManager = androidFusedLocation
                            ..getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.best,
                            ).then((position) async {
                              if (mounted) {
                                final bitmapUser =
                                    await BitmapDescriptor.fromAssetImage(
                                  ImageConfiguration(
                                      size: Size(12, 12),
                                      devicePixelRatio: 2.5),
                                  'assets/images/pin_user.png',
                                );
                                LatLng newPosition = LatLng(
                                    position.latitude, position.longitude);
                                setState(() {
                                  _userPosition = newPosition;
                                  markers.add(Marker(
                                      markerId: MarkerId('User Position'),
                                      position: _userPosition,
                                      icon: bitmapUser,
                                      infoWindow:
                                          InfoWindow(title: 'User Position')));
                                });
                                mapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                  target: _userPosition,
                                  zoom: 18.0,
                                )));
                                _getAddress(position, 10);
                                _calculateLocation(
                                    _dazzleOutlet, _userPosition);
                                // _locationListening();
                              }
                            }).catchError((e) {
                              //
                            });
                        },
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            )),
        onWillPop: _onBackPressed);
  }

  Future<bool> _onBackPressed() {
    return _panelController.isPanelOpen
        ? _panelController.close()
        : Navigator.pop(context);
  }
}
