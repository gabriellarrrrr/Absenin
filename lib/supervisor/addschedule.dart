import 'package:absenin/supervisor/liststaff.dart' as staffpage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:some_calendar/some_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSchedule extends StatefulWidget {

  final String title;
  final DateTime month;

  const AddSchedule({Key key, @required this.title, @required this.month}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddScheduleState();
  }
}

class StaffItem {
  String id;
  String img;
  String name;
  String part;
  int type;
  DateTime libur;
  List<DateTime> overtime;
  bool check;

  StaffItem(this.id, this.img, this.name, this.part, this.type, this.libur, this.overtime,
      this.check);
}

class DateItem {
  bool check;
  DateTime date;

  DateItem(this.check, this.date);
}

class DateItem2 {
  bool check;
  DateTime date;

  DateItem2(this.check, this.date);
}

class DateTimes {
  bool check;
  DateTime date;
  DateTime startFull;
  DateTime endFull;
  DateTime startPart;
  DateTime endPart;
  bool edited;

  DateTimes(this.check, this.date, this.startFull, this.endFull, this.startPart,
      this.endPart, this.edited);
}

class PartItem {
  String part;
  bool check;

  PartItem(this.part, this.check);
}

class AddScheduleState extends State<AddSchedule> {
  List<StaffItem> listStaff = new List<StaffItem>();
  List<staffpage.StaffItem> listTemp = new List<staffpage.StaffItem>();
  List<DateTimes> listDateTime = List<DateTimes>();
  List<DateItem> listDateDayOff = List<DateItem>();
  List<DateItem2> listDateOvertime = List<DateItem2>();
  List<DateTime> selectedDates = List();
  List<PartItem> listPart = new List<PartItem>();
  DateTime selectedDate = DateTime.now();
  bool dateSelected = false;
  bool staffSelected = false;
  int dateCountSelected = 0;
  int staffCountSelected = 0;
  int fullTimeCount = 0;
  int partTimeCount = 0;
  bool _canVibrate = true;
  DateFormat dateTimeFormat = DateFormat.yMMMMEEEEd();
  DateFormat year = DateFormat.y();
  DateFormat month = DateFormat.M();
  DateFormat day = DateFormat.d();
  int lastDayNum;
  String outlet;

  PartItem part1 = new PartItem('Inventori', false);
  PartItem part2 = new PartItem('Front Linner', false);
  PartItem part3 = new PartItem('Temperedglass', false);
  PartItem part4 = new PartItem('Online Service', false);

  final Firestore firestore = Firestore.instance;

  @override
  void initState() {
    super.initState();
    DateTime lastDay = new DateTime(widget.month.year, widget.month.month+1, 0);
    lastDayNum = lastDay.day;
    selectedDates.add(selectedDate);
    listPart.add(part1);
    listPart.add(part2);
    listPart.add(part3);
    listPart.add(part4);
    _checkVibrate();
    _getDataUserFromPref();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
    });
  }

  void saveSchedule() async {
    for (int i = 0; i < listDateTime.length; i++) {
      String tahun = year.format(listDateTime[i].date);
      String bulan = month.format(listDateTime[i].date);
      String tanggal = day.format(listDateTime[i].date);

      await firestore
          .collection('schedule')
          .document(outlet)
          .collection('scheduledetail')
          .document(tahun)
          .collection(bulan)
          .document(widget.title)
          .collection('listday')
          .document(tanggal)
          .setData({
        'fullstart': listDateTime[i].startFull,
        'fullend': listDateTime[i].endFull,
        'partstart': listDateTime[i].startPart,
        'partend': listDateTime[i].endPart,
      });

      for (int j = 0; j < listStaff.length; j++) {
        if (listStaff[j].libur != listDateTime[i].date) {
          bool overtime = false;
          if(listStaff[j].overtime != null){
            overtime = listStaff[j].overtime.contains(listDateTime[i].date);
          }
          await firestore
            .collection('schedule')
            .document(outlet)
            .collection('scheduledetail')
            .document(tahun)
            .collection(bulan)
            .document(widget.title)
            .collection('listday')
            .document(tanggal)
            .collection('liststaff')
            .document(listStaff[j].id)
            .setData({
            'pos': listStaff[j].part,
            'type': listStaff[j].type,
            'clockin': listDateTime[i].startPart,
            'clockout': listDateTime[i].startPart,
            'break': listDateTime[i].startPart,
            'afterbreak': listDateTime[i].startPart,
            'overtimein': listDateTime[i].startPart,
            'overtimeout': listDateTime[i].startPart,
            'late': 0,
            'isClockIn': false,
            'isBreak': false,
            'isAfterBreak': false,
            'isClockOut': false,
            'isOvertime': overtime,
            'isOvertimeIn': false,
            'isOvertimeOut': false,
            'permit': false,
            'switch': false,
            'switchAcc': 0,
            'switchDate': listDateTime[i].startPart
          });
        }
      }
    }
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context, true);
    }
  }

  _checkVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  void _showCalendarDialog() {
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
                        'Set Date',
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.title.fontSize,
                            fontFamily: 'Google'),
                      ),
                    )),
                Divider(
                  height: 0.0,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 25.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Theme.of(context).backgroundColor),
                  child: SomeCalendar(
                    primaryColor: Color(0xff5833A5),
                    mode: SomeMode.Multi,
                    isWithoutDialog: true,
                    scrollDirection: Axis.horizontal,
                    startDate: widget.month,
                    lastDate: Jiffy(widget.month).add(days: lastDayNum),
                    textColor: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.black87
                        : Colors.white,
                    done: (date) {
                      setState(() {
                        selectedDates = date;
                      });
                    },
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
                      if (selectedDates.length > 0) {
                        listDateTime.clear();
                        for (int i = 0; i < selectedDates.length; i++) {
                          DateTimes date = new DateTimes(
                              false,
                              selectedDates[i],
                              DateTime(
                                  selectedDates[i].year,
                                  selectedDates[i].month,
                                  selectedDates[i].day,
                                  8,
                                  0),
                              DateTime(
                                  selectedDates[i].year,
                                  selectedDates[i].month,
                                  selectedDates[i].day,
                                  16,
                                  0),
                              DateTime(
                                  selectedDates[i].year,
                                  selectedDates[i].month,
                                  selectedDates[i].day,
                                  9,
                                  30),
                              DateTime(
                                  selectedDates[i].year,
                                  selectedDates[i].month,
                                  selectedDates[i].day,
                                  15,
                                  30),
                              false);
                          DateItem item = new DateItem(false, selectedDates[i]);
                          DateItem2 item2 = new DateItem2(false, selectedDates[i]);
                          setState(() {
                            listDateTime.add(date);
                            listDateDayOff.add(item);
                            listDateOvertime.add(item2);
                          });
                        }
                      } else {
                        setState(() {
                          listDateTime.clear();
                        });
                      }
                      Navigator.pop(context);
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
  }

  void _showTimeDialog(String title, DateTime startFull, DateTime endFull,
      DateTime startPart, DateTime endPart, int position) {
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
                                    if (startFull != time) {
                                      listDateTime[position].startFull = time;
                                      listDateTime[position].edited = true;
                                    }
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
                                    if (endFull != time) {
                                      listDateTime[position].endFull = time;
                                      listDateTime[position].edited = true;
                                    }
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
                                    if (startPart != time) {
                                      listDateTime[position].startPart = time;
                                      listDateTime[position].edited = true;
                                    }
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
                                    if (endPart != time) {
                                      listDateTime[position].endPart = time;
                                      listDateTime[position].edited = true;
                                    }
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
                      Navigator.pop(context);
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
  }

  _showSinglePostDialog(String title, int position) async {
    final bool result = await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
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
                            title,
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
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 10.0, bottom: 8.0),
                          child: Text(
                            'Off Day',
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
                        if (listDateDayOff.length > 0)
                          Container(
                            height: 48.0,
                            margin: EdgeInsets.only(top: 5.0, bottom: 15.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: listDateDayOff.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  DateFormat dateFormat = DateFormat.d();
                                  return Container(
                                    width: 50.0,
                                    height: 48.0,
                                    margin: index == listDateDayOff.length - 1
                                        ? EdgeInsets.only(
                                            left: 5.0,
                                            right: 15.0,
                                            top: 8.0,
                                            bottom: 10.0)
                                        : index == 0
                                            ? EdgeInsets.only(
                                                left: 15.0,
                                                right: 5.0,
                                                top: 8.0,
                                                bottom: 10.0)
                                            : EdgeInsets.only(
                                                left: 5.0,
                                                right: 5.0,
                                                top: 8.0,
                                                bottom: 10.0),
                                    child: FlatButton(
                                        padding: EdgeInsets.zero,
                                        color: listDateDayOff[index].check
                                            ? MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.red[50]
                                                : Colors.red.withAlpha(30)
                                            : Theme.of(context)
                                                .dividerColor
                                                .withAlpha(10),
                                        textColor: listDateDayOff[index].check
                                            ? MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.red[400]
                                                : Colors.red[400]
                                            : MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.black54
                                                : Colors.white70,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          // side: BorderSide(
                                          //   color: listDateDayOff[index].check ? Theme.of(context).accentColor : Theme.of(context).disabledColor,
                                          // )
                                        ),
                                        onPressed: () {
                                          for (int j = 0;
                                              j < listDateDayOff.length;
                                              j++) {
                                            setState(() {
                                              listDateDayOff[j].check = false;
                                            });
                                          }
                                          setState(() {
                                            listDateDayOff[index].check =
                                                !listDateDayOff[index].check;
                                          });
                                        },
                                        child: Text(
                                          dateFormat
                                              .format(listDateDayOff[index].date),
                                          style: TextStyle(
                                              fontFamily: 'Google',
                                              fontWeight: FontWeight.bold,
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .body2
                                                  .fontSize),
                                        )),
                                  );
                                }),
                          )
                        else
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10.0,
                              ),
                              Center(
                                child: FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showCalendarDialog();
                                    },
                                    textColor: Theme.of(context).buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      'Choose Date',
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                          Divider(
                      height: 0.0,
                    ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 10.0, bottom: 8.0),
                            child: Text(
                              'Overtime Day',
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
                          if(listDateOvertime.length > 0)
                          Container(
                            height: 48.0,
                            margin: EdgeInsets.only(top: 5.0, bottom: 15.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: listDateOvertime.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  DateFormat dateFormat = DateFormat.d();
                                  return Container(
                                    width: 50.0,
                                    height: 48.0,
                                    margin: index == listDateOvertime.length - 1
                                        ? EdgeInsets.only(
                                            left: 5.0,
                                            right: 15.0,
                                            top: 8.0,
                                            bottom: 10.0)
                                        : index == 0
                                            ? EdgeInsets.only(
                                                left: 15.0,
                                                right: 5.0,
                                                top: 8.0,
                                                bottom: 10.0)
                                            : EdgeInsets.only(
                                                left: 5.0,
                                                right: 5.0,
                                                top: 8.0,
                                                bottom: 10.0),
                                    child: FlatButton(
                                        padding: EdgeInsets.zero,
                                        color: listDateOvertime[index].check
                                            ? MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.green[50]
                                                : Colors.green.withAlpha(30)
                                            : Theme.of(context)
                                                .dividerColor
                                                .withAlpha(10),
                                        textColor: listDateOvertime[index].check
                                            ? MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.green[400]
                                                : Colors.green[400]
                                            : MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.black54
                                                : Colors.white70,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          // side: BorderSide(
                                          //   color: listDateOvertime[index].check ? Theme.of(context).accentColor : Theme.of(context).disabledColor,
                                          // )
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            listDateOvertime[index].check =
                                                !listDateOvertime[index].check;
                                          });
                                        },
                                        child: Text(
                                          dateFormat
                                              .format(listDateOvertime[index].date),
                                          style: TextStyle(
                                              fontFamily: 'Google',
                                              fontWeight: FontWeight.bold,
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .body2
                                                  .fontSize),
                                        )),
                                  );
                                }
                              ),
                          )
                          else 
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10.0,
                              ),
                              Center(
                                child: FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showCalendarDialog();
                                    },
                                    textColor: Theme.of(context).buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      'Choose Date',
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                          Divider(
                      height: 0.0,
                    ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 10.0, bottom: 15.0),
                          child: Text(
                            'Part of',
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
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listPart.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              ListTile(
                                onTap: () {
                                  for (int j = 0; j < listPart.length; j++) {
                                    setState(() {
                                      listPart[j].check = false;
                                    });
                                  }
                                  setState(() {
                                    listPart[index].check =
                                        !listPart[index].check;
                                  });
                                },
                                leading: Icon(
                                  listPart[index].check
                                      ? Icons.check_circle
                                      : Icons.panorama_fish_eye,
                                  size: 20.0,
                                  color: listPart[index].check
                                      ? MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Colors.green
                                          : Colors.green[400]
                                      : Theme.of(context).disabledColor,
                                ),
                                title: Text(
                                  listPart[index].part,
                                  style: TextStyle(fontFamily: 'Google'),
                                ),
                              ),
                              if (index != listPart.length - 1)
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
                ));
          });
        });
    if (result != null) {
      if (result) {
        for (int i = 0; i < listPart.length; i++) {
          if (listPart[i].check) {
            setState(() {
              listStaff[position].part = listPart[i].part;
            });
          }
        }
        for (int j = 0; j < listDateDayOff.length; j++) {
          if (listDateDayOff[j].check) {
            setState(() {
              listStaff[position].libur = listDateDayOff[j].date;
            });
          }
        }
        List<DateTime> overtime = List<DateTime>();
        for (int k = 0; k < listDateOvertime.length; k++) {
          if (listDateOvertime[k].check) {
            overtime.add(listDateOvertime[k].date);
            setState(() {
              listStaff[position].overtime = overtime;
            });
          }
        }
      }
    }
  }

  _showMultiplePostDialog() async {
    final bool result = await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
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
                            'Multiple Setting',
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
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 10.0, bottom: 8.0),
                          child: Text(
                            'Off Day',
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
                        if (listDateDayOff.length > 0)
                          Container(
                            height: 48.0,
                            margin: EdgeInsets.only(top: 5.0, bottom: 15.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: listDateDayOff.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  DateFormat dateFormat = DateFormat.d();
                                  return Container(
                                    width: 50.0,
                                    height: 48.0,
                                    margin: index == listDateDayOff.length - 1
                                        ? EdgeInsets.only(
                                            left: 5.0,
                                            right: 15.0,
                                            top: 8.0,
                                            bottom: 10.0)
                                        : index == 0
                                            ? EdgeInsets.only(
                                                left: 15.0,
                                                right: 5.0,
                                                top: 8.0,
                                                bottom: 10.0)
                                            : EdgeInsets.only(
                                                left: 5.0,
                                                right: 5.0,
                                                top: 8.0,
                                                bottom: 10.0),
                                    child: FlatButton(
                                        padding: EdgeInsets.zero,
                                        color: listDateDayOff[index].check
                                            ? MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.red[50]
                                                : Colors.red.withAlpha(30)
                                            : Theme.of(context)
                                                .dividerColor
                                                .withAlpha(10),
                                        textColor: listDateDayOff[index].check
                                            ? MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.red[400]
                                                : Colors.red[400]
                                            : MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.black54
                                                : Colors.white70,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          // side: BorderSide(
                                          //   color: listDateDayOff[index].check ? Theme.of(context).accentColor : Theme.of(context).disabledColor,
                                          // )
                                        ),
                                        onPressed: () {
                                          for (int j = 0;
                                              j < listDateDayOff.length;
                                              j++) {
                                            setState(() {
                                              listDateDayOff[j].check = false;
                                            });
                                          }
                                          setState(() {
                                            listDateDayOff[index].check =
                                                !listDateDayOff[index].check;
                                          });
                                        },
                                        child: Text(
                                          dateFormat
                                              .format(listDateDayOff[index].date),
                                          style: TextStyle(
                                              fontFamily: 'Google',
                                              fontWeight: FontWeight.bold,
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .body2
                                                  .fontSize),
                                        )),
                                  );
                                }),
                          )
                        else
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10.0,
                              ),
                              Center(
                                child: FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showCalendarDialog();
                                    },
                                    textColor: Theme.of(context).buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      'Choose Date',
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                          Divider(
                      height: 0.0,
                    ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 10.0, bottom: 8.0),
                            child: Text(
                              'Overtime Day',
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
                          if(listDateOvertime.length > 0)
                          Container(
                            height: 48.0,
                            margin: EdgeInsets.only(top: 5.0, bottom: 15.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: listDateOvertime.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  DateFormat dateFormat = DateFormat.d();
                                  return Container(
                                    width: 50.0,
                                    height: 48.0,
                                    margin: index == listDateOvertime.length - 1
                                        ? EdgeInsets.only(
                                            left: 5.0,
                                            right: 15.0,
                                            top: 8.0,
                                            bottom: 10.0)
                                        : index == 0
                                            ? EdgeInsets.only(
                                                left: 15.0,
                                                right: 5.0,
                                                top: 8.0,
                                                bottom: 10.0)
                                            : EdgeInsets.only(
                                                left: 5.0,
                                                right: 5.0,
                                                top: 8.0,
                                                bottom: 10.0),
                                    child: FlatButton(
                                        padding: EdgeInsets.zero,
                                        color: listDateOvertime[index].check
                                            ? MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.green[50]
                                                : Colors.green.withAlpha(30)
                                            : Theme.of(context)
                                                .dividerColor
                                                .withAlpha(10),
                                        textColor: listDateOvertime[index].check
                                            ? MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.green[400]
                                                : Colors.green[400]
                                            : MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.black54
                                                : Colors.white70,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          // side: BorderSide(
                                          //   color: listDateOvertime[index].check ? Theme.of(context).accentColor : Theme.of(context).disabledColor,
                                          // )
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            listDateOvertime[index].check =
                                                !listDateOvertime[index].check;
                                          });
                                        },
                                        child: Text(
                                          dateFormat
                                              .format(listDateOvertime[index].date),
                                          style: TextStyle(
                                              fontFamily: 'Google',
                                              fontWeight: FontWeight.bold,
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .body2
                                                  .fontSize),
                                        )),
                                  );
                                }
                              ),
                          )
                          else 
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10.0,
                              ),
                              Center(
                                child: FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showCalendarDialog();
                                    },
                                    textColor: Theme.of(context).buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      'Choose Date',
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                          Divider(
                      height: 0.0,
                    ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 10.0, bottom: 15.0),
                          child: Text(
                            'Part of',
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
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listPart.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              ListTile(
                                onTap: () {
                                  for (int j = 0; j < listPart.length; j++) {
                                    setState(() {
                                      listPart[j].check = false;
                                    });
                                  }
                                  setState(() {
                                    listPart[index].check =
                                        !listPart[index].check;
                                  });
                                },
                                leading: Icon(
                                  listPart[index].check
                                      ? Icons.check_circle
                                      : Icons.panorama_fish_eye,
                                  size: 20.0,
                                  color: listPart[index].check
                                      ? MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Colors.green
                                          : Colors.green[400]
                                      : Theme.of(context).disabledColor,
                                ),
                                title: Text(
                                  listPart[index].part,
                                  style: TextStyle(fontFamily: 'Google'),
                                ),
                              ),
                              if (index != listPart.length - 1)
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
                ));
          });
        });
    if (result != null) {
      if (result) {
        String selectedPart;
        DateTime selectedLibur;
        List<DateTime> selectedOver = List<DateTime>();
        for (int i = 0; i < listPart.length; i++) {
          if (listPart[i].check) {
            selectedPart = listPart[i].part;
          }
        }
        for (int i = 0; i < listDateDayOff.length; i++) {
          if (listDateDayOff[i].check) {
            selectedLibur = listDateDayOff[i].date;
          }
        }
        for (int i = 0; i < listDateOvertime.length; i++) {
          if (listDateOvertime[i].check) {
            selectedOver.add(listDateOvertime[i].date);
          }
        }
        for (int j = 0; j < listStaff.length; j++) {
          if (listStaff[j].check) {
            setState(() {
              if (selectedPart != null) {
                listStaff[j].part = selectedPart;
              }
              if (selectedLibur != null) {
                listStaff[j].libur = selectedLibur;
              }
              if(selectedOver != null){
                listStaff[j].overtime = selectedOver;
              }
              listStaff[j].check = false;
            });
          }
        }
        staffSelected = false;
      }
    }
  }

  _gotoListStaffPage() async {
    final result =
        await Navigator.of(context).push(_createRoute(staffpage.Staff(
      action: 20,
      listCurrent: listTemp,
    )));
    if (result != null) {
      listTemp = result;
      if (listTemp.length > 0) {
        listStaff.clear();
        int fullTime = 0;
        int partTime = 0;
        for (int i = 0; i < listTemp.length; i++) {
          StaffItem item = new StaffItem(listTemp[i].id, listTemp[i].img,
              listTemp[i].name, '', listTemp[i].type, null, null, false);
          if (listTemp[i].type == 1) {
            fullTime++;
          } else {
            partTime++;
          }
          setState(() {
            listStaff.add(item);
            fullTimeCount = fullTime;
            partTimeCount = partTime;
          });
        }
      }
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
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(dateSelected
                ? '$dateCountSelected'
                : staffSelected ? '$staffCountSelected' : widget.title),
            actions: <Widget>[
              if(!dateSelected && !staffSelected)
              FlatButton(
                child: Text(
                  'Save',
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontFamily: 'Google',
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                splashColor: Theme.of(context).appBarTheme.color,
                highlightColor: Theme.of(context).appBarTheme.color,
                onPressed: () {
                  _prosesDialog();
                  saveSchedule();
                },
              ),
              if (dateSelected)
                IconButton(
                  icon: Icon(
                    MaterialIcons.delete,
                    size: 20.0,
                  ),
                  onPressed: () {
                    List<DateTimes> date = List<DateTimes>();
                    List<DateItem> dayOff = List<DateItem>();
                    List<DateItem2> overtime = List<DateItem2>();
                    for(int i = 0; i < listDateTime.length; i++){
                      if(!listDateTime[i].check){
                        date.add(listDateTime[i]);
                      }
                    }
                    for(int j = 0; j < listDateDayOff.length; j++){
                      for(int k = 0; k < date.length; k++){
                        if(listDateDayOff[j].date.day == date[k].date.day){
                          dayOff.add(listDateDayOff[j]);
                        }
                      }
                    }
                    for(int j = 0; j < listDateOvertime.length; j++){
                      for(int k = 0; k < date.length; k++){
                        if(listDateOvertime[j].date.day == date[k].date.day){
                          overtime.add(listDateOvertime[j]);
                        }
                      }
                    }
                    setState(() {
                      listDateTime = date;
                      listDateDayOff = dayOff;
                      listDateOvertime = overtime;
                      dateSelected = !dateSelected;
                      dateCountSelected = 0;
                    });
                  }
                ),
              if (staffSelected)
                Row(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20.0,
                        ),
                        onPressed: () {
                          for (int i = 0; i < listPart.length; i++) {
                            setState(() {
                              listPart[i].check = false;
                            });
                          }
                          for (int j = 0; j < listDateDayOff.length; j++) {
                            setState(() {
                              listDateDayOff[j].check = false;
                            });
                          }
                          for (int k = 0; k < listDateOvertime.length; k++) {
                            setState(() {
                              listDateOvertime[k].check = false;
                            });
                          }
                          _showMultiplePostDialog();
                        }),
                    IconButton(
                        icon: Icon(
                          MaterialIcons.delete,
                          size: 20.0,
                        ),
                        onPressed: () {
                          List<StaffItem> staff = List<StaffItem>();
                          List<staffpage.StaffItem> temp = List<staffpage.StaffItem>();
                          for (int i = 0; i < listStaff.length; i++) {
                            if(!listStaff[i].check){
                              staff.add(listStaff[i]);
                            }
                          }
                          for (int j = 0; j < listTemp.length; j++) {
                            for(int k = 0; k < staff.length; k++){
                              if(listTemp[j].id == staff[k].id){
                                temp.add(listTemp[j]);
                              }
                            }
                          }
                          setState(() {
                            listStaff = staff;
                            listTemp = temp;
                            staffSelected = !staffSelected;
                            staffCountSelected = 0;
                          });
                        }
                      )
                  ],
                )
            ],
          ),
          floatingActionButton: FloatingActionButton(
              child: Icon(
                Ionicons.ios_person_add,
                color: Colors.white,
                size: 24.0,
              ),
              onPressed: () {
                _gotoListStaffPage();
              }),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 20.0, bottom: 10.0),
                  child: Text(
                    'Date Time',
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    child: Column(
                      children: <Widget>[
                        if (listDateTime.length > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0, top: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Set up for ${listDateTime.length} days',
                                      style: TextStyle(
                                          fontFamily: 'Google',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .headline
                                              .fontSize),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          child: Text(
                                            'Full time',
                                            style: TextStyle(
                                                fontFamily: 'Sans',
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .fontSize,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .color),
                                          ),
                                        ),
                                        Text(
                                          '07:00 - 16:00 WIB',
                                          style: TextStyle(
                                              fontFamily: 'Sans',
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .fontSize,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Divider(
                                      height: 0.0,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          child: Text(
                                            'Part time',
                                            style: TextStyle(
                                                fontFamily: 'Sans',
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .fontSize,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .color),
                                          ),
                                        ),
                                        Text(
                                          '09:30 - 15.30 WIB',
                                          style: TextStyle(
                                              fontFamily: 'Sans',
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .fontSize,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Divider(
                                      height: 0.0,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      'List days',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Divider(
                                      height: 0.0,
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: listDateTime.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: <Widget>[
                                        Material(
                                          color: listDateTime[index].check
                                              ? MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.light
                                                  ? Colors.grey[50]
                                                  : Colors.grey[900]
                                              : Colors.transparent,
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
                                              dateTimeFormat.format(
                                                  listDateTime[index].date),
                                              style:
                                                  TextStyle(fontFamily: 'Sans'),
                                            ),
                                            trailing: listDateTime[index].check
                                                ? Icon(
                                                    Icons.check_circle,
                                                    size: 18.0,
                                                    color: MediaQuery.of(
                                                                    context)
                                                                .platformBrightness ==
                                                            Brightness.light
                                                        ? Colors.green
                                                        : Colors.green[400],
                                                  )
                                                : listDateTime[index].edited
                                                    ? Container(
                                                        width: 10.0,
                                                        height: 10.0,
                                                        margin: EdgeInsets.only(
                                                            right: 15.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: MediaQuery.of(
                                                                          context)
                                                                      .platformBrightness ==
                                                                  Brightness
                                                                      .light
                                                              ? Colors.green
                                                              : Colors
                                                                  .green[400],
                                                        ),
                                                      )
                                                    : null,
                                            onLongPress: () {
                                              setState(() {
                                                listDateTime[index].check =
                                                    true;
                                                dateSelected = true;
                                                dateCountSelected++;
                                                if (staffSelected) {
                                                  staffSelected = false;
                                                  staffCountSelected = 0;
                                                  for (int i = 0;
                                                      i < listStaff.length;
                                                      i++) {
                                                    if (listStaff[i].check) {
                                                      setState(() {
                                                        listStaff[i].check =
                                                            false;
                                                      });
                                                    }
                                                  }
                                                }
                                              });
                                            },
                                            onTap: () {
                                              if (dateSelected) {
                                                if (listDateTime[index].check ==
                                                    true) {
                                                  setState(() {
                                                    listDateTime[index].check =
                                                        false;
                                                    dateCountSelected--;
                                                    if (dateCountSelected ==
                                                        0) {
                                                      dateSelected = false;
                                                    }
                                                  });
                                                } else {
                                                  setState(() {
                                                    listDateTime[index].check =
                                                        true;
                                                    dateCountSelected++;
                                                  });
                                                }
                                              } else {
                                                _showTimeDialog(
                                                    dateTimeFormat.format(
                                                        listDateTime[index]
                                                            .date),
                                                    listDateTime[index]
                                                        .startFull,
                                                    listDateTime[index].endFull,
                                                    listDateTime[index]
                                                        .startPart,
                                                    listDateTime[index].endPart,
                                                    index);
                                              }
                                            },
                                          ),
                                        ),
                                        if (index < listDateTime.length - 1)
                                          Container(
                                            height: 0.5,
                                            margin: EdgeInsets.only(
                                                left: 70.0, right: 20.0),
                                            color:
                                                Theme.of(context).dividerColor,
                                          )
                                        else
                                          Container(
                                            height: 0.5,
                                            margin: EdgeInsets.only(
                                                left: 20.0, right: 20.0),
                                            color:
                                                Theme.of(context).dividerColor,
                                          )
                                      ],
                                    );
                                  }),
                            ],
                          )
                        else
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                  top: 30.0,
                                  bottom: 5.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withAlpha(10)),
                                    child: Icon(Ionicons.ios_calendar,
                                        size: 46.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color),
                                  ),
                                ],
                              )),
                        SizedBox(
                          height: 10.0,
                        ),
                        FlatButton(
                            onPressed: () {
                              _showCalendarDialog();
                            },
                            textColor: Theme.of(context).buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              listDateTime.length > 0
                                  ? 'Change Date'
                                  : 'Choose Date',
                              style: TextStyle(
                                fontFamily: 'Google',
                              ),
                            )),
                        SizedBox(
                          height: 10.0,
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 30.0, bottom: 10.0),
                  child: Text(
                    'Staff',
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    child: Column(
                      children: <Widget>[
                        if (listStaff.length > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0, top: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Set up for ${listStaff.length} staffs',
                                      style: TextStyle(
                                          fontFamily: 'Google',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .headline
                                              .fontSize),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          child: Text(
                                            'Full time',
                                            style: TextStyle(
                                                fontFamily: 'Sans',
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .fontSize,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .color),
                                          ),
                                        ),
                                        Text(
                                          '$fullTimeCount staff',
                                          style: TextStyle(
                                              fontFamily: 'Sans',
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .fontSize,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Divider(
                                      height: 0.0,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          child: Text(
                                            'Part time',
                                            style: TextStyle(
                                                fontFamily: 'Sans',
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .fontSize,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .color),
                                          ),
                                        ),
                                        Text(
                                          '$partTimeCount staff',
                                          style: TextStyle(
                                              fontFamily: 'Sans',
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .fontSize,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Divider(
                                      height: 0.0,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      'List staff',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Divider(
                                      height: 0.0,
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: listStaff.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: <Widget>[
                                        Material(
                                            color: listStaff[index].check
                                                ? MediaQuery.of(context)
                                                            .platformBrightness ==
                                                        Brightness.light
                                                    ? Colors.grey[50]
                                                    : Colors.grey[900]
                                                : Colors.transparent,
                                            child: ListTile(
                                              onTap: () {
                                                if (staffSelected) {
                                                  if (listStaff[index].check ==
                                                      true) {
                                                    setState(() {
                                                      listStaff[index].check =
                                                          false;
                                                      staffCountSelected--;
                                                      if (staffCountSelected ==
                                                          0) {
                                                        staffSelected = false;
                                                      }
                                                    });
                                                  } else {
                                                    setState(() {
                                                      listStaff[index].check =
                                                          true;
                                                      staffCountSelected++;
                                                    });
                                                  }
                                                } else {
                                                  for (int i = 0;
                                                      i < listPart.length;
                                                      i++) {
                                                    if (listPart[i].part ==
                                                        listStaff[index].part) {
                                                      setState(() {
                                                        listPart[i].check =
                                                            true;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        listPart[i].check =
                                                            false;
                                                      });
                                                    }
                                                  }
                                                  for (int j = 0;
                                                      j < listDateDayOff.length;
                                                      j++) {
                                                    if (listDateDayOff[j].date ==
                                                        listStaff[index]
                                                            .libur) {
                                                      setState(() {
                                                        listDateDayOff[j].check =
                                                            true;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        listDateDayOff[j].check =
                                                            false;
                                                      });
                                                    }
                                                  }

                                                  if(listStaff[index].overtime != null){
                                                    List<DateTime> temp = List<DateTime>();
                                                    for(int k = 0; k < listDateOvertime.length; k++){
                                                      temp.add(listDateOvertime[k].date);
                                                      setState(() {
                                                        listDateOvertime[k].check = false;
                                                      });
                                                    }
                                                    for(int l = 0; l < listStaff[index].overtime.length; l++){
                                                      if(temp.contains(listStaff[index].overtime[l])){
                                                        DateItem2 item = new DateItem2(true, listStaff[index].overtime[l]);
                                                        int position;
                                                        for(int m = 0; m < listDateOvertime.length; m++){
                                                          if(listDateOvertime[m].date == listStaff[index].overtime[l]){
                                                            position = m;
                                                          }
                                                        }
                                                        listDateOvertime[position] = item;
                                                      }
                                                    }
                                                  } else {
                                                    for(int k = 0; k < listDateOvertime.length; k++){
                                                      setState(() {
                                                        listDateOvertime[k].check = false;
                                                      });
                                                    }
                                                  }
                                                  _showSinglePostDialog(
                                                      listStaff[index].name,
                                                      index);
                                                }
                                              },
                                              onLongPress: () {
                                                setState(() {
                                                  listStaff[index].check = true;
                                                  staffSelected = true;
                                                  staffCountSelected++;
                                                  if (dateSelected) {
                                                    dateSelected = false;
                                                    dateCountSelected = 0;
                                                    for (int i = 0;
                                                        i < listDateTime.length;
                                                        i++) {
                                                      if (listDateTime[i]
                                                          .check) {
                                                        setState(() {
                                                          listDateTime[i]
                                                              .check = false;
                                                        });
                                                      }
                                                    }
                                                  }
                                                });
                                              },
                                              leading: ClipOval(
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                placeholder:
                                                    'assets/images/absenin.png',
                                                height: 50.0,
                                                width: 50.0,
                                                image: listStaff[index].img,
                                                fadeInDuration:
                                                    Duration(seconds: 1),
                                                fit: BoxFit.cover,
                                              )),
                                              title: Text(
                                                listStaff[index].name,
                                                style: TextStyle(
                                                    fontFamily: 'Google'),
                                              ),
                                              subtitle: Text(
                                                listStaff[index].part != ''
                                                    ? listStaff[index].part
                                                    : 'Part = not set',
                                                style: TextStyle(
                                                    fontFamily: 'Sans'),
                                              ),
                                              trailing: listStaff[index].check
                                                  ? Icon(
                                                      Icons.check_circle,
                                                      size: 18.0,
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.light
                                                          ? Colors.green
                                                          : Colors.green[400],
                                                    )
                                                  : null,
                                            )),
                                        if (index != listStaff.length - 1)
                                          Container(
                                            height: 0.5,
                                            margin: EdgeInsets.only(
                                                left: 80.0, right: 20.0),
                                            color:
                                                Theme.of(context).dividerColor,
                                          )
                                      ],
                                    );
                                  }),
                            ],
                          )
                        else
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                  top: 30.0,
                                  bottom: 30.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withAlpha(10)),
                                    child: Icon(Ionicons.ios_person_add,
                                        size: 46.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Text(
                                    "You can add staff that work by pressing the\nfloating button on the bottom right.",
                                    style: TextStyle(
                                        fontFamily: 'Sans',
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .fontSize,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              )),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                )
              ],
            ),
          ),
        ),
        onWillPop: () async {
          bool exit = false;
          if (staffSelected || dateSelected) {
            if (staffSelected) {
              setState(() {
                staffSelected = false;
              });
              for (int i = 0; i < listStaff.length; i++) {
                if (listStaff[i].check) {
                  setState(() {
                    listStaff[i].check = false;
                  });
                }
              }
            }
            if (dateSelected) {
              setState(() {
                dateSelected = false;
              });
              for (int i = 0; i < listDateTime.length; i++) {
                if (listDateTime[i].check) {
                  setState(() {
                    listDateTime[i].check = false;
                  });
                }
              }
            }
            dateCountSelected = 0;
            staffCountSelected = 0;
          } else {
            if (_canVibrate) {
              Vibrate.feedback(FeedbackType.warning);
            }
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
                                  left: 20.0,
                                  top: 30.0,
                                  right: 20.0,
                                  bottom: 30.0),
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
                                    'Do you want to save your changes or discard?',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                        fontFamily: 'Sans',
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .body1
                                            .fontSize),
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
                                  Navigator.pop(context, true);
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontFamily: 'Google',
                                      fontWeight: FontWeight.bold),
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
                                  Navigator.pop(context, false);
                                },
                                child: Text(
                                  'Discard',
                                  style: TextStyle(
                                      fontFamily: 'Google',
                                      fontWeight: FontWeight.bold,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Colors.black54
                                          : Colors.grey[400]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )));
          }
          return exit;
        });
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
