import 'dart:async';

import 'package:absenin/anim/FadeUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderPage extends StatefulWidget {

  final DateTime date, startTime, endTime;
  final String shift;
  final int action;

  const ReminderPage({Key key, @required this.action, @required this.date, @required this.startTime, @required this.endTime, @required this.shift}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ReminderPageState();
  }
}

class ReminderPageState extends State<ReminderPage> {
  
  bool _canVibrate = true;
  double width = 0;
  double height = 0;
  DateTime timeSet;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  DateFormat dateFormat = DateFormat.yMd();
  DateFormat hourFormat = DateFormat.Hm();
  DateFormat dateFullFormat = DateFormat.yMMMMEEEEd();

  @override
  void initState() {
    super.initState();
    timeSet = widget.date;
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _checkVibrate();
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        width = MediaQuery.of(context).size.width;
        height = MediaQuery.of(context).size.height * 0.4;
      });
    });
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  _checkVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  _setReminder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '1.0',
        'Absenin',
        'Reminder Notification',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        40,
        'Reminder For You',
        "You have schedule today! Don't forget to attend.",
        DateTime.now().add(Duration(seconds: 10)),
        platformChannelSpecifics);
    if (mounted) {
      prefs.setBool('isReminder', true);
      prefs.setString('dateReminder', dateFormat.format(timeSet));
      prefs.setString('timeReminder', hourFormat.format(timeSet));
      showCenterShortToast();
      Navigator.pop(context, true);
    }
  }

  void showCenterShortToast() {
    Fluttertoast.showToast(
      msg: timeSet.toString(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Reminder'
            ),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 50,),
                      FadeUp(
                        1.5,
                        TimePickerSpinner(
                          alignment: Alignment.center,
                          is24HourMode: false,
                          itemHeight: 70.0,
                          itemWidth: 60.0,
                          isForce2Digits: true,
                          time: widget.action == 20 ? widget.date : widget.startTime.subtract(Duration(hours: 1)),
                          normalTextStyle: TextStyle(
                              color: MediaQuery.of(context).platformBrightness ==
                                      Brightness.light
                                  ? Colors.black12
                                  : Colors.white24,
                              fontSize:
                                  Theme.of(context).textTheme.display2.fontSize,
                              fontWeight: FontWeight.w300),
                          highlightedTextStyle: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.display2.fontSize,
                              fontWeight: FontWeight.w300),
                          onTimeChange: (time) {
                            setState(() {
                              timeSet = time;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 50,),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: Theme.of(context).backgroundColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  dateFullFormat.format(widget.date),
                                  style: TextStyle(
                                    fontFamily: 'Google',
                                    fontSize: Theme.of(context).textTheme.title.fontSize - 2
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(
                                  Feather.target,
                                  color:
                                      MediaQuery.of(context).platformBrightness ==
                                              Brightness.light
                                          ? Colors.indigo[300]
                                          : Colors.indigoAccent[100],
                                ),
                                title: Text(
                                  widget.shift,
                                  style: TextStyle(
                                    fontFamily: 'Google',
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .subhead
                                        .fontSize,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 70),
                                width: double.infinity,
                                height: 0.5,
                                color: Theme.of(context).dividerColor,
                              ),
                              ListTile(
                                leading: Icon(
                                  Feather.clock,
                                  color:
                                      MediaQuery.of(context).platformBrightness ==
                                              Brightness.light
                                          ? Colors.indigo[300]
                                          : Colors.indigoAccent[100],
                                ),
                                title: Row(
                                  children: <Widget>[
                                    Text(
                                      hourFormat.format(widget.startTime) + ' AM',
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .fontSize,
                                      ),
                                    ),
                                    for (int i =  0; i < 3; i++)
                                    Row(
                                      children: <
                                          Widget>[
                                        if (i == 0)
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                        Container(
                                          width:
                                              3.5,
                                          height:
                                              3.5,
                                          decoration:
                                              BoxDecoration(color: Theme.of(context).textTheme.caption.color, shape: BoxShape.circle),
                                        ),
                                        if (i <
                                            3)
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                      ],
                                    ),
                                    Text(
                                      hourFormat.format(widget.endTime) + ' PM',
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .fontSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 55.0,
                    child: FlatButton(
                      onPressed: () {
                        _setReminder();
                        // Navigator.pop(context, true);
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold),
                      ),
                      color: Theme.of(context).buttonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0)),
                      splashColor: Colors.black26,
                      highlightColor: Colors.black26,
                    ),
                  )
                )
              ],
            ),
          )
        ),
        onWillPop: _onBackPressed
      );
  }

  Future<bool> _onBackPressed() {
    if (_canVibrate) {
      Vibrate.feedback(FeedbackType.warning);
    }
    return showDialog(
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
                                'Attendance Reminder',
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
                ))) ??
        false;
  }
}
