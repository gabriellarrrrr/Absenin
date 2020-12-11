import 'dart:async';
import 'package:absenin/anim/FadeUp.dart';
import 'package:absenin/login.dart';
import 'package:absenin/user/history.dart';
import 'package:absenin/user/map.dart';
import 'package:absenin/user/permission.dart';
import 'package:absenin/user/profile.dart';
import 'package:absenin/user/reminder.dart';
import 'package:absenin/user/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:content_placeholder/content_placeholder.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_vant_kit/widgets/steps.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class OverviewSchedule {
  final DateTime date, startTime, endTime, switchDate;
  final String shift, pos;
  final int lateTime, type;
  DateTime clockinTime, breakTime, afterbreakTime, overtimeinTime;
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
      this.overtimeinTime);
}

class StaffItem {
  String id;
  String img;
  String name;
  String position;
  int type;
  String phone;
  String address;
  String email;
  String outlet;
  bool check;
  String enrol;
  bool clicked;

  StaffItem(
      this.id,
      this.img,
      this.name,
      this.position,
      this.type,
      this.check,
      this.phone,
      this.address,
      this.email,
      this.outlet,
      this.enrol,
      this.clicked);
}

class HomePageState extends State<HomePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<OverviewSchedule> listSchedule = new List<OverviewSchedule>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final PanelController _panelController = new PanelController();
  final searchController = TextEditingController();
  double _radiusPanel = 0.0;
  bool collaps = true;
  double minHeight = 0;
  String searchQuery;
  // int _active = -1;
  // bool isClockin = false;
  bool isClockOut = false;
  bool isNoClockOut = false;
  bool _canVibrate = true;
  bool isReminder = false;
  String dateReminder;
  String timeReminder;
  String appName;
  String packageName;
  String version;
  String buildNumber;
  String deviceModel;
  String deviceBrand;
  String deviceId;
  int indexList;
  String id = '',
      name = '',
      img = '',
      position = '',
      outlet = '',
      phone = '',
      email = '',
      address = '',
      passcode = '';
  int type = 0, role = 0;
  String query = '';
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateFormat timeFormat = DateFormat.Hm();

  List listJadwal = ['Shift 1', 'Shift 2', 'Lembur', 'Jaga Malam'];
  List<StaffItem> listStaff = new List<StaffItem>();
  List listTampung = new List();
  String monthNow;

  final Firestore firestore = Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void saveSwitchData(int index) async {
    await firestore
      .collection('switchschedule')
      .document('Dazzle Gejayan')
      .collection('listswitch')
      .add({
      'datefrom': listSchedule[indexList].date,
      'shiftfrom': listSchedule[indexList].shift,
      'from': id,
      'dateto': DateTime.now(),
      'shiftto': '-',
      'to': listStaff[index].id,
      'toAcc' : false,
      'status': 0,
      'checked': DateTime.now(),
      'posFrom': listSchedule[indexList].pos,
      'posTo' : '-'
    }).then((data) async {
      await firestore
        .collection('user')
        .document('Dazzle Gejayan')
        .collection('listuser')
        .document(listStaff[index].id)
        .collection('${DateTime.now().year}')
        .document('request')
        .setData({
          'switch' : true,
          'from' : id,
          'shift' : listSchedule[indexList].shift,
          'date' : listSchedule[indexList].date,
          'id' : data.documentID
        });
      if(mounted){
        await firestore
          .collection('schedule')
          .document('Dazzle Gejayan')
          .collection('scheduledetail')
          .document('${listSchedule[indexList].date.year}')
          .collection('${listSchedule[indexList].date.month}')
          .document('${listSchedule[indexList].shift}')
          .collection('listday')
          .document('${listSchedule[indexList].date.day}')
          .collection('liststaff')
          .document(id)
          .updateData({'switch': true});
        if (mounted) {
          setState(() {
            listSchedule[indexList].isSwitch = true;
            listStaff[index].check = true;
            listStaff[index].clicked = false;
            if (collaps) {
              _panelController.open();
              setState(() {
                collaps = false;
              });
            } else {
              _panelController.close();
              setState(() {
                collaps = true;
              });
            }
          });
        }
      }
    });
  }

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser currentUser = await auth.currentUser();
    outlet = prefs.getString('outletUser');
    firestore
        .collection('user')
        .document(outlet)
        .collection('listuser')
        .where('email', isEqualTo: currentUser.email)
        .snapshots()
        .listen((data) {
      if (data.documents.isNotEmpty) {
        data.documents.forEach((f) {
          setState(() {
            id = f.documentID;
            name = f.data['name'];
            position = f.data['position'];
            img = f.data['img'];
            phone = f.data['phone'];
            email = f.data['email'];
            address = f.data['address'];
            type = f.data['type'];
            role = f.data['role'];
            passcode = f.data['passcode'];
            prefs.setString('idUser', id);
            prefs.setString('namaUser', name);
            prefs.setString('positionUser', position);
            prefs.setString('imgUser', img);
            prefs.setString('phoneUser', phone);
            prefs.setString('emailUser', email);
            prefs.setString('addressUser', address);
            prefs.setInt('typeUser', type);
            prefs.setInt('roleUser', role);
            prefs.setString('passcodeUser', passcode);
            getListSchedule();
            getOutlet();
            getSwitchRequest(id);
          });
        });
      }
    });
  }

  void getSwitchRequest(String id) async {
    await firestore
        .collection('user')
        .document(outlet)
        .collection('listuser')
        .document(id)
        .collection('${DateTime.now().year}')
        .document('request')
        .get()
        .then((snapshot) async {
          if(snapshot.exists){
            if(snapshot.data['switch']){
              Timestamp date = snapshot.data['date'];
              await firestore
                .collection('user')
                .document(outlet)
                .collection('listuser')
                .document(snapshot.data['from'])
                .get()
                .then((value){
                  if(value.exists){
                    _showSwitchRequestDialog(value.data['name'], date.toDate(), snapshot.data['id']);
                  }
                });
            }
          }
        });
  }

  void getOutlet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firestore
        .collection('outlet')
        .where('name', isEqualTo: outlet)
        .snapshots()
        .listen((data) {
      if (data.documents.isNotEmpty) {
        data.documents.forEach((f) {
          prefs.setDouble('latitude', f.data['latitude']);
          prefs.setDouble('longtitude', f.data['longtitude']);
        });
      }
    });
  }

  Future<void> getListSchedule() async {
    DateTime dateTime = DateTime.now();
    for (int i = 0; i < 2; i++) {
      await firestore
          .collection('schedule')
          .document(outlet)
          .collection('scheduledetail')
          .document('${dateTime.year}')
          .collection('${dateTime.month}')
          .document('Shift 1')
          .collection('listday')
          .document('${dateTime.day + i}')
          .collection('liststaff')
          .document(id)
          .get()
          .then((snapshoot) async {
        if (snapshoot.exists) {
          Timestamp switchDate = snapshoot.data['switchDate'];
          Timestamp clockinTime = snapshoot.data['clockin'];
          Timestamp breakTime = snapshoot.data['break'];
          Timestamp afterbreakTime = snapshoot.data['afterbreak'];
          Timestamp overtimeinTime = snapshoot.data['overtimein'];
          bool isClockIn = snapshoot.data['isClockIn'];
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
          if (isOverTimeIn){
            active = 4;
          }
          if (isOverTimeOut) {
            active = 5;
          }

          await firestore
              .collection('schedule')
              .document(outlet)
              .collection('scheduledetail')
              .document('${dateTime.year}')
              .collection('${dateTime.month}')
              .document('Shift 1')
              .collection('listday')
              .document('${dateTime.day + i}')
              .get()
              .then((snapshoots) {
            if (snapshoots.exists) {
              bool isOff = false;
              Timestamp start, end;
              if (type == 1) {
                start = snapshoots.data['fullstart'];
                end = snapshoots.data['fullend'];
              } else {
                start = snapshoots.data['partstart'];
                end = snapshoots.data['partend'];
              }
              OverviewSchedule item = new OverviewSchedule(
                Jiffy().add(days: i),
                start.toDate(),
                end.toDate(),
                'Shift 1',
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
                overtimeinTime.toDate());
              setState(() {
                listSchedule.add(item);
                if(i == 0){
                  if(!isClockIn && !isPermit && isSwitchAcc != 1 && !isOff){
                    _setClockInNotifMin15(start.toDate());
                  }
                }
              });
            } else {
              print('Details empty!');
            }
          });
        } else {
          await firestore
              .collection('schedule')
              .document(outlet)
              .collection('scheduledetail')
              .document('${dateTime.year}')
              .collection('${dateTime.month}')
              .document('Shift 2')
              .collection('listday')
              .document('${dateTime.day + i}')
              .collection('liststaff')
              .document(id)
              .get()
              .then((snapshoot) async {
            if (snapshoot.exists) {
              Timestamp switchDate = snapshoot.data['switchDate'];
              Timestamp clockinTime = snapshoot.data['clockin'];
              Timestamp breakTime = snapshoot.data['break'];
              Timestamp afterbreakTime = snapshoot.data['afterbreak'];
              Timestamp overtimeinTime = snapshoot.data['overtimein'];
              bool isClockIn = snapshoot.data['isClockIn'];
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
              if (isOverTimeIn){
                active = 4;
              }
              if (isOverTimeOut) {
                active = 5;
              }

              await firestore
                  .collection('schedule')
                  .document(outlet)
                  .collection('scheduledetail')
                  .document('${dateTime.year}')
                  .collection('${dateTime.month}')
                  .document('Shift 2')
                  .collection('listday')
                  .document('${dateTime.day + i}')
                  .get()
                  .then((snapshoots) {
                if (snapshoots.exists) {
                  bool isOff = false;
                  Timestamp start, end;
                  if (type == 1) {
                    start = snapshoots.data['fullstart'];
                    end = snapshoots.data['fullend'];
                  } else {
                    start = snapshoots.data['partstart'];
                    end = snapshoots.data['partend'];
                  }
                  OverviewSchedule item = new OverviewSchedule(
                      Jiffy().add(days: i),
                      start.toDate(),
                      end.toDate(),
                      'Shift 2',
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
                      overtimeinTime.toDate());
                  setState(() {
                    listSchedule.add(item);
                    if(i == 0){
                      if(!isClockIn && !isPermit && isSwitchAcc != 1 && !isOff){
                        _setClockInNotifMin15(start.toDate());
                      }
                    }
                  });
                } else {
                  print('Details empty!');
                }
              });
            } else {
              print('No Schedule For You!');
              OverviewSchedule item = new OverviewSchedule(
                  Jiffy().add(days: i),
                  DateTime.now(),
                  DateTime.now(),
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
                  DateTime.now(),
                  -1,
                  DateTime.now(),
                  DateTime.now(),
                  DateTime.now(),
                  DateTime.now());
              setState(() {
                listSchedule.add(item);
              });
            }
          });
        }
      });
    }
    if (!listSchedule[1].isPermit || !listSchedule[1].isSwitch) {
      getStaff();
    }
  }

  void getStaff() async {
    firestore
        .collection('user')
        .document(outlet)
        .collection('listuser')
        .where('outlet', isEqualTo: outlet)
        .where('role', isEqualTo: 1)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        if (f.documentID != id) {
          StaffItem item = new StaffItem(
              f.documentID,
              f.data['img'],
              f.data['name'],
              f.data['position'],
              f.data['type'],
              false,
              f.data['phone'],
              f.data['address'],
              f.data['email'],
              f.data['outlet'],
              f.data['enrol'],
              false);
          setState(() {
            listStaff.add(item);
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    getUser();
    _checkVibrate();
    _getAppInfo();
    _getDeviceInfo();
  }

  _setClockInNotifMin15(DateTime dateTime) async {
    DateTime date = Jiffy(dateTime).subtract(minutes: 15);
    var time = Time(date.hour, date.minute, date.second);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '10',
        'Clock In 15',
        '15 Minutes',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        10,
        'Clock In Time',
        "Hi $name, 15 minutes again time to clock in!",
        time,
        platformChannelSpecifics);
  }

  _setAfterBreak15(DateTime dateTime) async {
    DateTime date = Jiffy(dateTime).subtract(minutes: 15);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '20',
        'After Break 15',
        '15 Minutes',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        20,
        'After Break Time',
        "Hi $name, 15 minutes again time to after break!",
        date,
        platformChannelSpecifics);
  }

  _setClockOut15(DateTime dateTime) async {
    DateTime date = Jiffy(dateTime).subtract(minutes: 15);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '30',
        'Clock Out 15',
        '15 Minutes',
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        30,
        'Clock Out Time',
        "Hi $name, 15 minutes again time to clock out!",
        date,
        platformChannelSpecifics);
  }

  void _stepCounter(int index) {
    setState(() {
      listSchedule[index]._active++;
      if (listSchedule[index]._active == 3 && !listSchedule[index].isOverTime ||
          listSchedule[index]._active == 5 && listSchedule[index].isOverTime) {
        Timer(Duration(milliseconds: 300), () {
          _showAlertDialog('Hi, $name', 'Your work finished, Thank you.', 10, index);
        });
      }
      if(listSchedule[index]._active == 2){
        _setClockOut15(listSchedule[index].endTime);
      }
    });
  }

  _checkTimeNow(int index, String shift, int action) async {
    DateTime dateTime = DateTime.now();
    DateFormat year = DateFormat.y();
    DateFormat month = DateFormat.M();
    DateFormat day = DateFormat.d();
    DateFormat hourFormat = DateFormat.H();
    if (action == 10) {
      DateTime longBreak = Jiffy(dateTime).add(minutes: 60);
      _prosesDialog();
      await firestore
          .collection('schedule')
          .document('Dazzle Gejayan')
          .collection('scheduledetail')
          .document(year.format(dateTime))
          .collection(month.format(dateTime))
          .document(shift)
          .collection('listday')
          .document(day.format(dateTime))
          .collection('liststaff')
          .document(id)
          .updateData({
        'break': DateTime.now(),
        'isBreak': true,
      });
      if (mounted) {
        Navigator.pop(context);
        listSchedule[index].breakTime = DateTime.now();
        listSchedule[index].isBreak = true;
        _stepCounter(index);
        _setAfterBreak15(longBreak);
      }
    } else if (action == 20) {
      int hourNow = int.tryParse(hourFormat.format(dateTime));
      if (hourNow >= 16) {
        _prosesDialog();
        await firestore
            .collection('schedule')
            .document('Dazzle Gejayan')
            .collection('scheduledetail')
            .document(year.format(dateTime))
            .collection(month.format(dateTime))
            .document(shift)
            .collection('listday')
            .document(day.format(dateTime))
            .collection('liststaff')
            .document(id)
            .updateData({
          'clockout': DateTime.now(),
          'isClockOut': true,
        });
        if (mounted) {
          listSchedule[index].isClockOut = true;
          if(!listSchedule[index].isOverTime){
            await firestore.collection('history')
              .document('Dazzle Gejayan')
              .collection('listhistory')
              .document('${DateTime.now().year}')
              .collection(id)
              .document('${DateTime.now().month}')
              .collection('listhistory')
              .add({
                'date' : listSchedule[index].date,
                'shift' : listSchedule[index].shift,
                'start' : listSchedule[index].startTime,
                'end' : listSchedule[index].endTime,
                'late' : listSchedule[index].lateTime,
                'pos' : listSchedule[index].pos
              });
            if(mounted){
              Navigator.pop(context);
              setState(() {
                listSchedule[index].isClockOut = true;
                _stepCounter(index);
              });
            }
            int dayintotaltime = DateTime.now().difference(listSchedule[index].clockinTime).inMinutes;
            int breaktotaltime = listSchedule[index].afterbreakTime.difference(listSchedule[index].breakTime).inMinutes;
            int lateday = 0;
            if(listSchedule[index].lateTime > 0){
              lateday = 1;
            }
            await firestore
              .collection('report')
              .document('Dazzle Gejayan')
              .collection('listreport')
              .document('${DateTime.now().year}')
              .collection('${DateTime.now().month}')
              .document(id)
              .collection('listreport')
              .add({
                'name' : name,
                'dayin' : 1,
                'dayintotaltime' : dayintotaltime,
                'totalbreaktime' : breaktotaltime,
                'overtimeday' : 0,
                'overtimetotaltime' : 0,
                'lateday' : lateday,
                'latetotaltime' : listSchedule[index].lateTime, 
                'date' : listSchedule[index].date
              });
          } else {
            Navigator.pop(context);
            setState(() {
              listSchedule[index].isClockOut = true;
              _stepCounter(index);
            });
          }
        }
      } else {
        _showAlertDialog(
            'Attention', "You can't clockout now! clockout start at 16:00 PM", 10, index);
        if (_canVibrate) {
          Vibrate.feedback(FeedbackType.warning);
        }
      }
    } else if (action == 30) {
      _prosesDialog();
      await firestore
          .collection('schedule')
          .document('Dazzle Gejayan')
          .collection('scheduledetail')
          .document(year.format(dateTime))
          .collection(month.format(dateTime))
          .document(shift)
          .collection('listday')
          .document(day.format(dateTime))
          .collection('liststaff')
          .document(id)
          .updateData({
        'overtimeout': DateTime.now(),
        'isOvertimeOut': true,
      });
      if (mounted) {
        listSchedule[index].isOverTimeOut = true;
        await firestore.collection('history')
          .document('Dazzle Gejayan')
          .collection('listhistory')
          .document('${DateTime.now().year}')
          .collection(id)
          .document('${DateTime.now().month}')
          .collection('listhistory')
          .add({
            'date' : listSchedule[index].date,
            'shift' : listSchedule[index].shift,
            'start' : listSchedule[index].startTime,
            'end' : listSchedule[index].endTime,
            'late' : listSchedule[index].lateTime,
            'pos' : listSchedule[index].pos
          });
        if(mounted){
          Navigator.pop(context);
          setState(() {
            listSchedule[index].isOverTimeOut = true;
            _stepCounter(index);
          });
        }
        int dayintotaltime = DateTime.now().difference(listSchedule[index].clockinTime).inMinutes;
        int breaktotaltime = listSchedule[index].afterbreakTime.difference(listSchedule[index].breakTime).inMinutes;
        int lateday = 0;
        if(listSchedule[index].lateTime > 0){
          lateday = 1;
        }
        int overtimetotaltime = DateTime.now().difference(listSchedule[index].overtimeinTime).inMinutes;
        await firestore
          .collection('report')
          .document('Dazzle Gejayan')
          .collection('listreport')
          .document('${DateTime.now().year}')
          .collection('${DateTime.now().month}')
          .document(id)
          .collection('listreport')
          .add({
            'name' : name,
            'dayin' : 1,
            'dayintotaltime' : dayintotaltime,
            'totalbreaktime' : breaktotaltime,
            'overtimeday' : 1,
            'overtimetotaltime' : overtimetotaltime,
            'lateday' : lateday,
            'latetotaltime' : listSchedule[index].lateTime, 
            'date' : listSchedule[index].date
          });
      }
    }
  }

  _checkVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  _getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  _getDeviceInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      deviceModel = androidInfo.model;
      deviceBrand = androidInfo.brand;
      deviceId = androidInfo.id;
    });
  }

  void _showReminderDialog(DateTime date, DateTime startTime, DateTime endTime, String shift) {
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
                            'Reminder enable',
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption.color,
                                fontFamily: 'Sans',
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .fontSize),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            timeReminder,
                            style: TextStyle(
                                fontFamily: 'Sans',
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .display1
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
                          _gotoReminderPage(20, date, startTime, endTime, shift);
                        },
                        child: Text(
                          'Edit Reminder',
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
                          setState(() async {
                            isReminder = false;
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setBool('isReminder', false);
                            prefs.setString('dateReminder', '-');
                            prefs.setString('timeReminder', '-');
                          });
                        },
                        child: Text(
                          'Disable',
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

  void _showAppInfoDialog() {
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
                            'Absenin v.$version',
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
                            '$packageName',
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

  void _showDeviceInfoDialog() {
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
                            '$deviceModel',
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
                            'Brand: $deviceBrand\nId: $deviceId',
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

  void _showSwitchRequestDialog(String name, DateTime date, String id) {
    showDialog(
        context: context,
        barrierDismissible: false,
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
                          left: 20, top: 20, right: 20, bottom: 15),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'You have switch request',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Google',
                              fontSize:
                                  Theme.of(context).textTheme.subhead.fontSize),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      'assets/images/switch1.png',
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '$name request switch schedule on ${dateFormat.format(date)}',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.caption.color,
                              fontFamily: 'Sans',
                              fontSize:
                                  Theme.of(context).textTheme.body1.fontSize),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
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
                          Navigator.of(context).push(_createRoute(ScheduleTime(action: 20, id: id,)));
                        },
                        child: Text(
                          'Choose schedule',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontFamily: 'Google',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }

  void _showAlertDialog(String title, String message, int action, int index) {
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
                            '$title',
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
                            '$message',
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
                    if(action == 20)
                    Divider(
                      height: 0.0,
                    ),
                    if(action == 20)
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _checkTimeNow(
                            index,
                            listSchedule[index].shift,
                            10);
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(
                              fontFamily: 'Google',
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).accentColor),
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
                          action == 10 ? 'Close' : 'No',
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

  _gotoMapsPage(int _action, String shift, int index, DateTime timeSet) async {
    final result = await Navigator.of(context).push(_createRoute(MapPage(
      action: _action,
      id: id,
      name: name,
      outlet: outlet,
      img: img,
      shift: shift,
      timeSet: timeSet,
    )));
    if (result != null && result != false) {
      setState(() {
        if (_action == 10) {
          listSchedule[index].isClockIn = true;
          listSchedule[index].clockinTime = DateTime.now();
        } else if(_action == 20){
          listSchedule[index].isAfterBreak = true;
          listSchedule[index].afterbreakTime = DateTime.now();
        } else {
          listSchedule[index].isOverTimeIn = true;
          listSchedule[index].overtimeinTime = DateTime.now();
        }
        _stepCounter(index);
      });
    }
  }

  _gotoReminderPage(int action, DateTime date, DateTime startTime, DateTime endTime, String shift) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result =
        await Navigator.of(context).push(_createRoute(ReminderPage(action: action, date: date, startTime: startTime, endTime: endTime, shift: shift,)));
    if (result != null && result != false) {
      setState(() {
        isReminder = prefs.getBool('isReminder');
        dateReminder = prefs.getString('dateReminder');
        timeReminder = prefs.getString('timeReminder');
      });
    }
  }

  _getReminderSet(int index) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isReminder = prefs.getBool('isReminder');
    dateReminder = prefs.getString('dateReminder');
    timeReminder = prefs.getString('timeReminder');
    if (isReminder != null && isReminder) {
      DateTime date = DateFormat('yMd').parse(dateReminder);
      DateTime time = DateFormat('H:m').parse(timeReminder);
      DateTime finalTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      print(date.toString());
      print(time.toString());
      print(finalTime.toString());
      _showReminderDialog(finalTime, listSchedule[index].startTime, listSchedule[index].endTime, listSchedule[index].shift);
    } else {
      _gotoReminderPage(10, listSchedule[index].date, listSchedule[index].startTime, listSchedule[index].endTime, listSchedule[index].shift);
    }
  }

  _signOutFromAuth() async {
    if (auth.currentUser() != null) {
      await auth.signOut();
      if (mounted) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(_createRoute(SignIn()));
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
            key: _scaffoldKey,
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Feather.menu),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  }),
              title: Text('Absenin'),
            ),
            drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 10.0, right: 10.0),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/images/absenin.png',
                            width: 40.0,
                            filterQuality: FilterQuality.medium,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            'Absenin',
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .fontSize,
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                  Divider(
                    height: 0.0,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(_createRoute(ProfileUser()));
                    },
                    leading: Icon(
                      Ionicons.md_person,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Profile',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      ),
                    ),
                    subtitle: Text(
                      'View and update your profile',
                      style: TextStyle(
                        fontFamily: 'Sans',
                      ),
                    ),
                    trailing: Icon(
                      Feather.chevron_right,
                      size: 15.0,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context)
                          .push(_createRoute(ListPermission()));
                    },
                    leading: Icon(
                      MaterialIcons.note,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Permissions',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      ),
                    ),
                    subtitle: Text(
                      'Make new permissions',
                      style: TextStyle(
                        fontFamily: 'Sans',
                      ),
                    ),
                    trailing: Icon(
                      Feather.chevron_right,
                      size: 15.0,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(_createRoute(ScheduleTime(action: 10,)));
                    },
                    leading: Icon(
                      Ionicons.md_calendar,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Schedule',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      ),
                    ),
                    subtitle: Text(
                      'Your schedule is here',
                      style: TextStyle(
                        fontFamily: 'Sans',
                      ),
                    ),
                    trailing: Icon(
                      Feather.chevron_right,
                      size: 15.0,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(_createRoute(History()));
                    },
                    leading: Icon(
                      FontAwesome.history,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'History',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      ),
                    ),
                    subtitle: Text(
                      'Your history is here',
                      style: TextStyle(
                        fontFamily: 'Sans',
                      ),
                    ),
                    trailing: Icon(
                      Feather.chevron_right,
                      size: 15.0,
                    ),
                  ),
                  Divider(
                    height: 0.0,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _prosesDialog();
                      _signOutFromAuth();
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (BuildContext context) => Help()));
                    },
                    leading: Icon(
                      MaterialIcons.help,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Help',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      ),
                    ),
                    subtitle: Text(
                      'Get information',
                      style: TextStyle(
                        fontFamily: 'Sans',
                      ),
                    ),
                    trailing: Icon(
                      Feather.chevron_right,
                      size: 15.0,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showDeviceInfoDialog();
                    },
                    leading: Icon(
                      Ionicons.ios_phone_portrait,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Device Info',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      ),
                    ),
                    subtitle: Text(
                      deviceModel != null ? deviceModel : 'Checking...',
                      style: TextStyle(
                        fontFamily: 'Sans',
                      ),
                    ),
                    trailing: Icon(
                      Feather.chevron_right,
                      size: 15.0,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showAppInfoDialog();
                    },
                    leading: Icon(
                      MaterialIcons.info,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'About Apps',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      ),
                    ),
                    subtitle: Text(
                      version != null ? 'Version $version' : 'Version...',
                      style: TextStyle(
                        fontFamily: 'Sans',
                      ),
                    ),
                    trailing: Icon(
                      Feather.chevron_right,
                      size: 15.0,
                    ),
                  ),
                ],
              ),
            ),
            body: SlidingUpPanel(
              minHeight: minHeight,
              maxHeight: MediaQuery.of(context).size.height,
              backdropEnabled: true,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(_radiusPanel)),
              parallaxEnabled: true,
              parallaxOffset: 0.5,
              color: Theme.of(context).backgroundColor,
              isDraggable: true,
              controller: _panelController,
              onPanelClosed: () {
                setState(() {
                  collaps = true;
                  FocusScope.of(context).requestFocus(new FocusNode());
                  searchController.text = '';
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
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Switch your shift with',
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .subhead
                                        .fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Google',
                                    color: Theme.of(context)
                                        .appBarTheme
                                        .textTheme
                                        .title
                                        .color),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              SizedBox(
                                height: 50.0,
                                child: TextFormField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    print(value);
                                    setState(() {
                                      query = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        MaterialIcons.search,
                                        size: 20.0,
                                      ),
                                      hintText: 'Search',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      counter: Offstage(),
                                      contentPadding:
                                          EdgeInsets.only(right: 20.0)),
                                  keyboardType: TextInputType.text,
                                  maxLength: 30,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .fontSize,
                                      fontFamily: 'Sans'),
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 0.0,
                        ),
                        for (int index = 0; index < listStaff.length; index++)
                          if (listStaff[index]
                              .name
                              .toLowerCase()
                              .contains(query))
                            ListTile(
                              onTap: null,
                              leading: Container(
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                      color: Colors.orange[400],
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(
                                      '${listStaff[index].name.substring(0, 1)}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontFamily: 'Google',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                              title: Text(
                                listStaff[index].name,
                                style: TextStyle(fontFamily: 'Sans'),
                              ),
                              trailing: SizedBox(
                                width: 75.0,
                                height: 32.0,
                                child: FlatButton(
                                  onPressed: listStaff[index].check
                                      ? () {}
                                      : !listStaff[index].clicked ? () {
                                          setState(() {
                                            listStaff[index].clicked = true;
                                          });
                                          saveSwitchData(index);
                                        } : (){},
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      if (listStaff[index].clicked)
                                        SizedBox(
                                            width: 15.0,
                                            height: 15.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ))
                                      else
                                        Text(
                                          listStaff[index].check
                                              ? 'Sent'
                                              : 'Switch',
                                          style: TextStyle(
                                              color: listStaff[index].check
                                                  ? Theme.of(context)
                                                      .disabledColor
                                                  : Colors.white,
                                              fontFamily: 'Sans',
                                              fontWeight: FontWeight.bold,
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .body1
                                                  .fontSize),
                                        ),
                                    ],
                                  ),
                                  color: listStaff[index].check
                                      ? Theme.of(context).backgroundColor
                                      : Theme.of(context).buttonColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      side: BorderSide(
                                        color: listStaff[index].check
                                            ? Theme.of(context).disabledColor
                                            : Colors.transparent,
                                      )),
                                ),
                              ),
                            ),
                      ],
                    ));
              },
              body: SingleChildScrollView(
                  child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      FadeUp(
                        1.0,
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.28,
                          padding: EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 30.0, bottom: 50.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).dividerColor.withAlpha(10)),
                                child: ClipOval(
                                    child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/images/absenin_icon.png',
                                  height: 65.0,
                                  width: 65.0,
                                  image: img,
                                  fadeInDuration: Duration(seconds: 1),
                                  fit: BoxFit.cover,
                                )),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Container(
                                height: 65.0,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .textTheme
                                                  .title
                                                  .fontSize,
                                              fontFamily: 'Google'),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(position,
                                          style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .fontSize,
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.orange[800]
                                                : Colors.orange[300],
                                          )),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15,
                          ),
                          if (listSchedule.length > 1)
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: listSchedule.length,
                                itemBuilder: (context, index) {
                                  return listSchedule[index].isOff
                                      ? Container(
                                          margin: index == 0
                                              ? EdgeInsets.only(
                                                  left: 20.0,
                                                  right: 20.0,
                                                  top: 5.0,
                                                  bottom: 10.0)
                                              : EdgeInsets.only(
                                                  left: 20.0,
                                                  right: 20.0,
                                                  top: 20.0,
                                                  bottom: 20.0),
                                          padding: EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 8.0,
                                                    color: MediaQuery.of(
                                                                    context)
                                                                .platformBrightness ==
                                                            Brightness.light
                                                        ? Colors.black12
                                                        : Colors.transparent,
                                                    offset: Offset(0.0, 3.0))
                                              ]),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Icon(Ionicons.md_calendar,
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.light
                                                          ? Colors.red[400]
                                                          : Colors.red[300]),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    dateFormat.format(
                                                        listSchedule[index]
                                                            .date),
                                                    style: TextStyle(
                                                        fontSize:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .subhead
                                                                .fontSize,
                                                        fontFamily: 'Sans',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: MediaQuery.of(
                                                                        context)
                                                                    .platformBrightness ==
                                                                Brightness
                                                                    .light
                                                            ? Colors.red[900]
                                                            : Colors
                                                                .red[400]),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              Image.asset(
                                                'assets/images/cinemas.png',
                                                height: 180,
                                              ),
                                              SizedBox(
                                                height: 25.0,
                                              ),
                                              Text(
                                                'Enjoy your free day!',
                                                style: TextStyle(
                                                    fontSize:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .title
                                                            .fontSize,
                                                    fontFamily: 'Google',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                            ],
                                          ),
                                        )
                                      : listSchedule[index].isPermit
                                          ? Container(
                                              margin: index == 0
                                                  ? EdgeInsets.only(
                                                      left: 20.0,
                                                      right: 20.0,
                                                      top: 5.0,
                                                      bottom: 10.0)
                                                  : EdgeInsets.only(
                                                      left: 20.0,
                                                      right: 20.0,
                                                      top: 20.0,
                                                      bottom: 20.0),
                                              padding: EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        blurRadius: 8.0,
                                                        color: MediaQuery.of(
                                                                        context)
                                                                    .platformBrightness ==
                                                                Brightness
                                                                    .light
                                                            ? Colors.black12
                                                            : Colors
                                                                .transparent,
                                                        offset:
                                                            Offset(0.0, 3.0))
                                                  ]),
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Icon(
                                                          Ionicons
                                                              .md_calendar,
                                                          color: MediaQuery.of(
                                                                          context)
                                                                      .platformBrightness ==
                                                                  Brightness
                                                                      .light
                                                              ? Colors
                                                                  .indigo[400]
                                                              : Colors.indigo[
                                                                  300]),
                                                      SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                          dateFormat.format(
                                                              listSchedule[
                                                                      index]
                                                                  .date),
                                                          style: TextStyle(
                                                            fontSize: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .subhead
                                                                .fontSize,
                                                            fontFamily:
                                                                'Sans',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                          )),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 20.0,
                                                  ),
                                                  Image.asset(
                                                    'assets/images/permit.png',
                                                    height: 180,
                                                  ),
                                                  SizedBox(
                                                    height: 25.0,
                                                  ),
                                                  Text(
                                                    'You have permitted!',
                                                    style: TextStyle(
                                                        fontSize:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .title
                                                                .fontSize,
                                                        fontFamily: 'Google',
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 10.0,
                                                  ),
                                                ],
                                              ),
                                            )
                                          : listSchedule[index].isSwitchAcc == 1
                                              ? Container(
                                                  margin: index == 0
                                                      ? EdgeInsets.only(
                                                          left: 20.0,
                                                          right: 20.0,
                                                          top: 5.0,
                                                          bottom: 10.0)
                                                      : EdgeInsets.only(
                                                          left: 20.0,
                                                          right: 20.0,
                                                          top: 20.0,
                                                          bottom: 20.0),
                                                  padding:
                                                      EdgeInsets.all(16.0),
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .backgroundColor,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(10.0),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 8.0,
                                                            color: MediaQuery.of(
                                                                            context)
                                                                        .platformBrightness ==
                                                                    Brightness
                                                                        .light
                                                                ? Colors
                                                                    .black12
                                                                : Colors
                                                                    .transparent,
                                                            offset: Offset(
                                                                0.0, 3.0))
                                                      ]),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Icon(
                                                              Ionicons
                                                                  .md_calendar,
                                                              color: MediaQuery.of(context)
                                                                          .platformBrightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? Colors.indigo[
                                                                      400]
                                                                  : Colors.indigo[
                                                                      300]),
                                                          SizedBox(
                                                            width: 10.0,
                                                          ),
                                                          Text(
                                                              dateFormat.format(
                                                                  listSchedule[
                                                                          index]
                                                                      .date),
                                                              style:
                                                                  TextStyle(
                                                                fontSize: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .subhead
                                                                    .fontSize,
                                                                fontFamily:
                                                                    'Sans',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              )),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      Image.asset(
                                                        'assets/images/switch1.png',
                                                        height: 180,
                                                      ),
                                                      SizedBox(
                                                        height: 25.0,
                                                      ),
                                                      Text(
                                                        'You have Switched!',
                                                        style: TextStyle(
                                                            fontSize: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .title
                                                                .fontSize,
                                                            fontFamily:
                                                                'Google',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 3.0,
                                                      ),
                                                      Text(
                                                        '${dateFormat.format(listSchedule[index].switchDate)}',
                                                          style: TextStyle(
                                                              fontSize: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .caption
                                                                  .fontSize,
                                                              fontFamily:
                                                                  'Sans',),
                                                      ),
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                margin: index == 0
                                                    ? EdgeInsets.only(
                                                        left: 20.0,
                                                        right: 20.0,
                                                        top: 5.0,
                                                        bottom: 20.0)
                                                    : EdgeInsets.all(
                                                        20.0),
                                                padding: EdgeInsets.all(
                                                    16.0),
                                                decoration: BoxDecoration(
                                                    color: index == 0
                                                        ? MediaQuery.of(context)
                                                                    .platformBrightness ==
                                                                Brightness
                                                                    .light
                                                            ? Theme.of(
                                                                    context)
                                                                .backgroundColor
                                                            : Colors
                                                                .indigo
                                                        : Theme.of(
                                                                context)
                                                            .backgroundColor,
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          blurRadius:
                                                              8.0,
                                                          color: MediaQuery.of(context)
                                                                      .platformBrightness ==
                                                                  Brightness
                                                                      .light
                                                              ? Colors
                                                                  .black12
                                                              : Colors
                                                                  .transparent,
                                                          offset:
                                                              Offset(
                                                                  0.0,
                                                                  3.0))
                                                    ]),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <
                                                          Widget>[
                                                        Icon(
                                                          Ionicons
                                                              .md_calendar,
                                                          color: index ==
                                                                  0
                                                              ? MediaQuery.of(context).platformBrightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? Colors.indigo[
                                                                      300]
                                                                  : Colors.indigoAccent[
                                                                      100]
                                                              : Theme.of(
                                                                      context)
                                                                  .disabledColor,
                                                        ),
                                                        SizedBox(
                                                          width: 10.0,
                                                        ),
                                                        Text(
                                                          index == 0
                                                              ? dateFormat.format(
                                                                  listSchedule[index]
                                                                      .date)
                                                              : dateFormat
                                                                  .format(
                                                                      listSchedule[index].date),
                                                          style: TextStyle(
                                                              fontSize: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .subhead
                                                                  .fontSize,
                                                              fontFamily:
                                                                  'Sans',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    Divider(),
                                                    SizedBox(
                                                      height: 10.0,
                                                    ),
                                                    Text(
                                                      listSchedule[
                                                              index]
                                                          .shift,
                                                      style: TextStyle(
                                                          fontSize: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .title
                                                              .fontSize,
                                                          fontFamily:
                                                              'Google',
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                    ),
                                                    SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <
                                                          Widget>[
                                                        Text(
                                                          timeFormat.format(
                                                                  listSchedule[index]
                                                                      .startTime) +
                                                              ' AM',
                                                          style:
                                                              TextStyle(
                                                            fontSize: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .body2
                                                                .fontSize,
                                                            fontFamily:
                                                                'Sans',
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption
                                                                .color,
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize
                                                                  .min,
                                                          children: <
                                                              Widget>[
                                                            for (int i =
                                                                    0;
                                                                i < 20;
                                                                i++)
                                                              Row(
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    width:
                                                                        3.5,
                                                                    height:
                                                                        3.5,
                                                                    decoration:
                                                                        BoxDecoration(color: Theme.of(context).textTheme.caption.color, shape: BoxShape.circle),
                                                                  ),
                                                                  if (i <
                                                                      19)
                                                                    SizedBox(
                                                                      width: 5.0,
                                                                    ),
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                        Text(
                                                          timeFormat.format(
                                                                  listSchedule[index]
                                                                      .endTime) +
                                                              ' PM',
                                                          style:
                                                              TextStyle(
                                                            fontSize: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .body2
                                                                .fontSize,
                                                            fontFamily:
                                                                'Sans',
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption
                                                                .color,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (index == 0 &&
                                                        listSchedule[
                                                                index]
                                                            .isClockIn)
                                                      Column(
                                                        children: <
                                                            Widget>[
                                                          SizedBox(
                                                            height:
                                                                30.0,
                                                          ),
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    5.0),
                                                            child:
                                                                Steps(
                                                              // direction: 'vertical',
                                                              steps: listSchedule[index]
                                                                      .isOverTime
                                                                  ? [
                                                                      StepItem('Clockin'),
                                                                      StepItem('Break'),
                                                                      StepItem('After break'),
                                                                      StepItem('Clockout'),
                                                                      StepItem('Ovt In'),
                                                                      StepItem('Ovt Out'),
                                                                    ]
                                                                  : [
                                                                      StepItem('Clockin'),
                                                                      StepItem('Break'),
                                                                      StepItem('After break'),
                                                                      StepItem('Clockout'),
                                                                    ],
                                                              active: listSchedule[
                                                                      index]
                                                                  ._active,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    SizedBox(
                                                      height: 30.0,
                                                    ),
                                                    if (listSchedule[
                                                                    index]
                                                                .isOverTime &&
                                                            listSchedule[index]
                                                                    ._active <
                                                                5 ||
                                                        !listSchedule[
                                                                    index]
                                                                .isClockOut &&
                                                            listSchedule[index]
                                                                    ._active <
                                                                5)
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <
                                                            Widget>[
                                                          if (index !=
                                                                  0 &&
                                                              !listSchedule[
                                                                      index]
                                                                  .isSwitch)
                                                            FlatButton(
                                                              onPressed:
                                                                  () {
                                                                if (collaps) {
                                                                  _panelController
                                                                      .open();
                                                                  setState(
                                                                      () {
                                                                    collaps =
                                                                        false;
                                                                    indexList =
                                                                        index;
                                                                  });
                                                                } else {
                                                                  _panelController
                                                                      .close();
                                                                  setState(
                                                                      () {
                                                                    collaps =
                                                                        true;
                                                                    indexList =
                                                                        0;
                                                                  });
                                                                }
                                                              },
                                                              child:
                                                                  Row(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Ionicons.ios_repeat,
                                                                    color:
                                                                        Colors.white,
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        5.0,
                                                                  ),
                                                                  Text(
                                                                    'Switch',
                                                                    style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontFamily: 'Google',
                                                                        fontWeight: FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                              color: MediaQuery.of(context).platformBrightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors
                                                                      .orange[300],
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(5.0)),
                                                              splashColor:
                                                                  Colors
                                                                      .black26,
                                                              highlightColor:
                                                                  Colors
                                                                      .black26,
                                                            )
                                                          else
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                if (listSchedule[index]
                                                                    .isSwitch)
                                                                  Icon(
                                                                    FontAwesome.hourglass_2,
                                                                    size:
                                                                        16.0,
                                                                    color: MediaQuery.of(context).platformBrightness == Brightness.light
                                                                        ? Colors.orange
                                                                        : Colors.orange[300],
                                                                  ),
                                                                if (listSchedule[index]
                                                                    .isSwitch)
                                                                  SizedBox(
                                                                    width:
                                                                        8.0,
                                                                  ),
                                                                Text(
                                                                  listSchedule[index]._active >= 0
                                                                      ? 'You late ${listSchedule[index].lateTime} minutes'
                                                                      : listSchedule[index].isSwitch ? 'Your switch request\n is being processed' : '15 minutes again',
                                                                  style: listSchedule[index].isSwitch
                                                                      ? TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.orange : Colors.orange[300], fontSize: Theme.of(context).textTheme.caption.fontSize, fontFamily: 'Sans')
                                                                      : Theme.of(context).textTheme.caption,
                                                                ),
                                                              ],
                                                            ),
                                                          FlatButton(
                                                            onPressed:
                                                                () {
                                                              if (index ==
                                                                  0) {
                                                                if (!listSchedule[index]
                                                                    .isClockIn) {
                                                                  _gotoMapsPage(
                                                                      10,
                                                                      listSchedule[index].shift,
                                                                      index,
                                                                      listSchedule[index].startTime);
                                                                } else if (listSchedule[index]._active ==
                                                                    0) {
                                                                      _showAlertDialog('Attention', 'Are you sure want to break right now?', 20, index);
                                                                } else if (listSchedule[index]._active ==
                                                                    1) {
                                                                  _gotoMapsPage(
                                                                      20,
                                                                      listSchedule[index].shift,
                                                                      index,
                                                                      DateTime.now());
                                                                } else if (listSchedule[index]._active ==
                                                                    2) {
                                                                  _checkTimeNow(
                                                                      index,
                                                                      listSchedule[index].shift,
                                                                      20);
                                                                } else if (listSchedule[index]._active ==
                                                                    3) {
                                                                  _gotoMapsPage(
                                                                      30,
                                                                      listSchedule[index].shift,
                                                                      index,
                                                                      DateTime.now());
                                                                } else {
                                                                  _checkTimeNow(
                                                                      index,
                                                                      listSchedule[index].shift,
                                                                      30);
                                                                }
                                                              } else {
                                                                _getReminderSet(index);
                                                              }
                                                            },
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                if (index !=
                                                                    0)
                                                                  Icon(
                                                                    Ionicons.ios_notifications_outline,
                                                                    color:
                                                                        Colors.white,
                                                                  ),
                                                                SizedBox(
                                                                  width:
                                                                      5.0,
                                                                ),
                                                                Text(
                                                                  index == 0
                                                                      ? listSchedule[index]._active == 0 ? 'Break' : listSchedule[index]._active == 1 ? 'After Break' : listSchedule[index]._active == 2 ? 'Clock Out' : listSchedule[index]._active == 3 ? 'Overtime In' : listSchedule[index]._active == 4 ? 'Overtime Out' : 'Clock in'
                                                                      : 'Remind Me',
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontFamily: 'Google',
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                              ],
                                                            ),
                                                            color: index ==
                                                                    0
                                                                ? MediaQuery.of(context).platformBrightness == Brightness.light
                                                                    ? Colors
                                                                        .indigo
                                                                    : Colors.indigo[
                                                                        900]
                                                                : Theme.of(context)
                                                                    .buttonColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(5.0)),
                                                            splashColor:
                                                                Colors
                                                                    .black26,
                                                            highlightColor:
                                                                Colors
                                                                    .black26,
                                                          )
                                                        ],
                                                      )
                                                    else
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <
                                                            Widget>[
                                                          if (index !=
                                                              0)
                                                            FlatButton(
                                                              onPressed:
                                                                  () {
                                                                if (collaps) {
                                                                  _panelController
                                                                      .open();
                                                                  setState(
                                                                      () {
                                                                    collaps =
                                                                        false;
                                                                  });
                                                                } else {
                                                                  _panelController
                                                                      .close();
                                                                  setState(
                                                                      () {
                                                                    collaps =
                                                                        true;
                                                                  });
                                                                }
                                                              },
                                                              child:
                                                                  Row(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Ionicons.ios_repeat,
                                                                    color:
                                                                        Colors.white,
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        5.0,
                                                                  ),
                                                                  Text(
                                                                    'Switch',
                                                                    style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontFamily: 'Google',
                                                                        fontWeight: FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                              color: MediaQuery.of(context).platformBrightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors
                                                                      .orange[300],
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(5.0)),
                                                              splashColor:
                                                                  Colors
                                                                      .black26,
                                                              highlightColor:
                                                                  Colors
                                                                      .black26,
                                                            )
                                                          else
                                                            Column(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'Your Work Finished',
                                                                  style: Theme.of(context)
                                                                      .textTheme
                                                                      .caption,
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      10.0,
                                                                )
                                                              ],
                                                            ),
                                                          if (index !=
                                                              0)
                                                            FlatButton(
                                                              onPressed:
                                                                  () {
                                                                if (index ==
                                                                    0) {
                                                                  if (!listSchedule[index]
                                                                    .isClockIn) {
                                                                    _gotoMapsPage(
                                                                        10,
                                                                        listSchedule[index].shift,
                                                                        index,
                                                                        listSchedule[index].startTime);
                                                                  } else if (listSchedule[index]._active ==
                                                                      0) {
                                                                        _showAlertDialog('Attention', 'Are you sure want to break right now?', 20, index);
                                                                  } else if (listSchedule[index]._active ==
                                                                      1) {
                                                                    _gotoMapsPage(
                                                                        20,
                                                                        listSchedule[index].shift,
                                                                        index,
                                                                        DateTime.now());
                                                                  } else if (listSchedule[index]._active ==
                                                                      2) {
                                                                    _checkTimeNow(
                                                                        index,
                                                                        listSchedule[index].shift,
                                                                        20);
                                                                  } else if (listSchedule[index]._active ==
                                                                      3) {
                                                                    _gotoMapsPage(
                                                                        30,
                                                                        listSchedule[index].shift,
                                                                        index,
                                                                        DateTime.now());
                                                                  } else {
                                                                    _checkTimeNow(
                                                                        index,
                                                                        listSchedule[index].shift,
                                                                        30);
                                                                  }
                                                                } else {
                                                                  _getReminderSet(index);
                                                                }
                                                              },
                                                              child:
                                                                  Row(
                                                                children: <
                                                                    Widget>[
                                                                  if (index !=
                                                                      0)
                                                                    Icon(
                                                                      Ionicons.ios_notifications_outline,
                                                                      color: Colors.white,
                                                                    ),
                                                                  SizedBox(
                                                                    width:
                                                                        5.0,
                                                                  ),
                                                                  Text(
                                                                    index == 0
                                                                        ? listSchedule[index]._active == 0 ? 'Break' : listSchedule[index]._active == 1 ? 'After Break' : listSchedule[index]._active == 2 ? 'Clock Out' : listSchedule[index]._active == 3 ? 'Overtime In' : listSchedule[index]._active == 4 ? 'Overtime Out' : 'Clock in'
                                                                        : 'Remind Me',
                                                                    style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontFamily: 'Google',
                                                                        fontWeight: FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                              color: index ==
                                                                      0
                                                                  ? MediaQuery.of(context).platformBrightness == Brightness.light
                                                                      ? Colors.indigo
                                                                      : Colors.indigo[900]
                                                                  : Theme.of(context).buttonColor,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(5.0)),
                                                              splashColor:
                                                                  Colors
                                                                      .black26,
                                                              highlightColor:
                                                                  Colors
                                                                      .black26,
                                                            )
                                                          else
                                                            Column(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'Thank You!',
                                                                  style: Theme.of(context)
                                                                      .textTheme
                                                                      .caption,
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      10.0,
                                                                )
                                                              ],
                                                            ),
                                                        ],
                                                      )
                                                  ],
                                                ),
                                              );
                                })
                          else
                            Column(
                              children: <Widget>[
                                FadeUp(
                                  1.5,
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 5.0,
                                        bottom: 20.0),
                                    padding: EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 16.0,
                                        bottom: 10.0),
                                    decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            ContentPlaceholder(
                                              height: 20,
                                              width: 20,
                                              spacing: EdgeInsets.zero,
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            ContentPlaceholder(
                                              height: 20,
                                              width: 150,
                                              spacing: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                        ContentPlaceholder(
                                          height: 1,
                                          width: double.infinity,
                                          spacing: EdgeInsets.zero,
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        ContentPlaceholder(
                                          height: 28,
                                          width: 55,
                                          spacing: EdgeInsets.zero,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            ContentPlaceholder(
                                              height: 18,
                                              width: 65,
                                              spacing: EdgeInsets.zero,
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                for (int i = 0; i < 20; i++)
                                                  Row(
                                                    children: <Widget>[
                                                      ContentPlaceholder(
                                                        height: 3.5,
                                                        width: 3.5,
                                                        spacing:
                                                            EdgeInsets.zero,
                                                      ),
                                                      if (i < 19)
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            ContentPlaceholder(
                                              height: 18,
                                              width: 65,
                                              spacing: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            ContentPlaceholder(
                                              height: 18,
                                              width: 140,
                                              spacing: EdgeInsets.zero,
                                            ),
                                            ContentPlaceholder(
                                              height: 38,
                                              width: 90,
                                              spacing: EdgeInsets.zero,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                FadeUp(
                                  2.5,
                                  Container(
                                    margin: EdgeInsets.all(
                                      20.0,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 16.0,
                                        bottom: 10.0),
                                    decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            ContentPlaceholder(
                                              height: 20,
                                              width: 20,
                                              spacing: EdgeInsets.zero,
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            ContentPlaceholder(
                                              height: 20,
                                              width: 150,
                                              spacing: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                        ContentPlaceholder(
                                          height: 1,
                                          width: double.infinity,
                                          spacing: EdgeInsets.zero,
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        ContentPlaceholder(
                                          height: 28,
                                          width: 55,
                                          spacing: EdgeInsets.zero,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            ContentPlaceholder(
                                              height: 18,
                                              width: 65,
                                              spacing: EdgeInsets.zero,
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                for (int i = 0; i < 20; i++)
                                                  Row(
                                                    children: <Widget>[
                                                      ContentPlaceholder(
                                                        height: 3.5,
                                                        width: 3.5,
                                                        spacing:
                                                            EdgeInsets.zero,
                                                      ),
                                                      if (i < 19)
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            ContentPlaceholder(
                                              height: 18,
                                              width: 65,
                                              spacing: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.0,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            ContentPlaceholder(
                                              height: 38,
                                              width: 90,
                                              spacing: EdgeInsets.zero,
                                            ),
                                            ContentPlaceholder(
                                              height: 38,
                                              width: 90,
                                              spacing: EdgeInsets.zero,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 100.0,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text('\u00a9 2020 Absenin',
                                  style: Theme.of(context).textTheme.overline),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.15,
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              )),
            )),
        onWillPop: _onBackPressed);
  }

  Future<bool> _onBackPressed() {
    if (_panelController.isPanelClosed && _canVibrate) {
      Vibrate.feedback(FeedbackType.warning);
    }
    return _panelController.isPanelOpen
        ? _panelController.close()
        : showDialog(
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
                                    'Hi, $name',
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
                                    'Do you want to exit an application?',
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
                                  Navigator.of(context).pop(true);
                                },
                                child: Text(
                                  'Yes',
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
                                },
                                child: Text(
                                  'No',
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
                            )
                          ],
                        ),
                      ],
                    ))) ??
            false;
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
