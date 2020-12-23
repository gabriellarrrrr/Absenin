import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:random_color/random_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleTime extends StatefulWidget {
  final int action;
  final String id;

  const ScheduleTime({Key key, @required this.action, this.id})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScheduleState();
  }
}

class OverviewSchedule {
  //untuk getter and setter -> class model schedule, objek
  final DateTime date, startTime, endTime, switchDate;
  String shift, pos;
  int lateTime, type;
  DateTime clockinTime,
      breakTime,
      afterbreakTime,
      clockoutTime,
      overtimeinTime,
      overtimeoutTime;
  bool isClockIn,
      isBreak,
      isAfterBreak,
      isClockOut,
      isOverTime,
      isOverTimeIn,
      isOverTimeOut,
      isOff,
      isPermit,
      isSwitch;
  int _active, isSwitchAcc;

  OverviewSchedule(
      this.date,
      this.startTime,
      this.endTime,
      this.shift,
      this.pos,
      this.lateTime,
      this.type,
      this.isClockIn,
      this.isBreak,
      this.isAfterBreak,
      this.isClockOut,
      this.isOverTime,
      this.isOverTimeIn,
      this.isOverTimeOut,
      this.isOff,
      this.isPermit,
      this.isSwitch,
      this.isSwitchAcc,
      this.switchDate,
      this._active,
      this.clockinTime,
      this.breakTime,
      this.afterbreakTime,
      this.clockoutTime,
      this.overtimeinTime,
      this.overtimeoutTime);
}

class TodayCheck {
  bool check;

  TodayCheck(this.check);
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

class ScheduleState extends State<ScheduleTime> {
  final Firestore firestore = Firestore.instance;
  DateTime dateTime = DateTime.now();
  String id, outlet, shift;
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateFormat timeFormat = DateFormat.Hm();
  bool isEmptyy = false;

  List<OverviewSchedule> listSchedule = new List<OverviewSchedule>();
  List<OverviewSchedule> listScheduleTemp = new List<OverviewSchedule>();
  List<TodayCheck> listToday = new List<TodayCheck>();
  List<OprationalItem> listJadwal = new List<OprationalItem>();
  List<Color> generatedColors = <Color>[];
  final List<ColorHue> _hueType = <ColorHue>[
    ColorHue.green,
    ColorHue.red,
    ColorHue.pink,
    ColorHue.purple,
    ColorHue.blue,
    ColorHue.yellow,
    ColorHue.orange
  ];
  ColorBrightness _colorLuminosity = ColorBrightness.random;
  ColorSaturation _colorSaturation = ColorSaturation.random;

  @override
  void initState() {
    super.initState();
    TodayCheck item = new TodayCheck(false);
    TodayCheck item1 = new TodayCheck(false);
    TodayCheck item2 = new TodayCheck(false);
    TodayCheck item3 = new TodayCheck(false);
    TodayCheck item4 = new TodayCheck(false);
    TodayCheck item5 = new TodayCheck(false);
    TodayCheck item6 = new TodayCheck(false);
    listToday.add(item);
    listToday.add(item1);
    listToday.add(item2);
    listToday.add(item3);
    listToday.add(item4);
    listToday.add(item5);
    listToday.add(item6);
    getDataUserFromPref();
  }

  void getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('idUser');
      outlet = prefs.getString('outletUser');
      getOprationalSchedule();
    });
  }

  void getOprationalSchedule() async {
    print('OUTLET => $outlet');
    await firestore
        .collection('outlet')
        .where('name', isEqualTo: outlet)
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.isNotEmpty) {
        listJadwal.clear();
        snapshot.documents.forEach((k) async {
          print('DOCUMENT ID => ${k.documentID}');
          await firestore
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
              if (listJadwal.length > 0) {
                print('DATA OPERATIONAL ADA => ${listJadwal.length}');
              } else {
                print('DATA OPERATIONAL TIDAK ADA');
              }
              _getListSchedule();
            }
          });
        });
      }
    });
  }

  _getListSchedule() async {
    for (int i = 0; i < 7; i++) {
      if(i != 0){
        dateTime = Jiffy(dateTime).add(days: 1);
      }
      for (int j = 0; j < listJadwal.length; j++) {
        print(
            'MENGAMBIL DATA TANGGAL ${dateTime.day} / ${listJadwal[j].shift}');
        if (!listToday[i].check) {
          await firestore
              .collection('schedule')
              .document(outlet)
              .collection('scheduledetail')
              .document('${dateTime.year}')
              .collection('${dateTime.month}')
              .document('${listJadwal[j].shift}')
              .collection('listday')
              .document('${dateTime.day}')
              .collection('liststaff')
              .document(id)
              .get()
              .then((snapshoot) async {
            if (snapshoot.exists) {
              Timestamp switchDate = snapshoot.data['switchDate'];
              Timestamp clockinTime = snapshoot.data['clockin'];
              Timestamp breakTime = snapshoot.data['break'];
              Timestamp afterbreakTime = snapshoot.data['afterbreak'];
              Timestamp clockoutTime = snapshoot.data['clockout'];
              Timestamp overtimeinTime = snapshoot.data['overtimein'];
              Timestamp overtimeoutTime = snapshoot.data['overtimeout'];
              bool isClockIn = snapshoot.data['isClockIn'];
              bool isOtherTime = snapshoot.data['otherTime'];
              bool isBreak = snapshoot.data['isBreak'];
              bool isAfterBreak = snapshoot.data['isAfterBreak'];
              bool isClockOut = snapshoot.data['isClockOut'];
              bool isOverTime = snapshoot.data['isOvertime'];
              bool isOverTimeIn = snapshoot.data['isOvertimeIn'];
              bool isOverTimeOut = snapshoot.data['isOvertimeOut'];
              bool isPermit = snapshoot.data['permit'];
              bool isSwitch = snapshoot.data['switch'];
              int isSwitchAcc = snapshoot.data['switchAcc'];
              int lateTime = snapshoot.data['late'];
              int type = snapshoot.data['type'];
              String pos = snapshoot.data['pos'];
              int active = -1;
              if (isClockIn) {
                active = 0;
              }
              if (isBreak) {
                active = 1;
              }
              if (isAfterBreak) {
                active = 2;
              }
              if (isClockOut) {
                active = 3;
              }
              if (isOverTimeIn) {
                active = 4;
              }
              if (isOverTimeOut) {
                active = 5;
              }

              if (isSwitchAcc != 1 && !isPermit) {
                await firestore
                    .collection('schedule')
                    .document(outlet)
                    .collection('scheduledetail')
                    .document('${dateTime.year}')
                    .collection('${dateTime.month}')
                    .document('${listJadwal[j].shift}')
                    .collection('listday')
                    .document('${dateTime.day}')
                    .get()
                    .then((snapshoots) {
                  if (snapshoots.exists) {
                    bool isOff = false;
                    Timestamp start, end;
                    if (type == 1) {
                      if (isOtherTime) {
                        start = snapshoots.data['fullstart2'];
                        end = snapshoots.data['fullend2'];
                      } else {
                        start = snapshoots.data['fullstart'];
                        end = snapshoots.data['fullend'];
                      }
                    } else {
                      if (isOtherTime) {
                        start = snapshoots.data['partstart2'];
                        end = snapshoots.data['partend2'];
                      } else {
                        start = snapshoots.data['partstart'];
                        end = snapshoots.data['partend'];
                      }
                    }
                    OverviewSchedule item = new OverviewSchedule(
                        dateTime,
                        start.toDate(),
                        end.toDate(),
                        '${listJadwal[j].shift}',
                        pos,
                        lateTime,
                        type,
                        isClockIn,
                        isBreak,
                        isAfterBreak,
                        isClockOut,
                        isOverTime,
                        isOverTimeIn,
                        isOverTimeOut,
                        isOff,
                        isPermit,
                        isSwitch,
                        isSwitchAcc,
                        switchDate.toDate(),
                        active,
                        clockinTime.toDate(),
                        breakTime.toDate(),
                        afterbreakTime.toDate(),
                        clockoutTime.toDate(),
                        overtimeinTime.toDate(),
                        overtimeoutTime.toDate());
                    setState(() {
                      listToday[i].check = true;
                      listSchedule.add(item);
                      print(
                          'ADA JADWAL TANGGAL ${dateTime.day} / ${listJadwal[j].shift} ');
                    });
                  } else {
                    print('Details empty!');
                  }
                });
              }
            } else {
              if(!listToday[i].check && j == listJadwal.length - 1){
                OverviewSchedule item = new OverviewSchedule(
                  dateTime,
                  dateTime,
                  dateTime,
                  '-',
                  '-',
                  0,
                  0,
                  false,
                  false,
                  false,
                  false,
                  false,
                  false,
                  false,
                  true,
                  false,
                  false,
                  0,
                  dateTime,
                  1,
                  dateTime,
                  dateTime,
                  dateTime,
                  dateTime,
                  dateTime,
                  dateTime);
              setState(() {
                listToday[i].check = true;
                listSchedule.add(item);
                print(
                    'TIDAK ADA JADWAL TANGGAL ${dateTime.day} / ${listJadwal[j].shift} ');
              });
              }
            }
          });
        } else {
          print('${listJadwal[j].shift} DI SKIP');
        }
      }
    }
  }

  void accSwitchRequest(int index) async {
    await firestore
        .collection('switchschedule')
        .document(outlet)
        .collection('listswitch')
        .document(widget.id)
        .updateData({
      'posTo': listSchedule[index].pos,
      'dateto': listSchedule[index].date,
      'shiftto': listSchedule[index].shift,
      'toAcc': true,
      'toDayOff': listSchedule[index].isOff
    });
    if (mounted) {
      await firestore
          .collection('user')
          .document(outlet)
          .collection('listuser')
          .document(id)
          .collection('${DateTime.now().year}')
          .document('request')
          .updateData({
        'switch': false,
      });
      if (mounted) {
        Navigator.pop(context);
        showCenterShortToast();
        Navigator.pop(context);
      }
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

  Color getRandomColor(int index) {
    Color _color;

    if (generatedColors.length > index) {
      _color = generatedColors[index];
    } else {
      _color = RandomColor().randomColor(
          colorHue: ColorHue.multiple(colorHues: _hueType),
          colorSaturation: _colorSaturation,
          colorBrightness: _colorLuminosity);

      generatedColors.add(_color);
    }

    return _color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.action == 10 ? 'Schedule' : 'Choose Schedule'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  margin: EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0)),
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/schedule.png',
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'My Schedule',
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .fontSize,
                                fontFamily: 'Google',
                              ),
                            ),
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: IconButton(
                                    icon: Icon(
                                      MaterialIcons.more_vert,
                                      size: 20.0,
                                    ),
                                    onPressed: () {}),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.action == 10
                          ? 'All your schedule'
                          : 'Choose one of your schedule',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.caption.color,
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.bold),
                    ),
                    if (listSchedule.length > 0)
                      ListView.builder(
                          itemCount: listSchedule.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: 5,
                                top: 15,
                              ),
                              padding: EdgeInsets.only(left: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: getRandomColor(index),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 3),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 15.0,
                                    bottom: 10.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Theme.of(context).backgroundColor,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      dateFormat
                                          .format(listSchedule[index].date),
                                      style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .body1
                                              .fontSize,
                                          fontFamily: 'Sans',
                                          color: listSchedule[index].isOff ? MediaQuery.of(
                                                                        context)
                                                                    .platformBrightness ==
                                                                Brightness.light
                                                            ? Colors.red[400]
                                                            : Colors.red[300] : listSchedule[index].isSwitch ? MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.orange : Colors.orange[300] : Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Text(
                                      listSchedule[index].isOff ? 'No schedule available' : listSchedule[index].shift,
                                      style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .title
                                              .fontSize,
                                          fontFamily: 'Google',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if(!listSchedule[index].isOff)
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    if(!listSchedule[index].isOff)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          timeFormat.format(
                                              listSchedule[index].startTime),
                                          style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .body1
                                                .fontSize,
                                            fontFamily: 'Sans',
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            for (int i = 0; i < 20; i++)
                                              Row(
                                                children: <Widget>[
                                                  Container(
                                                    width: 3.5,
                                                    height: 3.5,
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .caption
                                                            .color,
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
                                        Text(
                                          timeFormat.format(
                                              listSchedule[index].endTime),
                                          style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .body1
                                                .fontSize,
                                            fontFamily: 'Sans',
                                          ),
                                        ),
                                      ],
                                    )
                                    else
                                    Text(
                                      'Enjoy your free day!',
                                      style: TextStyle(
                                          fontSize:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  .fontSize,
                                          fontFamily: 'Google',
                                          fontWeight:
                                              FontWeight.bold),
                                    ),
                                    if (widget.action == 20 && !listSchedule[index].isSwitch)
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                    if (widget.action == 20 && !listSchedule[index].isSwitch)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: FlatButton(
                                                onPressed: () {
                                                  _prosesDialog();
                                                  accSwitchRequest(index);
                                                },
                                                child: Text(
                                                  'Choose',
                                                  style: TextStyle(
                                                      fontFamily: 'Google',
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                color: Theme.of(context).buttonColor,
                                                textColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5.0),
                                                ),
                                                splashColor: Colors.black26,
                                                highlightColor: Colors.black26,
                                              ),
                                      )
                                    else
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      if(listSchedule[index].isSwitch)
                                      Text(
                                        'Your switch request is being processed',
                                        style: TextStyle(
                                          color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.orange : Colors.orange[300],
                                          fontSize: Theme.of(context).textTheme.caption.fontSize,
                                          fontFamily: 'Sans'),
                                      ),
                                      if(listSchedule[index].isSwitch)
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          })
                    else
                      Center(
                          child: Padding(
                        padding:
                            const EdgeInsets.only(top: 150.0, bottom: 30.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      )),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
