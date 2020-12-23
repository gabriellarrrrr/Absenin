import 'package:absenin/supervisor/addschedule.dart';
import 'package:absenin/supervisor/listschedule.dart';
import 'package:absenin/supervisor/operational.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonthSchedule extends StatefulWidget {
  final DateTime month;

  const MonthSchedule({Key key, @required this.month}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MonthScheduleState();
  }
}

class ScheduleItem {
  String shift;
  bool setup;
  DateTime startfull,
      endfull,
      startpart,
      endpart,
      startfull2,
      endfull2,
      startpart2,
      endpart2;

  ScheduleItem(
      this.shift,
      this.setup,
      this.startfull,
      this.endfull,
      this.startpart,
      this.endpart,
      this.startfull2,
      this.endfull2,
      this.startpart2,
      this.endpart2);
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

class MonthScheduleState extends State<MonthSchedule> {
  List<OprationalItem> listJadwal = new List<OprationalItem>();
  List<ScheduleItem> listSchedule = new List<ScheduleItem>();
  DateTime dateTime = DateTime.now();
  DateFormat todayFormat = DateFormat.yMMMMd();
  DateFormat monthFormat = DateFormat.yMMMM();
  DateFormat year = DateFormat.y();
  DateFormat month = DateFormat.M();
  bool isEmptyy = false;
  String outlet;
  DateTime startFullTemp, endFullTemp, startPartTemp, endPartTemp;

  final Firestore firestore = Firestore.instance;

  @override
  void initState() {
    super.initState();
    _getDataUserFromPref();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
      getScheduleType();
      getOprationalSchedule();
    });
  }

  void getOprationalSchedule() async {
    firestore
        .collection('outlet')
        .where('name', isEqualTo: outlet)
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.isNotEmpty) {
        listJadwal.clear();
        snapshot.documents.forEach((k) {
          firestore
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

  void getScheduleType() async {
    firestore
        .collection('schedule')
        .document(outlet)
        .collection('scheduledetail')
        .document('detail')
        .collection('${widget.month.year}')
        .document('${widget.month.month}')
        .collection('type')
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documentChanges.isEmpty) {
        setState(() {
          isEmptyy = true;
        });
      } else {
        snapshot.documents.forEach((f) {
          Timestamp startfull = f.data['startfull'];
          Timestamp endfull = f.data['endfull'];
          Timestamp startpart = f.data['startpart'];
          Timestamp endpart = f.data['endpart'];
          Timestamp startfull2 = f.data['startfull2'];
          Timestamp endfull2 = f.data['endfull2'];
          Timestamp startpart2 = f.data['startpart2'];
          Timestamp endpart2 = f.data['endpart2'];

          ScheduleItem item = new ScheduleItem(
              f.data['name'],
              f.data['setup'],
              startfull.toDate(),
              endfull.toDate(),
              startpart.toDate(),
              endpart.toDate(),
              startfull2.toDate(),
              endfull2.toDate(),
              startpart2.toDate(),
              endpart2.toDate());
          setState(() {
            listSchedule.add(item);
          });
        });
      }
    });
  }

  void saveScheduleType(int index) async {
    await firestore
        .collection('schedule')
        .document(outlet)
        .collection('scheduledetail')
        .document('detail')
        .collection('${widget.month.year}')
        .document('${widget.month.month}')
        .collection('type')
        .document(listJadwal[index].shift)
        .setData({
      'name': listJadwal[index].shift,
      'setup': false,
      'startfull': listJadwal[index].startfull,
      'endfull': listJadwal[index].endfull,
      'startpart': listJadwal[index].startpart,
      'endpart': listJadwal[index].endpart,
      'startfull2': listJadwal[index].startfull2,
      'endfull2': listJadwal[index].endfull2,
      'startpart2': listJadwal[index].startpart2,
      'endpart2': listJadwal[index].endpart2
    });
  }

  void _showTimeChosseDialog(String title, DateTime startFull, DateTime endFull,
      DateTime startPart, DateTime endPart, int index) {
    showDialog(
        context: context,
        builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Wrap(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 30.0, bottom: 30.0),
                    child: Center(
                      child: Text(
                        'Choose set time',
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.title.fontSize,
                            fontFamily: 'Google'),
                      ),
                    )),
                Divider(
                  height: 0.0,
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showTimeDialog(
                          listSchedule[index].shift,
                          listSchedule[index].startfull,
                          listSchedule[index].endfull,
                          listSchedule[index].startpart,
                          listSchedule[index].endpart,
                          index,
                          10);
                    },
                    leading: Icon(
                      Ionicons.md_clock,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Default time',
                      style: TextStyle(fontFamily: 'Google'),
                    ),
                  ),
                ),
                Divider(
                  height: 0.0,
                ),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showTimeDialog(
                          listSchedule[index].shift,
                          listSchedule[index].startfull2,
                          listSchedule[index].endfull2,
                          listSchedule[index].startpart2,
                          listSchedule[index].endpart2,
                          index,
                          20);
                    },
                    leading: Icon(
                      Ionicons.md_clock,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Optional time',
                      style: TextStyle(fontFamily: 'Google'),
                    ),
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
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black54
                              : Colors.grey[400]),
                    ),
                  ),
                )
              ],
            )));
  }

  void _showTimeDialog(String title, DateTime startFull, DateTime endFull,
      DateTime startPart, DateTime endPart, int index, int action) async {
    final bool result = await showDialog(
        context: context,
        builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Wrap(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 30.0, bottom: 30.0),
                    child: Center(
                      child: Text(
                        '$title',
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.title.fontSize,
                            fontFamily: 'Google'),
                      ),
                    )),
                Divider(
                  height: 0.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Full Time',
                        style: TextStyle(
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.black54
                                : Colors.grey[400]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                'Clock In',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .fontSize,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TimePickerSpinner(
                                alignment: Alignment.center,
                                itemHeight: 30.0,
                                itemWidth: 30.0,
                                time: startFull,
                                isForce2Digits: true,
                                normalTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[100]
                                        : Colors.indigoAccent.withAlpha(90),
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.w300),
                                highlightedTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[400]
                                        : Colors.indigoAccent[100],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.bold),
                                onTimeChange: (time) {
                                  setState(() {
                                    startFullTemp = time;
                                  });
                                },
                              ),
                            ],
                          ),
                          Container(
                            width: 0.5,
                            height: 80.0,
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Clock Out',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .fontSize,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TimePickerSpinner(
                                alignment: Alignment.center,
                                itemHeight: 30.0,
                                itemWidth: 30.0,
                                time: endFull,
                                isForce2Digits: true,
                                normalTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[100]
                                        : Colors.indigoAccent.withAlpha(90),
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.w300),
                                highlightedTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[400]
                                        : Colors.indigoAccent[100],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.bold),
                                onTimeChange: (time) {
                                  setState(() {
                                    endFullTemp = time;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 0.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Part Time',
                        style: TextStyle(
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.black54
                                : Colors.grey[400]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                'Clock In',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .fontSize,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TimePickerSpinner(
                                alignment: Alignment.center,
                                itemHeight: 30.0,
                                itemWidth: 30.0,
                                time: startPart,
                                isForce2Digits: true,
                                normalTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[100]
                                        : Colors.indigoAccent.withAlpha(90),
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.w300),
                                highlightedTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[400]
                                        : Colors.indigoAccent[100],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.bold),
                                onTimeChange: (time) {
                                  setState(() {
                                    startPartTemp = time;
                                  });
                                },
                              ),
                            ],
                          ),
                          Container(
                            width: 0.5,
                            height: 80.0,
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Clock Out',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .fontSize,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TimePickerSpinner(
                                alignment: Alignment.center,
                                itemHeight: 30.0,
                                itemWidth: 30.0,
                                time: endPart,
                                isForce2Digits: true,
                                normalTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[100]
                                        : Colors.indigoAccent.withAlpha(90),
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.w300),
                                highlightedTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[400]
                                        : Colors.indigoAccent[100],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.bold),
                                onTimeChange: (time) {
                                  setState(() {
                                    endPartTemp = time;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 0.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                )
              ],
            )));
    if (result != null) {
      if (result) {
        if (action == 10) {
          await firestore
              .collection('schedule')
              .document(outlet)
              .collection('scheduledetail')
              .document('detail')
              .collection('${widget.month.year}')
              .document('${widget.month.month}')
              .collection('type')
              .document(title)
              .updateData({
            'startfull': startFullTemp,
            'endfull': endFullTemp,
            'startpart': startPartTemp,
            'endpart': endPartTemp
          });
          if (mounted) {
            setState(() {
              listSchedule[index].startfull = startFullTemp;
              listSchedule[index].endfull = endFullTemp;
              listSchedule[index].startpart = startPartTemp;
              listSchedule[index].endpart = endPartTemp;
            });
          }
        } else {
          await firestore
              .collection('schedule')
              .document(outlet)
              .collection('scheduledetail')
              .document('detail')
              .collection('${widget.month.year}')
              .document('${widget.month.month}')
              .collection('type')
              .document(title)
              .updateData({
            'startfull2': startFullTemp,
            'endfull2': endFullTemp,
            'startpart2': startPartTemp,
            'endpart2': endPartTemp
          });
          if (mounted) {
            setState(() {
              listSchedule[index].startfull2 = startFullTemp;
              listSchedule[index].endfull2 = endFullTemp;
              listSchedule[index].startpart2 = startPartTemp;
              listSchedule[index].endpart2 = endPartTemp;
            });
          }
        }
      }
    }
  }

  void _showScheduleDialog() {
    showDialog(
        context: context,
        builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Wrap(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 30.0, bottom: 30.0),
                    child: Center(
                      child: Text(
                        'New Schedule',
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.title.fontSize,
                            fontFamily: 'Google'),
                      ),
                    )),
                Divider(
                  height: 0.0,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: listJadwal.length,
                    itemBuilder: (context, index) {
                      bool checkDis = false;
                      for (int i = 0; i < listSchedule.length; i++) {
                        if (listSchedule[i].shift == listJadwal[index].shift) {
                          checkDis = true;
                          break;
                        }
                      }
                      return Column(
                        children: <Widget>[
                          Material(
                            color: checkDis == true
                                ? MediaQuery.of(context).platformBrightness ==
                                        Brightness.light
                                    ? Colors.grey[50]
                                    : Colors.grey[900]
                                : Colors.transparent,
                            child: ListTile(
                              enabled: checkDis ? false : true,
                              onTap: () {
                                setState(() {
                                  ScheduleItem item = new ScheduleItem(
                                    listJadwal[index].shift,
                                    false,
                                    listJadwal[index].startfull,
                                    listJadwal[index].endfull,
                                    listJadwal[index].startpart,
                                    listJadwal[index].endpart,
                                    listJadwal[index].startfull2,
                                    listJadwal[index].endfull2,
                                    listJadwal[index].startpart2,
                                    listJadwal[index].endpart2,
                                  );
                                  listSchedule.add(item);
                                  if (isEmptyy) {
                                    isEmptyy = !isEmptyy;
                                  }
                                });
                                Navigator.pop(context);
                                saveScheduleType(index);
                              },
                              leading: Icon(
                                Ionicons.md_calendar,
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[300]
                                        : Colors.indigoAccent[100],
                              ),
                              title: Text(
                                listJadwal[index].shift,
                                style: TextStyle(fontFamily: 'Google'),
                              ),
                              trailing: checkDis == true
                                  ? Icon(
                                      MaterialIcons.check_circle,
                                      size: 18.0,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Colors.green
                                          : Colors.green[400],
                                    )
                                  : null,
                            ),
                          ),
                          if (index != listJadwal.length - 1)
                            Container(
                              margin: EdgeInsets.only(left: 70.0),
                              height: 0.5,
                              color: Theme.of(context).dividerColor,
                            )
                        ],
                      );
                    }),
                Divider(
                  height: 0.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: FlatButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.of(context)
                          .push(_createRoute(OperationalPage()));
                      if (result != null) {
                        if (result) {
                          getOprationalSchedule();
                        }
                      }
                    },
                    child: Text(
                      'Other',
                      style: TextStyle(
                          fontFamily: 'Google',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                )
              ],
            )));
  }

  _gotoAddSchedulePage(
      String title,
      DateTime startfull,
      DateTime endfull,
      DateTime startpart,
      DateTime endpart,
      DateTime startfull2,
      DateTime endfull2,
      DateTime startpart2,
      DateTime endpart2) async {
    final result = await Navigator.of(context).push(_createRoute(AddSchedule(
      title: title,
      month: widget.month,
      startfull: startfull,
      endfull: endfull,
      startpart: startpart,
      endpart: endpart,
      startfull2: startfull2,
      endfull2: endfull2,
      startpart2: startpart2,
      endpart2: endpart2,
    )));

    if (result != null) {
      if (result) {
        await firestore
            .collection('schedule')
            .document(outlet)
            .collection('scheduledetail')
            .document('detail')
            .collection('${widget.month.year}')
            .document('${widget.month.month}')
            .collection('type')
            .document('$title')
            .updateData({'setup': true});
        listSchedule.clear();
        getScheduleType();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor:
      //     MediaQuery.of(context).platformBrightness == Brightness.light
      //         ? Theme.of(context).backgroundColor
      //         : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(monthFormat.format(widget.month)),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 24.0,
          ),
          onPressed: () async {
            if (listJadwal.length > 0) {
              _showScheduleDialog();
            } else {
              final result = await Navigator.of(context)
                  .push(_createRoute(OperationalPage()));
              if (result != null) {
                if (result) {
                  getOprationalSchedule();
                }
              }
            }
          }),
      body: SingleChildScrollView(
        child: !isEmptyy
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
                    child: Center(
                      child: Image.asset(
                        'assets/images/schedulespv.png',
                        width: MediaQuery.of(context).size.width * 0.65,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'All schedule',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.caption.color,
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (listSchedule.length > 0 && !isEmptyy)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        color: Theme.of(context).backgroundColor,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: listSchedule.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  Material(
                                    color: Theme.of(context).backgroundColor,
                                    child: ListTile(
                                      leading: Icon(
                                        Ionicons.md_calendar,
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? Colors.indigo[300]
                                            : Colors.indigoAccent[100],
                                      ),
                                      title: Text(
                                        listSchedule[index].shift,
                                        style: TextStyle(
                                            fontFamily: 'Google',
                                            fontWeight: FontWeight.bold,
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .subhead
                                                .fontSize),
                                      ),
                                      subtitle: Text(
                                        listSchedule[index].setup
                                            ? 'View'
                                            : 'Setup now',
                                        style: TextStyle(
                                            fontFamily: 'Sans',
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .fontSize),
                                      ),
                                      trailing: Icon(
                                        Feather.chevron_right,
                                      ),
                                      onLongPress: () {
                                        _showTimeChosseDialog(
                                            listSchedule[index].shift,
                                            listSchedule[index].startfull,
                                            listSchedule[index].endfull,
                                            listSchedule[index].startpart,
                                            listSchedule[index].endpart,
                                            index);
                                      },
                                      onTap: () {
                                        if (listSchedule[index].setup) {
                                          Navigator.of(context)
                                              .push(_createRoute(ListSchedule(
                                            shift: listSchedule[index].shift,
                                            month: widget.month,
                                            startfull:
                                                listSchedule[index].startfull,
                                            endfull:
                                                listSchedule[index].endfull,
                                            startpart:
                                                listSchedule[index].startpart,
                                            endpart:
                                                listSchedule[index].endpart,
                                            startfull2:
                                                listSchedule[index].startfull2,
                                            endfull2:
                                                listSchedule[index].endfull2,
                                            startpart2:
                                                listSchedule[index].startpart2,
                                            endpart2:
                                                listSchedule[index].endpart2,
                                          )));
                                        } else {
                                          _gotoAddSchedulePage(
                                              listSchedule[index].shift,
                                              listSchedule[index].startfull,
                                              listSchedule[index].endfull,
                                              listSchedule[index].startpart,
                                              listSchedule[index].endpart,
                                              listSchedule[index].startfull2,
                                              listSchedule[index].endfull2,
                                              listSchedule[index].startpart2,
                                              listSchedule[index].endpart2);
                                        }
                                      },
                                    ),
                                  ),
                                  if (index < listSchedule.length - 1)
                                    Container(
                                      height: 0.5,
                                      margin: EdgeInsets.only(left: 70.0),
                                      color: Theme.of(context).dividerColor,
                                    )
                                ],
                              );
                            }),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 150.0, bottom: 15.0),
                      child: Center(
                          child: Text(
                        "Oopss.. can't find schedule.",
                        style: TextStyle(
                            fontFamily: 'Sans',
                            fontSize:
                                Theme.of(context).textTheme.caption.fontSize,
                            color: Theme.of(context).textTheme.caption.color),
                      )),
                    ),
                ],
              )
            : Padding(
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
                      "Oopss.. can't find schedule.",
                      style: TextStyle(
                          fontFamily: 'Sans',
                          color: Theme.of(context).disabledColor,
                          fontSize: Theme.of(context).textTheme.title.fontSize),
                    )
                  ],
                ),
              ),
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
}
