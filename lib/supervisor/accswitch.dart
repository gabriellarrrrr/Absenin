import 'package:absenin/anim/FadeUp.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccSwitch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccSwitchState();
  }
}

class SwitchItem {
  final DateTime dateFrom, dateTo, checked;
  final String id,
      idFrom,
      idTo,
      shiftFrom,
      shiftTo,
      nameFrom,
      nameTo,
      posFrom,
      posTo,
      photoFrom,
      photoTo;
  int status, typeFrom, typeTo;
  bool acc, reject, toDayOff;

  SwitchItem(
      this.id,
      this.dateFrom,
      this.dateTo,
      this.idFrom,
      this.idTo,
      this.shiftFrom,
      this.shiftTo,
      this.nameFrom,
      this.nameTo,
      this.posFrom,
      this.posTo,
      this.photoFrom,
      this.photoTo,
      this.typeFrom,
      this.typeTo,
      this.status,
      this.checked,
      this.acc,
      this.reject,
      this.toDayOff);
}

class AccSwitchState extends State<AccSwitch>
    with AutomaticKeepAliveClientMixin {
  List<SwitchItem> listSwitch = new List<SwitchItem>();
  final Firestore db = Firestore.instance;
  bool _load = false;
  bool isEmptyy = false;
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateFormat timeFormat = DateFormat.Hm();
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
      getListSwitch();
    });
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
                              setState(() {
                                listSwitch[index].acc = true;
                              });
                            } else {
                              statusUpdate(id, 2, index);
                              setState(() {
                                listSwitch[index].reject = true;
                              });
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

  void statusUpdate(String id, int value, int index) async {
    try {
      await db
          .collection('switchschedule')
          .document(outlet)
          .collection('listswitch')
          .document(id)
          .updateData({'status': value, 'checked': DateTime.now()});
      if (mounted) {
        checkSchedule(
            listSwitch[index].idFrom,
            listSwitch[index].idTo,
            listSwitch[index].dateFrom,
            listSwitch[index].dateTo,
            listSwitch[index].shiftFrom,
            listSwitch[index].shiftTo,
            listSwitch[index].typeFrom,
            listSwitch[index].typeTo,
            listSwitch[index].posFrom,
            listSwitch[index].posTo,
            value,
            listSwitch[index].toDayOff,);
        listSwitch.clear();
        getListSwitch();
      }
    } catch (e) {
      print(e);
    }
  }

  void checkSchedule(
    String idFrom,
    String idTo,
    DateTime dateFrom,
    DateTime dateTo,
    String shiftFrom,
    String shiftTo,
    int typeFrom,
    int typeTo,
    String posFrom,
    String posTo,
    int value,
    bool toDayOff,
  ) async {
    if(toDayOff && value == 1){
      await db
        .collection('schedule')
        .document(outlet)
        .collection('scheduledetail')
        .document('${dateFrom.year}')
        .collection('${dateFrom.month}')
        .document(shiftFrom)
        .collection('listday')
        .document('${dateFrom.day}')
        .collection('liststaff')
        .document(idTo)
        .setData({
          'pos': posFrom,
          'type': typeTo,
          'clockin': DateTime.now(),
          'clockout': DateTime.now(),
          'break': DateTime.now(),
          'afterbreak': DateTime.now(),
          'overtimein': DateTime.now(),
          'overtimeout': DateTime.now(),
          'late': 0,
          'isClockIn': false,
          'isBreak': false,
          'isAfterBreak': false,
          'isClockOut': false,
          'isOvertime': false,
          'isOvertimeIn': false,
          'isOvertimeOut': false,
          'permit': false,
          'switch': false,
          'switchAcc': 0,
          'switchDate': DateTime.now(),
          'otherTime': false
      }).then((value) async {
        await db
          .collection('schedule')
          .document(outlet)
          .collection('scheduledetail')
          .document('${dateFrom.year}')
          .collection('${dateFrom.month}')
          .document(shiftFrom)
          .collection('listday')
          .document('${dateFrom.day}')
          .collection('liststaff')
          .document(idFrom).delete();
      });
    } else {
      await db
          .collection('schedule')
          .document(outlet)
          .collection('scheduledetail')
          .document('${dateFrom.year}')
          .collection('${dateFrom.month}')
          .document(shiftFrom)
          .collection('listday')
          .document('${dateFrom.day}')
          .collection('liststaff')
          .document(idFrom)
          .updateData({'switchAcc': value, 'switchDate': dateTo});
      if (mounted) {
        if (value == 1) {
          await db
              .collection('schedule')
              .document(outlet)
              .collection('scheduledetail')
              .document('${dateFrom.year}')
              .collection('${dateFrom.month}')
              .document(shiftFrom)
              .collection('listday')
              .document('${dateFrom.day}')
              .collection('liststaff')
              .document(idTo)
              .setData({
            'pos': posFrom,
            'type': typeTo,
            'clockin': DateTime.now(),
            'clockout': DateTime.now(),
            'break': DateTime.now(),
            'afterbreak': DateTime.now(),
            'overtimein': DateTime.now(),
            'overtimeout': DateTime.now(),
            'late': 0,
            'isClockIn': false,
            'isBreak': false,
            'isAfterBreak': false,
            'isClockOut': false,
            'isOvertime': false,
            'isOvertimeIn': false,
            'isOvertimeOut': false,
            'permit': false,
            'switch': false,
            'switchAcc': 0,
            'switchDate': DateTime.now(),
            'otherTime': false
          });
          if (mounted) {
            await db
                .collection('schedule')
                .document(outlet)
                .collection('scheduledetail')
                .document('${dateTo.year}')
                .collection('${dateTo.month}')
                .document(shiftTo)
                .collection('listday')
                .document('${dateTo.day}')
                .collection('liststaff')
                .document(idTo)
                .updateData(
                    {'switch': true, 'switchAcc': value, 'switchDate': dateFrom});
            await db
                .collection('schedule')
                .document(outlet)
                .collection('scheduledetail')
                .document('${dateTo.year}')
                .collection('${dateTo.month}')
                .document(shiftTo)
                .collection('listday')
                .document('${dateTo.day}')
                .collection('liststaff')
                .document(idFrom)
                .setData({
              'pos': posTo,
              'type': typeFrom,
              'clockin': DateTime.now(),
              'clockout': DateTime.now(),
              'break': DateTime.now(),
              'afterbreak': DateTime.now(),
              'overtimein': DateTime.now(),
              'overtimeout': DateTime.now(),
              'late': 0,
              'isClockIn': false,
              'isBreak': false,
              'isAfterBreak': false,
              'isClockOut': false,
              'isOvertime': false,
              'isOvertimeIn': false,
              'isOvertimeOut': false,
              'permit': false,
              'switch': false,
              'switchAcc': 0,
              'switchDate': DateTime.now(),
              'otherTime': false
            });
          }
        }
      }
    }
  }

  void getListSwitch() async {
    db
        .collection('switchschedule')
        .document(outlet)
        .collection('listswitch')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      if (snapshot.documents.isEmpty) {
        setState(() {
          isEmptyy = true;
        });
      } else {
        snapshot.documents.forEach((f) async {
          if (f.data['toAcc']) {
            Timestamp dateFrom = f.data['datefrom'];
            Timestamp dateTo = f.data['dateto'];
            Timestamp checked = f.data['checked'];
            String nameTo = '';
            String photoTo = '';
            String nameFrom = '';
            String photoFrom = '';
            int typeFrom = 0;
            int typeTo = 0;
            await db
                .collection('user')
                .document(outlet)
                .collection('listuser')
                .document(f.data['from'])
                .get()
                .then((DocumentSnapshot snapshot) {
              nameFrom = snapshot.data['name'];
              photoFrom = snapshot.data['img'];
              typeFrom = snapshot.data['type'];
            });
            if (mounted) {
              await db
                  .collection('user')
                  .document(outlet)
                  .collection('listuser')
                  .document(f.data['to'])
                  .get()
                  .then((DocumentSnapshot snapshot) {
                nameTo = snapshot.data['name'];
                photoTo = snapshot.data['img'];
                typeTo = snapshot.data['type'];
              });
              if (mounted) {
                SwitchItem item = new SwitchItem(
                  f.documentID,
                  dateFrom.toDate(),
                  dateTo.toDate(),
                  f.data['from'],
                  f.data['to'],
                  f.data['shiftfrom'],
                  f.data['shiftto'],
                  nameFrom,
                  nameTo,
                  f.data['posFrom'],
                  f.data['posTo'],
                  photoFrom,
                  photoTo,
                  typeFrom,
                  typeTo,
                  f.data['status'],
                  checked.toDate(),
                  false,
                  false,
                  f.data['toDayOff']
                );
                setState(() {
                  listSwitch.add(item);
                  _load = true;
                });
              }
            }
          } else {
            if (snapshot.documents.length == 1) {
              setState(() {
                isEmptyy = true;
              });
            }
          }
        });
      }
    });
    print(listSwitch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _load
            ? Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'All switch request',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.caption.color,
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                        itemCount: listSwitch.length,
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
                                        'Switch on : ' +
                                            dateFormat.format(
                                                listSwitch[index].dateFrom),
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
                                            listSwitch[index].shiftFrom,
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
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              ClipOval(
                                                  child: CachedNetworkImage(
                                                imageUrl:
                                                    listSwitch[index].photoFrom,
                                                height: 50.0,
                                                width: 50.0,
                                                fit: BoxFit.cover,
                                              )
                                                  //         FadeInImage.assetNetwork(
                                                  //   placeholder:
                                                  //       'assets/images/absenin.png',
                                                  //   height: 50.0,
                                                  //   width: 50.0,
                                                  //   image:
                                                  //       listSwitch[index].photoFrom,
                                                  //   fadeInDuration:
                                                  //       Duration(seconds: 1),
                                                  //   fit: BoxFit.cover,
                                                  // )
                                                  ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                child: Text(
                                                  listSwitch[index].nameFrom,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color,
                                                      fontFamily: 'Sans',
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              .fontSize),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(
                                                listSwitch[index].status == 0
                                                    ? 'Waiting'
                                                    : listSwitch[index]
                                                                .status ==
                                                            1
                                                        ? 'Accepted'
                                                        : 'Rejected',
                                                style: TextStyle(
                                                    color: listSwitch[index].status == 0
                                                        ? MediaQuery.of(context)
                                                                    .platformBrightness ==
                                                                Brightness.light
                                                            ? Colors.blue[800]
                                                            : Colors.blue[400]
                                                        : listSwitch[index].status == 2
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
                                                              color: listSwitch[index].status == 0
                                                                  ? MediaQuery.of(context).platformBrightness ==
                                                                          Brightness
                                                                              .light
                                                                      ? Colors.blue[
                                                                          300]
                                                                      : Colors
                                                                          .blue
                                                                          .withAlpha(
                                                                              100)
                                                                  : listSwitch[index].status == 2
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
                                          Column(
                                            children: <Widget>[
                                              ClipOval(
                                                  child: CachedNetworkImage(
                                                imageUrl:
                                                    listSwitch[index].photoTo,
                                                height: 50.0,
                                                width: 50.0,
                                                fit: BoxFit.cover,
                                              )
                                                  //         FadeInImage.assetNetwork(
                                                  //   placeholder:
                                                  //       'assets/images/absenin.png',
                                                  //   height: 50.0,
                                                  //   width: 50.0,
                                                  //   image:
                                                  //       listSwitch[index].photoTo,
                                                  //   fadeInDuration:
                                                  //       Duration(seconds: 1),
                                                  //   fit: BoxFit.cover,
                                                  // )
                                                  ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                child: Text(
                                                  listSwitch[index].nameTo,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color,
                                                      fontFamily: 'Sans',
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              .fontSize),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30.0,
                                      ),
                                      if (listSwitch[index].status == 0)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                _showAlertDialog(
                                                    1,
                                                    listSwitch[index].id,
                                                    index);
                                              },
                                              child: Row(
                                                children: <Widget>[
                                                  if (listSwitch[index].acc)
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
                                                    listSwitch[index].id,
                                                    index);
                                              },
                                              child: Row(
                                                children: <Widget>[
                                                  if (listSwitch[index].reject)
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
                                            'Checked: ${dateFormat.format(listSwitch[index].checked)} at ${timeFormat.format(listSwitch[index].checked)}',
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

  @override
  bool get wantKeepAlive => true;
}
