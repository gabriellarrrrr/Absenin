import 'package:absenin/supervisor/addschedule.dart';
import 'package:absenin/supervisor/listschedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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

class TodayItem {
  final String date;
  final String shift;
  final String startTime;
  final String endTime;

  TodayItem(this.date, this.shift, this.startTime, this.endTime);
}

class ScheduleItem {
  String shift;
  bool setup;

  ScheduleItem(this.shift, this.setup);
}

class MonthScheduleState extends State<MonthSchedule> {
  List listJadwal = ['Shift 1', 'Shift 2'];
  List<ScheduleItem> listSchedule = new List<ScheduleItem>();
  List<TodayItem> listToday = new List<TodayItem>();
  String monthNow;
  DateTime dateTime = DateTime.now();
  DateFormat todayFormat = DateFormat.yMMMMd();
  DateFormat monthFormat = DateFormat.yMMMM();
  DateFormat year = DateFormat.y();
  DateFormat month = DateFormat.M();
  bool isEmptyy = false;
  String outlet;

  final Firestore firestore = Firestore.instance;

  @override
  void initState() {
    _checkTimeNow();
    super.initState();
    _getDataUserFromPref();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
      getScheduleType();
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
          snapshot.documents.forEach((f){
            ScheduleItem item = new ScheduleItem(f.data['name'], f.data['setup']);
            setState(() {
              listSchedule.add(item);
            });
          });
        }
    });
  }

  void saveScheduleType(String shift) async {
    await firestore
        .collection('schedule')
        .document(outlet)
        .collection('scheduledetail')
        .document('detail')
        .collection('${widget.month.year}')
        .document('${widget.month.month}')
        .collection('type')
        .document(shift)
        .setData({
      'name' : shift,
      'setup' : false
    });
  }

  _checkTimeNow() {
    String today = todayFormat.format(dateTime);
    String month = monthFormat.format(dateTime);

    TodayItem todayItem = new TodayItem(today, 'Shift 1', '07:00', '15:00');
    TodayItem todayItem2 = new TodayItem(today, 'Shift 2', '14:00', '22:00');

    setState(() {
      monthNow = month;
      listToday.add(todayItem);
      listToday.add(todayItem2);
    });
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
                        if (listSchedule[i].shift == listJadwal[index]) {
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
                                      listJadwal[index], false);
                                  listSchedule.add(item);
                                  if (isEmptyy) {
                                    isEmptyy = !isEmptyy;
                                  }
                                });
                                Navigator.pop(context);
                                saveScheduleType(listJadwal[index]);
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
                                listJadwal[index],
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Other',
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

  _gotoAddSchedulePage(String title) async {

    final result = await Navigator.of(context).push(_createRoute(AddSchedule(
      title: title, month: widget.month,
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
          .updateData({
            'setup': true
          });
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
          onPressed: () {
            _showScheduleDialog();
          }),
      body: SingleChildScrollView(
        child: !isEmptyy ? Column(
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
                                      onTap: () {
                                        if (listSchedule[index].setup) {
                                          Navigator.of(context)
                                              .push(_createRoute(ListSchedule(shift: listSchedule[index].shift, month: widget.month,)));
                                        } else {
                                          _gotoAddSchedulePage(
                                              listSchedule[index].shift);
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
