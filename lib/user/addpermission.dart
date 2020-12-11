import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class MakePermission extends StatefulWidget {
  final int action;
  final String id, type, start, end, explan;

  const MakePermission(
      {Key key,
      @required this.action,
      @required this.id,
      @required this.type,
      @required this.start,
      @required this.end,
      @required this.explan})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PermissionState();
  }
}

class PermissionState extends State<MakePermission> {
  List permission = [
    'Cuti',
    'Sakit',
    'Izin',
  ];

  final explanController = TextEditingController();
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  String _fileName;
  File _file;
  String _path;
  Map<String, String> _paths;
  String _extension = 'pdf';
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.custom;
  String _type;
  int _status = 0;
  String _explanation;
  String _startdate = "Not set";
  String _enddate = "Not set";
  String urlFile;
  String pathFile;
  String id;
  String outlet, name;
  int cutiCount = 0;
  final Firestore firestore = Firestore.instance;
  final StorageReference fs = FirebaseStorage.instance.ref();

  @override
  void initState() {
    super.initState();
    getDataUserFromPref();
    if (widget.action == 20) {
      setState(() {
        _type = widget.type;
        _startdate = widget.start;
        _enddate = widget.end;
        explanController.text = widget.explan;
      });
    }
  }

  void getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('idUser');
      name = prefs.getString('namaUser');
      outlet = prefs.getString('outletUser');
      getJumlahCuti();
    });
  }

  void getJumlahCuti() async {
    await firestore.collection('user')
      .document(outlet)
      .collection('listuser')
      .document(id)
      .collection('${DateTime.now().year}')
      .document('count')
      .get()
      .then((snapshot){
        if(snapshot.exists){
          setState(() {
            cutiCount = snapshot.data['dayOff'];
          });
        }
      });
  }

  void savePermission() async {
    await firestore.collection('permission')
    .document(outlet)
    .collection('listpermission')
    .add({
      'type': _type,
      'startdate': _startdate,
      'enddate': _enddate,
      'status': _status,
      'submitted': DateTime.now(),
      'checked': DateTime.now(),
      'explanation': explanController.text,
      'file': urlFile,
      'filePath': pathFile,
      'user': id
    });
    if (mounted) {
      Navigator.pop(context);
      showCenterShortToast();
      Navigator.pop(context, true);
    }
    
  }

  void updatePermission() async {
    await firestore.collection('permission')
    .document(outlet)
    .collection('listpermission')
    .document(widget.id).updateData({
      'type': _type,
      'startdate': _startdate,
      'enddate': _enddate,
      'explanation': explanController.text
    });
    if (mounted) {
      Navigator.pop(context);
      showCenterShortToast();
      Navigator.pop(context, true);
    }
  }

  void _showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
            insetAnimationDuration: Duration(milliseconds: 500),
            insetAnimationCurve: Curves.bounceOut,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Wrap(
              children: <Widget>[
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 30.0, right: 20.0, bottom: 30.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Attention',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Google',
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .fontSize),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "You can't make day off permission again.",
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption.color,
                                fontFamily: 'Sans',
                                fontSize:
                                    Theme.of(context).textTheme.body1.fontSize),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 0.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(
                              fontFamily: 'Google',
                              fontWeight: FontWeight.bold,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.black54
                                      : Colors.grey[400]),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )));
  }

  // Future<File> compressImage(File file) async {
  //   final dir = await path_provider.getTemporaryDirectory();
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //     _image.absolute.path,
  //     dir.absolute.path + '/test.jpg',
  //     quality: 80,
  //   );
  //   print('before : ' + _image.lengthSync().toString());
  //   print('after : ' + result.lengthSync().toString());

  //   setState(() {
  //     _image = result;
  //   });
  // }

  _uploadImageToFirebase() async {
    StorageReference reference = fs.child(
        '$outlet/Permission/${dateFormat.format(DateTime.now())}/${name}_$_type');

    try {
      StorageUploadTask uploadTask = reference.putFile(_file);

      if (uploadTask.isInProgress) {
        uploadTask.events.listen((persen) async {
          double persentase = 100 *
              (persen.snapshot.bytesTransferred.toDouble() /
                  persen.snapshot.totalByteCount.toDouble());
          print(persentase);
        });

        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        final String url = await taskSnapshot.ref.getDownloadURL();
        final String path = await taskSnapshot.ref.getPath();

        setState(() {
          urlFile = url;
          pathFile = path;
          savePermission();
        });
      } else if (uploadTask.isComplete) {
        final String url = await reference.getDownloadURL();
        print(url);
        setState(() {
          urlFile = url;
          savePermission();
          Navigator.pop(context, true);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void showCenterShortToast() {
    Fluttertoast.showToast(
        msg: 'Success',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
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

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      if (_multiPick) {
        _path = null;
        _paths = await FilePicker.getMultiFilePath(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
      } else {
        _paths = null;
        _file = await FilePicker.getFile(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      if (_file != null) {
        _path = _file.path;
      }

      _loadingPath = false;
      _fileName = _path != null
          ? _path.split('/').last
          : _paths != null ? _paths.keys.toString() : '...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Add Permission'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Choose Permission',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .fontSize,
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            DropdownButtonFormField(
                              items: permission.map((permit) {
                                return DropdownMenuItem(
                                    value: permit,
                                    child: Container(
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            permit,
                                            style: TextStyle(
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .subhead
                                                    .fontSize,
                                                fontFamily: 'Sans'),
                                          ),
                                        ],
                                      ),
                                    ));
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _type = value);
                              },
                              value: _type,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(15, 5, 15, 5),
                                border: OutlineInputBorder(),
                                hintText: 'Permission',
                                hintStyle: TextStyle(
                                  fontFamily: 'Sans',
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Start Date :',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .fontSize,
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              height: 55.0,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(
                                        color:
                                            Theme.of(context).disabledColor)),
                                onPressed: () {
                                  DatePicker.showDatePicker(context,
                                      theme: DatePickerTheme(
                                        containerHeight: 250.0,
                                      ),
                                      showTitleActions: true,
                                      minTime: DateTime.now(),
                                      maxTime: DateTime(2025, 12, 31),
                                      onConfirm: (date) {
                                    print('confirm $date');
                                    _startdate =
                                        '${date.day}/${date.month}/${date.year}';
                                    setState(() {});
                                  },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.date_range,
                                          size: 18.0,
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.light
                                              ? Colors.indigo[400]
                                              : Colors.indigoAccent[100],
                                        ),
                                        SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          "$_startdate",
                                          style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .subhead
                                                  .fontSize,
                                              fontFamily: 'Sans'),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _startdate != "Not set" ? 'Change' : "",
                                      style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .body1
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color,
                                          fontFamily: 'Google'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'End Date :',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .fontSize,
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              height: 55.0,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(
                                        color:
                                            Theme.of(context).disabledColor)),
                                onPressed: () {
                                  DatePicker.showDatePicker(context,
                                      theme: DatePickerTheme(
                                        containerHeight: 250.0,
                                      ),
                                      showTitleActions: true,
                                      minTime: DateTime.now(),
                                      maxTime: DateTime(2025, 12, 31),
                                      onConfirm: (date) {
                                    print('confirm $date');
                                    _enddate =
                                        '${date.day}/${date.month}/${date.year}';
                                    setState(() {});
                                  },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.date_range,
                                          size: 18.0,
                                          color: MediaQuery.of(context)
                                                      .platformBrightness ==
                                                  Brightness.light
                                              ? Colors.indigo[400]
                                              : Colors.indigoAccent[100],
                                        ),
                                        SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          " $_enddate",
                                          style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .subhead
                                                  .fontSize,
                                              fontFamily: 'Sans'),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _enddate != "Not set" ? 'Change' : "",
                                      style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .body1
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color,
                                          fontFamily: 'Google'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Explanation',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .fontSize,
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Form(
                              child: TextFormField(
                                controller: explanController,
                                onSaved: (value) {
                                  _explanation = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter your explanation',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLength: 100,
                                maxLines: null,
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .subhead
                                        .fontSize,
                                    fontFamily: 'Sans'),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Choose File',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .fontSize,
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: <Widget>[
                                FlatButton(
                                  textColor: Colors.white,
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(5.0)),
                                  color: Colors.indigo,
                                  child: Text(
                                    _fileName != null
                                        ? 'Change file'
                                        : 'Drop File Here',
                                    style: TextStyle(
                                      fontFamily: 'Sans',
                                    ),
                                  ),
                                  onPressed: () {
                                    _openFileExplorer();
                                  },
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                  child: Text(
                                    _fileName != null ? _fileName : '',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                        fontFamily: 'Sans'),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 100,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      padding: EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: FlatButton(
                          onPressed: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            if (widget.action == 10) {
                              if(_type.toLowerCase() == 'cuti'){
                                if(cutiCount<9){
                                  _prosesDialog();
                                  _uploadImageToFirebase();
                                } else {
                                  _showAlertDialog();
                                }
                              } else {
                                _prosesDialog();
                                _uploadImageToFirebase();
                              }
                            } else {
                              _prosesDialog();
                              updatePermission();
                            }
                          },
                          child: Text(
                            widget.action == 20 ? 'Update' : 'Submit',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold),
                          ),
                          color: Theme.of(context).buttonColor,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}
