import 'package:absenin/anim/FadeUp.dart';
import 'package:absenin/supervisor/pdfview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccPermission extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccPermissionState();
  }
}

class AccPermissionItem {
  final String id, user, name, startdate, enddate, type, file, filePath;
  int status;
  bool acc, reject;
  DateTime submitted, checked;

  AccPermissionItem(
      this.id,
      this.user,
      this.name,
      this.startdate,
      this.enddate,
      this.type,
      this.status,
      this.acc,
      this.reject,
      this.submitted,
      this.checked,
      this.file,
      this.filePath);
}

class OprationalItem {
  String shift;
  DateTime startfull,
      endfull,
      startpart,
      endpart,
      startfull2,
      endfull2,
      startpart2,
      endpart2;

  OprationalItem(
      this.shift,
      this.startfull,
      this.endfull,
      this.startpart,
      this.endpart,
      this.startfull2,
      this.endfull2,
      this.startpart2,
      this.endpart2);
}

class AccPermissionState extends State<AccPermission>
    with AutomaticKeepAliveClientMixin {
  List<AccPermissionItem> listaccpermission = new List<AccPermissionItem>();
  List<OprationalItem> listJadwal = new List<OprationalItem>();
  final Firestore db = Firestore.instance;
  bool _load = false;
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateFormat timeFormat = DateFormat.Hm();
  DateTime dateTime;
  bool isEmptyy = false;
  String outlet;

  @override
  void initState() {
    super.initState();
    _getDataUserFromPref();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
      getListPermission();
    });
  }

  void getOprationalSchedule() async {
    db
        .collection('outlet')
        .where('name', isEqualTo: outlet)
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.isNotEmpty) {
        listJadwal.clear();
        snapshot.documents.forEach((k) {
          db
              .collection('outlet')
              .document(k.documentID)
              .collection('oprational')
              .getDocuments()
              .then((snapshot2) {
            if (snapshot2.documents.isNotEmpty) {
              snapshot2.documents.forEach((f) {
                Timestamp startfull = f.data['startfull'];
                Timestamp endfull = f.data['endfull'];
                Timestamp startpart = f.data['startpart'];
                Timestamp endpart = f.data['endpart'];
                Timestamp startfull2 = f.data['startfull2'];
                Timestamp endfull2 = f.data['endfull2'];
                Timestamp startpart2 = f.data['startpart2'];
                Timestamp endpart2 = f.data['endpart2'];
                OprationalItem item = new OprationalItem(
                    f.data['name'],
                    startfull.toDate(),
                    endfull.toDate(),
                    startpart.toDate(),
                    endpart.toDate(),
                    startfull2.toDate(),
                    endfull2.toDate(),
                    startpart2.toDate(),
                    endpart2.toDate());
                setState(() {
                  listJadwal.add(item);
                });
              });
            }
          });
        });
      }
    });
  }

  void statusUpdate(String id, int value, int index) async {
    dateTime = DateTime.now();
    try {
      await db
          .collection('permission')
          .document(outlet)
          .collection('listpermission')
          .document(id)
          .updateData({'status': value, 'checked': dateTime});
      if (mounted) {
        if (value == 1) {
          checkSchedule(
              listaccpermission[index].user,
              listaccpermission[index].startdate,
              listaccpermission[index].enddate,
              listaccpermission[index].name,
              listaccpermission[index].type);
          if (listaccpermission[index].type.toLowerCase() != 'cuti') {
            await db
                .collection('history')
                .document(outlet)
                .collection('listhistory')
                .document('${DateTime.now().year}')
                .collection(listaccpermission[index].user)
                .document('${DateTime.now().month}')
                .get()
                .then((snapshot) {
              if (snapshot.exists) {
                if (snapshot.data['permission'] != null) {
                  db
                      .collection('history')
                      .document(outlet)
                      .collection('listhistory')
                      .document('${DateTime.now().year}')
                      .collection(listaccpermission[index].user)
                      .document('${DateTime.now().month}')
                      .updateData(
                          {'permission': snapshot.data['permission'] + 1});
                } else {
                  db
                      .collection('history')
                      .document(outlet)
                      .collection('listhistory')
                      .document('${DateTime.now().year}')
                      .collection(listaccpermission[index].user)
                      .document('${DateTime.now().month}')
                      .setData({'permission': 1}, merge: true);
                }
              } else {
                db
                    .collection('history')
                    .document(outlet)
                    .collection('listhistory')
                    .document('${DateTime.now().year}')
                    .collection(listaccpermission[index].user)
                    .document('${DateTime.now().month}')
                    .setData({'permission': 1}, merge: true);
              }
            });
          } else {
            db
                .collection('user')
                .document(outlet)
                .collection('listuser')
                .document(listaccpermission[index].user)
                .collection('${DateTime.now().year}')
                .document('count')
                .get()
                .then((snapshot) {
              db
                  .collection('user')
                  .document(outlet)
                  .collection('listuser')
                  .document(listaccpermission[index].user)
                  .collection('${DateTime.now().year}')
                  .document('count')
                  .updateData({'dayOff': snapshot.data['dayOff'] + 1});
            });
          }
        }
        listaccpermission.clear();
        getListPermission();
      }
    } catch (e) {
      print(e);
    }
  }

  void checkSchedule(
      String id, String start, String end, String name, String type) async {
    var startTime = DateFormat('d/M/yyyy').parse(start);
    var endTime = DateFormat('d/M/yyyy').parse(end);
    var loop = (endTime.difference(startTime).inDays) + 1;
    for (int i = 0; i < listJadwal.length; i++) {
      for (int j = 0; j < loop; j++) {
        var dateTime = startTime.add(Duration(days: j));
        await db
            .collection('schedule')
            .document(outlet)
            .collection('scheduledetail')
            .document('${dateTime.year}')
            .collection('${dateTime.month}')
            .document('${listJadwal[i].shift}')
            .collection('listday')
            .document('${dateTime.day}')
            .collection('liststaff')
            .document(id)
            .get()
            .then((snapshot) async {
          if (snapshot.data != null) {
            print(
                'Tanggal ${dateTime.day}/${dateTime.month}, ${listJadwal[i].shift} ada jadwal cuy...');
            await db
                .collection('schedule')
                .document(outlet)
                .collection('scheduledetail')
                .document('${dateTime.year}')
                .collection('${dateTime.month}')
                .document('${listJadwal[i].shift}')
                .collection('listday')
                .document('${dateTime.day}')
                .collection('liststaff')
                .document(id)
                .updateData({'permit': true});
            if (mounted) {
              await db
                  .collection('report')
                  .document(outlet)
                  .collection('listreport')
                  .document('${dateTime.year}')
                  .collection('${dateTime.month}')
                  .document(id)
                  .collection('listreport')
                  .add({
                'id': id,
                'name': name,
                'shift': '-',
                'pos': '-',
                'dayin': type.toLowerCase() != 'cuti' ? 3 : 2,
                'dayintotaltime': 0,
                'totalbreaktime': 0,
                'overtimeday': 0,
                'overtimetotaltime': 0,
                'lateday': 0,
                'latetotaltime': 0,
                'date': dateTime,
                'clockin': dateTime,
                'break': dateTime,
                'afterbreak': dateTime,
                'clockout': dateTime,
                'overtimein': dateTime,
                'overtimeout': dateTime,
              });
            }
          } else {
            print(
                'Tanggal ${dateTime.day}/${dateTime.month}, ${listJadwal[i].shift} gak ada cuy...');
          }
        });
      }
    }
  }

  void getListPermission() async {
    db
        .collection('permission')
        .document(outlet)
        .collection('listpermission')
        .orderBy('submitted', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.documents.isEmpty) {
        setState(() {
          isEmptyy = true;
        });
      } else {
        snapshot.documents.forEach((f) async {
          Timestamp submitted = f.data['submitted'];
          Timestamp checked = f.data['checked'];
          String name = '';
          await db
              .collection('user')
              .document(outlet)
              .collection('listuser')
              .document(f.data['user'])
              .get()
              .then((DocumentSnapshot snapshot) {
            name = snapshot.data['name'];
          });
          if (mounted) {
            AccPermissionItem item = new AccPermissionItem(
                f.documentID,
                f.data['user'],
                name,
                f.data['startdate'],
                f.data['enddate'],
                f.data['type'],
                f.data['status'],
                false,
                false,
                submitted.toDate(),
                checked.toDate(),
                f.data['file'],
                f.data['filePath']);
            setState(() {
              listaccpermission.add(item);
              _load = true;
            });
          }
        });
      }
    });
    print(listaccpermission);
  }

  void _showAlertDialog(int action, String id, int index) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Wrap(
              children: <Widget>[
                Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 20, right: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          action == 1
                              ? 'Are You Sure Accepting?'
                              : 'Are You Sure Rejecting?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Google',
                              fontSize:
                                  Theme.of(context).textTheme.subhead.fontSize),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Image.asset(
                      action == 1
                          ? 'assets/images/acc.png'
                          : 'assets/images/reject.png',
                      height: 200,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(
                      height: 0.5,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (action == 1) {
                              statusUpdate(id, 1, index);
                            } else {
                              statusUpdate(id, 2, index);
                            }
                          },
                          child: Text(
                            'Yes',
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                    Divider(
                      height: 0.5,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'No',
                            style: TextStyle(
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold,
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.black54
                                        : Colors.grey[400]),
                          )),
                    )
                  ],
                ),
              ],
            )));
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
    return Scaffold(
      body: SingleChildScrollView(
        child: _load
            ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'All permissions request',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.caption.color,
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                        itemCount: listaccpermission.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return FadeUp(
                              0.5 + index / 2,
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: 15,
                                  top: 15,
                                ),
                                padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 20.0,
                                    bottom: 15.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).backgroundColor,
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(0, 3),
                                        blurRadius: 8,
                                      )
                                    ]),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        listaccpermission[index].name,
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .subhead
                                                .fontSize,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Google'),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Submitted: ${dateFormat.format(listaccpermission[index].submitted)} at ${timeFormat.format(listaccpermission[index].submitted)}',
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .fontSize,
                                              fontFamily: 'Sans',
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color,
                                            ),
                                          ),
                                          Text(
                                            listaccpermission[index].type,
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .body1
                                                  .fontSize,
                                              fontFamily: 'Google',
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            width: 100,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                // color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[50] : Colors.green.withAlpha(30),
                                                border: Border.all(
                                                  color: MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.light
                                                      ? Colors.green[100]
                                                      : Colors.green
                                                          .withAlpha(50),
                                                )),
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  'Start Date',
                                                  style: TextStyle(
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              .fontSize,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color,
                                                      fontFamily: 'Sans'),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  listaccpermission[index]
                                                      .startdate,
                                                  style: TextStyle(
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.light
                                                          ? Colors.green[900]
                                                          : Colors.white,
                                                      fontFamily: 'Google'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                listaccpermission[index]
                                                            .status ==
                                                        0
                                                    ? 'Waiting'
                                                    : listaccpermission[index]
                                                                .status ==
                                                            1
                                                        ? 'Accepted'
                                                        : 'Rejected',
                                                style: TextStyle(
                                                    color: listaccpermission[index].status == 0
                                                        ? MediaQuery.of(context)
                                                                    .platformBrightness ==
                                                                Brightness.light
                                                            ? Colors.blue[800]
                                                            : Colors.blue[400]
                                                        : listaccpermission[index].status == 2
                                                            ? MediaQuery.of(context).platformBrightness ==
                                                                    Brightness
                                                                        .light
                                                                ? Colors
                                                                    .red[800]
                                                                : Colors
                                                                    .red[400]
                                                            : MediaQuery.of(context).platformBrightness ==
                                                                    Brightness
                                                                        .light
                                                                ? Colors
                                                                    .green[800]
                                                                : Colors
                                                                    .green[400],
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .caption
                                                        .fontSize,
                                                    fontFamily: 'Sans'),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  for (int i = 0; i < 12; i++)
                                                    Row(
                                                      children: <Widget>[
                                                        Container(
                                                          width: 3.5,
                                                          height: 3.5,
                                                          decoration: BoxDecoration(
                                                              color: listaccpermission[index].status == 0
                                                                  ? MediaQuery.of(context).platformBrightness ==
                                                                          Brightness
                                                                              .light
                                                                      ? Colors.blue[
                                                                          300]
                                                                      : Colors
                                                                          .blue
                                                                          .withAlpha(
                                                                              100)
                                                                  : listaccpermission[index].status == 2
                                                                      ? MediaQuery.of(context).platformBrightness == Brightness.light
                                                                          ? Colors.red[
                                                                              300]
                                                                          : Colors.red.withAlpha(
                                                                              100)
                                                                      : MediaQuery.of(context).platformBrightness ==
                                                                              Brightness.light
                                                                          ? Colors.green[300]
                                                                          : Colors.green.withAlpha(100),
                                                              shape: BoxShape.circle),
                                                        ),
                                                        if (i < 19)
                                                          SizedBox(
                                                            width: 5.0,
                                                          ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(15),
                                            width: 100,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                // color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[50] : Colors.green.withAlpha(30),
                                                border: Border.all(
                                                  color: MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.light
                                                      ? Colors.green[100]
                                                      : Colors.green
                                                          .withAlpha(50),
                                                )),
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  'End Date',
                                                  style: TextStyle(
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              .fontSize,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color,
                                                      fontFamily: 'Sans'),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  listaccpermission[index]
                                                      .enddate,
                                                  style: TextStyle(
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.light
                                                          ? Colors.green[900]
                                                          : Colors.white,
                                                      fontFamily: 'Google'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30.0,
                                      ),
                                      if (listaccpermission[index].status == 0)
                                        Row(
                                          children: <Widget>[
                                            SizedBox(
                                              width: 80,
                                              child: FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      _createRoute(PdfViewer(
                                                          urlFile:
                                                              listaccpermission[
                                                                      index]
                                                                  .file)));
                                                },
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      FontAwesome.file_pdf_o,
                                                      size: 15,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      'View',
                                                      style: TextStyle(
                                                          fontFamily: 'Google',
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption
                                                                  .fontSize,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                color: MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.light
                                                    ? Colors.indigo[50]
                                                    : Colors.indigo[400]
                                                        .withAlpha(30),
                                                textColor: MediaQuery.of(
                                                                context)
                                                            .platformBrightness ==
                                                        Brightness.light
                                                    ? Colors.indigo
                                                    : Colors.indigo[300],
                                                splashColor: Colors.black26,
                                                highlightColor: Colors.black26,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                              ),
                                            ),
                                            Spacer(),
                                            FlatButton(
                                              onPressed: () {
                                                _showAlertDialog(
                                                    1,
                                                    listaccpermission[index].id,
                                                    index);
                                              },
                                              child: Row(
                                                children: <Widget>[
                                                  if (listaccpermission[index]
                                                      .acc)
                                                    SizedBox(
                                                        width: 15.0,
                                                        height: 15.0,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ))
                                                  else
                                                    Text(
                                                      'Accept',
                                                      style: TextStyle(
                                                          fontFamily: 'Google',
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption
                                                                  .fontSize,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                ],
                                              ),
                                              color: MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.light
                                                  ? Colors.blue[50]
                                                  : Colors.blue[400]
                                                      .withAlpha(30),
                                              textColor:
                                                  Theme.of(context).buttonColor,
                                              splashColor: Colors.black26,
                                              highlightColor: Colors.black26,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                            ),
                                            SizedBox(
                                              width: 20.0,
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                _showAlertDialog(
                                                    2,
                                                    listaccpermission[index].id,
                                                    index);
                                              },
                                              child: Row(
                                                children: <Widget>[
                                                  if (listaccpermission[index]
                                                      .reject)
                                                    SizedBox(
                                                        width: 15.0,
                                                        height: 15.0,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ))
                                                  else
                                                    Text(
                                                      'Reject',
                                                      style: TextStyle(
                                                          fontFamily: 'Google',
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption
                                                                  .fontSize,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                ],
                                              ),
                                              color: MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.light
                                                  ? Colors.red[50]
                                                  : Colors.red[300]
                                                      .withAlpha(30),
                                              textColor: MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.light
                                                  ? Colors.red[400]
                                                  : Colors.red[300],
                                              splashColor: Colors.black26,
                                              highlightColor: Colors.black26,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                            ),
                                          ],
                                        )
                                      else
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'Checked: ${dateFormat.format(listaccpermission[index].checked)} at ${timeFormat.format(listaccpermission[index].checked)}',
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .fontSize,
                                              fontFamily: 'Sans',
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color,
                                            ),
                                          ),
                                        ),
                                    ]),
                              ));
                        }),
                  ],
                ),
              )
            : isEmptyy
                ? Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.2),
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Image.asset(
                            'assets/images/nodata.png',
                            width: MediaQuery.of(context).size.width * 0.6,
                          ),
                        ),
                        SizedBox(
                          height: 18.0,
                        ),
                        Text(
                          'No data to display',
                          style: TextStyle(
                              fontFamily: 'Sans',
                              color: Theme.of(context).disabledColor,
                              fontSize:
                                  Theme.of(context).textTheme.title.fontSize),
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Padding(
                    padding: const EdgeInsets.only(top: 150.0, bottom: 30.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  )),
      ),
    );
  }

  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
