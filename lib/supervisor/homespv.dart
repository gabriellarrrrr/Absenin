import 'dart:async';

import 'package:absenin/login.dart';
import 'package:absenin/supervisor/approval.dart';
import 'package:absenin/supervisor/profilespv.dart';
import 'package:absenin/supervisor/report.dart';
import 'package:absenin/supervisor/liststaff.dart';
import 'package:absenin/supervisor/schedule.dart';
import 'package:absenin/user/map.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:content_placeholder/content_placeholder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_vant_kit/widgets/steps.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpvHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SpvHomeState();
  }
}

class Menu {
  final String title, img;

  Menu(this.title, this.img);
}

class OverviewSchedule {
  final DateTime date, startTime, endTime, switchDate;
  final String shift, pos;
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

class TodayCheck {
  bool check;

  TodayCheck(this.check);
}

class SpvHomeState extends State<SpvHome> {
  Menu menu1 = new Menu('Schedule', 'assets/images/schedule.png');
  Menu menu2 = new Menu('Staff', 'assets/images/staff.png');
  Menu menu3 = new Menu('Approve', 'assets/images/approve.png');
  Menu menu4 = new Menu('Report', 'assets/images/report.png');
  List<OverviewSchedule> listSchedule = new List<OverviewSchedule>();
  List<TodayCheck> listToday = new List<TodayCheck>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String id = '',
      name = '',
      img = '',
      position = '',
      outlet = '',
      phone = '',
      email = '',
      address = '',
      passcode = '';
  int role = 0;
  bool status = false;
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateFormat timeFormat = DateFormat.Hm();
  bool _canVibrate = true, noOperational = false;
  List<OprationalItem> listJadwal = new List<OprationalItem>();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;

  void onClick(String title) {
    if (title == 'Schedule') {
      Navigator.of(context).push(_createRoute(Schedule()));
    } else if (title == 'Staff') {
      Navigator.of(context).push(_createRoute(Staff(
        action: 10,
      )));
    } else if (title == 'Approve') {
      Navigator.of(context).push(_createRoute(Approval()));
    } else if (title == 'Report') {
      Navigator.of(context).push(_createRoute(ReportPage()));
    }
  }

  @override
  void initState() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    TodayCheck item = new TodayCheck(false);
    TodayCheck item1 = new TodayCheck(false);
    listToday.add(item);
    listToday.add(item1);
    getUser();
    _checkVibrate();
    super.initState();
  }

  _onRefresh() async {
    if (noOperational) {
      setState(() {
        noOperational = false;
      });
      getOprationalSchedule();
    } else {
      listSchedule.clear();
      listToday.clear();
      TodayCheck item = new TodayCheck(false);
      TodayCheck item1 = new TodayCheck(false);
      listToday.add(item);
      listToday.add(item1);
      _getListSchedule();
    }
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
            } else {
              setState(() {
                noOperational = true;
              });
              _refreshController.refreshCompleted();
            }
          });
        });
      }
    });
  }

  _getOutlet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firestore
        .collection('outlet')
        .where('name', isEqualTo: outlet)
        .snapshots()
        .listen((data) {
      if (data.documents.isNotEmpty) {
        data.documents.forEach((f) {
          prefs.setString('city', f.data['city']);
          prefs.setString('owner', f.data['owner']);
          prefs.setInt('radius', f.data['radius']);
          prefs.setDouble('latitude', f.data['latitude']);
          prefs.setDouble('longtitude', f.data['longtitude']);
        });
      }
    });
  }

  _getReportUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firestore
        .collection('url')
        .document('report')
        .collection('list_url')
        .snapshots()
        .listen((data) {
      if (data.documents.isNotEmpty) {
        data.documents.forEach((f) {
          if (f.documentID == 'custom') {
            prefs.setString('r_custom', f.data['url']);
          } else if (f.documentID == 'monthly') {
            prefs.setString('r_monthly', f.data['url']);
          } else if (f.documentID == "staff's") {
            prefs.setString("r_staff's", f.data['url']);
          }
        });
      }
    });
  }

  _getDownloadUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firestore
        .collection('url')
        .document('download')
        .collection('list_url')
        .snapshots()
        .listen((data) {
      if (data.documents.isNotEmpty) {
        data.documents.forEach((f) {
          if (f.documentID == 'custom') {
            prefs.setString('d_custom', f.data['url']);
          } else if (f.documentID == 'monthly') {
            prefs.setString('d_monthly', f.data['url']);
          } else if (f.documentID == "staff's") {
            prefs.setString("d_staff's", f.data['url']);
          } else if (f.documentID == 'absenin') {
            prefs.setString('d_absenin', f.data['url']);
          }
        });
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
            role = f.data['role'];
            passcode = f.data['passcode'];
            status = f.data['status'];
            prefs.setString('idUser', id);
            prefs.setString('namaUser', name);
            prefs.setString('positionUser', position);
            prefs.setString('imgUser', img);
            prefs.setString('phoneUser', phone);
            prefs.setString('emailUser', email);
            prefs.setString('addressUser', address);
            prefs.setInt('roleUser', role);
            prefs.setString('passcodeUser', passcode);
            prefs.setBool('status', status);
            _getOutlet();
            getOprationalSchedule();
            _getReportUrl();
            _getDownloadUrl();
          });
        });
      }
    });
  }

  Future<void> _getListSchedule() async {
    DateTime dateTime = DateTime.now();

    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < listJadwal.length; j++) {
        print(
            'MENGAMBIL DATA TANGGAL ${dateTime.day + i} / ${listJadwal[j].shift}');
        if (!listToday[i].check) {
          await firestore
              .collection('schedule')
              .document(outlet)
              .collection('scheduledetail')
              .document('${dateTime.year}')
              .collection('${dateTime.month}')
              .document('${listJadwal[j].shift}')
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

              await firestore
                  .collection('schedule')
                  .document(outlet)
                  .collection('scheduledetail')
                  .document('${dateTime.year}')
                  .collection('${dateTime.month}')
                  .document('${listJadwal[j].shift}')
                  .collection('listday')
                  .document('${dateTime.day + i}')
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
                      start = snapshoots.data['fullstart2'];
                      end = snapshoots.data['fullend2'];
                    } else {
                      start = snapshoots.data['fullstart'];
                      end = snapshoots.data['fullend'];
                    }
                  }
                  OverviewSchedule item = new OverviewSchedule(
                      Jiffy().add(days: i),
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
                    if (i == 0) {
                      if (!isClockIn &&
                          !isPermit &&
                          isSwitchAcc != 1 &&
                          !isOff) {
                        _setClockInNotifMin15(start.toDate());
                      }
                    }
                  });
                } else {
                  print('Details empty!');
                }
              });
            } else {
              if (j == listJadwal.length - 1 && !listToday[i].check) {
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
                    DateTime.now(),
                    DateTime.now(),
                    DateTime.now());
                setState(() {
                  listToday[i].check = true;
                  listSchedule.add(item);
                  print(
                      'TANGGAL ${dateTime.day + i} : ${listJadwal[j].shift} TIDAK ADA JADWAL');
                });
              }
            }
          });
        }
      }
    }

    // for (int i = 0; i < 2; i++) {
    //   await firestore
    //       .collection('schedule')
    //       .document(outlet)
    //       .collection('scheduledetail')
    //       .document('${dateTime.year}')
    //       .collection('${dateTime.month}')
    //       .document('Shift 1')
    //       .collection('listday')
    //       .document('${dateTime.day + i}')
    //       .collection('liststaff')
    //       .document(id)
    //       .get()
    //       .then((snapshoot) async {
    //     if (snapshoot.exists) {
    //       Timestamp switchDate = snapshoot.data['switchDate'];
    //       Timestamp clockinTime = snapshoot.data['clockin'];
    //       Timestamp breakTime = snapshoot.data['break'];
    //       Timestamp afterbreakTime = snapshoot.data['afterbreak'];
    //       Timestamp clockoutTime = snapshoot.data['clockout'];
    //       Timestamp overtimeinTime = snapshoot.data['overtimein'];
    //       Timestamp overtimeoutTime = snapshoot.data['overtimeout'];
    //       bool isClockIn = snapshoot.data['isClockIn'];
    //       bool isOtherTime = snapshoot.data['otherTime'];
    //       bool isBreak = snapshoot.data['isBreak'];
    //       bool isAfterBreak = snapshoot.data['isAfterBreak'];
    //       bool isClockOut = snapshoot.data['isClockOut'];
    //       bool isOverTime = snapshoot.data['isOvertime'];
    //       bool isOverTimeIn = snapshoot.data['isOvertimeIn'];
    //       bool isOverTimeOut = snapshoot.data['isOvertimeOut'];
    //       bool isPermit = snapshoot.data['permit'];
    //       bool isSwitch = snapshoot.data['switch'];
    //       int isSwitchAcc = snapshoot.data['switchAcc'];
    //       int lateTime = snapshoot.data['late'];
    //       int type = snapshoot.data['type'];
    //       String pos = snapshoot.data['pos'];
    //       int active = -1;
    //       if (isClockIn) {
    //         active = 0;
    //       }
    //       if (isBreak) {
    //         active = 1;
    //       }
    //       if (isAfterBreak) {
    //         active = 2;
    //       }
    //       if (isClockOut) {
    //         active = 3;
    //       }
    //       if (isOverTimeIn) {
    //         active = 4;
    //       }
    //       if (isOverTimeOut) {
    //         active = 5;
    //       }

    //       await firestore
    //           .collection('schedule')
    //           .document(outlet)
    //           .collection('scheduledetail')
    //           .document('${dateTime.year}')
    //           .collection('${dateTime.month}')
    //           .document('Shift 1')
    //           .collection('listday')
    //           .document('${dateTime.day + i}')
    //           .get()
    //           .then((snapshoots) {
    //         if (snapshoots.exists) {
    //           bool isOff = false;
    //           Timestamp start, end;
    //           if (type == 1) {
    //             if (isOtherTime) {
    //               start = snapshoots.data['fullstart2'];
    //               end = snapshoots.data['fullend2'];
    //             } else {
    //               start = snapshoots.data['fullstart'];
    //               end = snapshoots.data['fullend'];
    //             }
    //           } else {
    //             if (isOtherTime) {
    //               start = snapshoots.data['fullstart2'];
    //               end = snapshoots.data['fullend2'];
    //             } else {
    //               start = snapshoots.data['fullstart'];
    //               end = snapshoots.data['fullend'];
    //             }
    //           }
    //           OverviewSchedule item = new OverviewSchedule(
    //               Jiffy().add(days: i),
    //               start.toDate(),
    //               end.toDate(),
    //               'Shift 1',
    //               pos,
    //               lateTime,
    //               type,
    //               isClockIn,
    //               isBreak,
    //               isAfterBreak,
    //               isClockOut,
    //               isOverTime,
    //               isOverTimeIn,
    //               isOverTimeOut,
    //               isOff,
    //               isPermit,
    //               isSwitch,
    //               isSwitchAcc,
    //               switchDate.toDate(),
    //               active,
    //               clockinTime.toDate(),
    //               breakTime.toDate(),
    //               afterbreakTime.toDate(),
    //               clockoutTime.toDate(),
    //               overtimeinTime.toDate(),
    //               overtimeoutTime.toDate());
    //           setState(() {
    //             listSchedule.add(item);
    //             if (i == 0) {
    //               if (!isClockIn && !isPermit && isSwitchAcc != 1 && !isOff) {
    //                 _setClockInNotifMin15(start.toDate());
    //               }
    //             }
    //           });
    //         } else {
    //           print('Details empty!');
    //         }
    //       });
    //     } else {
    //       await firestore
    //           .collection('schedule')
    //           .document(outlet)
    //           .collection('scheduledetail')
    //           .document('${dateTime.year}')
    //           .collection('${dateTime.month}')
    //           .document('Shift 2')
    //           .collection('listday')
    //           .document('${dateTime.day + i}')
    //           .collection('liststaff')
    //           .document(id)
    //           .get()
    //           .then((snapshoot) async {
    //         if (snapshoot.exists) {
    //           Timestamp switchDate = snapshoot.data['switchDate'];
    //           Timestamp clockinTime = snapshoot.data['clockin'];
    //           Timestamp breakTime = snapshoot.data['break'];
    //           Timestamp afterbreakTime = snapshoot.data['afterbreak'];
    //           Timestamp clockoutTime = snapshoot.data['clockout'];
    //           Timestamp overtimeinTime = snapshoot.data['overtimein'];
    //           Timestamp overtimeoutTime = snapshoot.data['overtimeout'];
    //           bool isClockIn = snapshoot.data['isClockIn'];
    //           bool isOtherTime = snapshoot.data['otherTime'];
    //           bool isBreak = snapshoot.data['isBreak'];
    //           bool isAfterBreak = snapshoot.data['isAfterBreak'];
    //           bool isClockOut = snapshoot.data['isClockOut'];
    //           bool isOverTime = snapshoot.data['isOvertime'];
    //           bool isOverTimeIn = snapshoot.data['isOvertimeIn'];
    //           bool isOverTimeOut = snapshoot.data['isOvertimeOut'];
    //           bool isPermit = snapshoot.data['permit'];
    //           bool isSwitch = snapshoot.data['switch'];
    //           int isSwitchAcc = snapshoot.data['switchAcc'];
    //           int lateTime = snapshoot.data['late'];
    //           int type = snapshoot.data['type'];
    //           String pos = snapshoot.data['pos'];
    //           int active = -1;
    //           if (isClockIn) {
    //             active = 0;
    //           }
    //           if (isBreak) {
    //             active = 1;
    //           }
    //           if (isAfterBreak) {
    //             active = 2;
    //           }
    //           if (isClockOut) {
    //             active = 3;
    //           }
    //           if (isOverTimeIn) {
    //             active = 4;
    //           }
    //           if (isOverTimeOut) {
    //             active = 5;
    //           }

    //           await firestore
    //               .collection('schedule')
    //               .document(outlet)
    //               .collection('scheduledetail')
    //               .document('${dateTime.year}')
    //               .collection('${dateTime.month}')
    //               .document('Shift 2')
    //               .collection('listday')
    //               .document('${dateTime.day + i}')
    //               .get()
    //               .then((snapshoots) {
    //             if (snapshoots.exists) {
    //               bool isOff = false;
    //               Timestamp start, end;
    //               if (type == 1) {
    //                 if (isOtherTime) {
    //                   start = snapshoots.data['fullstart2'];
    //                   end = snapshoots.data['fullend2'];
    //                 } else {
    //                   start = snapshoots.data['fullstart'];
    //                   end = snapshoots.data['fullend'];
    //                 }
    //               } else {
    //                 if (isOtherTime) {
    //                   start = snapshoots.data['fullstart2'];
    //                   end = snapshoots.data['fullend2'];
    //                 } else {
    //                   start = snapshoots.data['fullstart'];
    //                   end = snapshoots.data['fullend'];
    //                 }
    //               }
    //               OverviewSchedule item = new OverviewSchedule(
    //                   Jiffy().add(days: i),
    //                   start.toDate(),
    //                   end.toDate(),
    //                   'Shift 2',
    //                   pos,
    //                   lateTime,
    //                   type,
    //                   isClockIn,
    //                   isBreak,
    //                   isAfterBreak,
    //                   isClockOut,
    //                   isOverTime,
    //                   isOverTimeIn,
    //                   isOverTimeOut,
    //                   isOff,
    //                   isPermit,
    //                   isSwitch,
    //                   isSwitchAcc,
    //                   switchDate.toDate(),
    //                   active,
    //                   clockinTime.toDate(),
    //                   breakTime.toDate(),
    //                   afterbreakTime.toDate(),
    //                   clockoutTime.toDate(),
    //                   overtimeinTime.toDate(),
    //                   overtimeoutTime.toDate());
    //               setState(() {
    //                 listSchedule.add(item);
    //                 if (i == 0) {
    //                   if (!isClockIn &&
    //                       !isPermit &&
    //                       isSwitchAcc != 1 &&
    //                       !isOff) {
    //                     _setClockInNotifMin15(start.toDate());
    //                   }
    //                 }
    //               });
    //             } else {
    //               print('Details empty!');
    //             }
    //           });
    //         } else {
    //           print('No Schedule For You!');
    //           OverviewSchedule item = new OverviewSchedule(
    //               Jiffy().add(days: i),
    //               DateTime.now(),
    //               DateTime.now(),
    //               '-',
    //               '-',
    //               0,
    //               0,
    //               false,
    //               false,
    //               false,
    //               false,
    //               false,
    //               false,
    //               false,
    //               true,
    //               false,
    //               false,
    //               0,
    //               DateTime.now(),
    //               -1,
    //               DateTime.now(),
    //               DateTime.now(),
    //               DateTime.now(),
    //               DateTime.now(),
    //               DateTime.now(),
    //               DateTime.now());
    //           setState(() {
    //             listSchedule.add(item);
    //           });
    //         }
    //       });
    //     }
    //   });
    // }
    _refreshController.refreshCompleted();
  }

  _setClockInNotifMin15(DateTime dateTime) async {
    DateTime date = Jiffy(dateTime).subtract(minutes: 15);
    var time = Time(date.hour, date.minute, date.second);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '10', 'Clock In 15', '15 Minutes',
        importance: Importance.Max, priority: Priority.High);
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
        '20', 'After Break 15', '15 Minutes',
        importance: Importance.Max, priority: Priority.High);
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
        '30', 'Clock Out 15', '15 Minutes',
        importance: Importance.Max, priority: Priority.High);
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
    if (result != null) {
      if (_action == 10) {
        setState(() {
          listSchedule[index].isClockIn = true;
          listSchedule[index].clockinTime = DateTime.now();
          listSchedule[index].lateTime = result;
        });
      } else if (_action == 20 && result != false) {
        setState(() {
          listSchedule[index].isAfterBreak = true;
          listSchedule[index].afterbreakTime = DateTime.now();
        });
      } else if (_action == 30 && result != false) {
        setState(() {
          listSchedule[index].isOverTimeIn = true;
          listSchedule[index].overtimeinTime = DateTime.now();
        });
      } else if (_action == 40 && result != false) {
        setState(() {
          listSchedule[index].isClockOut = true;
          listSchedule[index].clockoutTime = DateTime.now();
        });
        if (!listSchedule[index].isOverTime) {
          await firestore
              .collection('history')
              .document(outlet)
              .collection('listhistory')
              .document('${DateTime.now().year}')
              .collection(id)
              .document('${DateTime.now().month}')
              .collection('listhistory')
              .add({
            'date': listSchedule[index].date,
            'shift': listSchedule[index].shift,
            'start': listSchedule[index].startTime,
            'end': listSchedule[index].endTime,
            'late': listSchedule[index].lateTime,
            'pos': listSchedule[index].pos
          });
          int dayintotaltime = DateTime.now()
              .difference(listSchedule[index].clockinTime)
              .inMinutes;
          int breaktotaltime = listSchedule[index]
              .afterbreakTime
              .difference(listSchedule[index].breakTime)
              .inMinutes;
          int lateday = 0;
          if (listSchedule[index].lateTime > 0) {
            lateday = 1;
          }
          await firestore
              .collection('report')
              .document(outlet)
              .collection('listreport')
              .document('${DateTime.now().year}')
              .collection('${DateTime.now().month}')
              .document(id)
              .collection('listreport')
              .add({
            'id': id,
            'name': name,
            'shift': listSchedule[index].shift,
            'pos': listSchedule[index].pos,
            'dayin': 1,
            'dayintotaltime': dayintotaltime,
            'totalbreaktime': breaktotaltime,
            'overtimeday': 0,
            'overtimetotaltime': 0,
            'lateday': lateday,
            'latetotaltime': listSchedule[index].lateTime,
            'date': listSchedule[index].date,
            'clockin': listSchedule[index].clockinTime,
            'break': listSchedule[index].breakTime,
            'afterbreak': listSchedule[index].afterbreakTime,
            'clockout': listSchedule[index].clockoutTime,
            'overtimein': '-',
            'overtimeout': '-',
          });
        }
      } else {
        setState(() {
          listSchedule[index].isOverTimeOut = true;
          listSchedule[index].overtimeoutTime = DateTime.now();
        });
        await firestore
            .collection('history')
            .document(outlet)
            .collection('listhistory')
            .document('${DateTime.now().year}')
            .collection(id)
            .document('${DateTime.now().month}')
            .collection('listhistory')
            .add({
          'date': listSchedule[index].date,
          'shift': listSchedule[index].shift,
          'start': listSchedule[index].startTime,
          'end': listSchedule[index].endTime,
          'late': listSchedule[index].lateTime,
          'pos': listSchedule[index].pos
        });
        int dayintotaltime = DateTime.now()
            .difference(listSchedule[index].clockinTime)
            .inMinutes;
        int breaktotaltime = listSchedule[index]
            .afterbreakTime
            .difference(listSchedule[index].breakTime)
            .inMinutes;
        int lateday = 0;
        if (listSchedule[index].lateTime > 0) {
          lateday = 1;
        }
        int overtimetotaltime = DateTime.now()
            .difference(listSchedule[index].overtimeinTime)
            .inMinutes;
        await firestore
            .collection('report')
            .document(outlet)
            .collection('listreport')
            .document('${DateTime.now().year}')
            .collection('${DateTime.now().month}')
            .document(id)
            .collection('listreport')
            .add({
          'id': id,
          'name': name,
          'shift': listSchedule[index].shift,
          'pos': listSchedule[index].pos,
          'dayin': 1,
          'dayintotaltime': dayintotaltime,
          'totalbreaktime': breaktotaltime,
          'overtimeday': 1,
          'overtimetotaltime': overtimetotaltime,
          'lateday': lateday,
          'latetotaltime': listSchedule[index].lateTime,
          'date': listSchedule[index].date,
          'clockin': listSchedule[index].clockinTime,
          'break': listSchedule[index].breakTime,
          'afterbreak': listSchedule[index].afterbreakTime,
          'clockout': listSchedule[index].clockoutTime,
          'overtimein': listSchedule[index].overtimeinTime,
          'overtimeout': listSchedule[index].overtimeoutTime,
        });
      }
      _stepCounter(index);
    }
  }

  void _stepCounter(int index) {
    setState(() {
      listSchedule[index]._active++;
      if (listSchedule[index]._active == 3 && !listSchedule[index].isOverTime ||
          listSchedule[index]._active == 5 && listSchedule[index].isOverTime) {
        Timer(Duration(milliseconds: 300), () {
          _showAlertDialog(
              'Hi, $name', 'Your work finished, Thank you.', 10, index);
        });
      }
      if (listSchedule[index]._active == 2) {
        _setClockOut15(listSchedule[index].endTime);
      }
    });
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
                    if (action == 20)
                      Divider(
                        height: 0.0,
                      ),
                    if (action == 20)
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _checkTimeNow(index, listSchedule[index].shift, 10);
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

  _checkTimeNow(int index, String shift, int action) async {
    DateTime dateTime = DateTime.now();
    DateFormat year = DateFormat.y();
    DateFormat month = DateFormat.M();
    DateFormat day = DateFormat.d();
    DateFormat hourFormat = DateFormat.H();
    if (action == 10) {
      //aksi 10 = break
      DateTime longBreak = Jiffy(dateTime).add(minutes: 60);
      _prosesDialog();
      await firestore
          .collection('schedule')
          .document(outlet)
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
      //20 aksi clockout
      if (dateTime.hour >= listSchedule[index].endTime.hour &&
          dateTime.minute >= listSchedule[index].endTime.minute) {
        //cek jam saat itu dgn waktu clockout
        if (listSchedule[index].isOverTime) {
          //cek lembur apa nggak
          _prosesDialog();
          await firestore
              .collection('schedule')
              .document(outlet)
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
            listSchedule[index].clockoutTime = DateTime.now();
            Navigator.pop(context);
            setState(() {
              _stepCounter(index);
            });
          }
        } else {
          _gotoMapsPage(40, listSchedule[index].shift, index,
              DateTime.now()); //ini kalau gak lembur
        }
      } else {
        _showAlertDialog(
            'Attention',
            "You can't clockout now! clockout start at ${listSchedule[index].endTime.hour}:${listSchedule[index].endTime.minute} WIB",
            10,
            index); //ini kalo jamnya gak memenuhi, aksi 10
        if (_canVibrate) {
          Vibrate.feedback(FeedbackType.warning);
        }
      }
    }
  }

  _checkVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
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
    List<Menu> menu = [menu1, menu2, menu3, menu4];
    return Scaffold(
      appBar: AppBar(
        // leading: Image.asset(
        //   'assets/images/absenin.png',
        //   width: 20.0,
        //   height: 20.0,
        // ),
        title: Text('Absenin'),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Feather.settings,
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.indigo
                    : Colors.indigo[300],
                size: 20.0,
              ),
              onPressed: () {
                Navigator.of(context).push(_createRoute(ProfileSpv()));
              }),
        ],
      ),
      body: SmartRefresher(
          enablePullDown: true,
          header: MaterialClassicHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 30.0, bottom: 30.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15))),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Theme.of(context).dividerColor.withAlpha(10)),
                        child: ClipOval(
                            child: CachedNetworkImage(
                          imageUrl: img,
                          height: 85.0,
                          width: 85.0,
                          fit: BoxFit.cover,
                        )
                            // FadeInImage.assetNetwork(
                            //   placeholder: 'assets/images/absenin_icon.png',
                            //   height: 85.0,
                            //   width: 85.0,
                            //   image: img,
                            //   fadeInDuration: Duration(seconds: 1),
                            //   fit: BoxFit.cover,
                            // )
                            ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.headline,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(position,
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.caption.fontSize,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.orange[800]
                                : Colors.orange[300],
                          )),
                      if (noOperational)
                        Container(
                          margin: EdgeInsets.all(20.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.circular(10.0),
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
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Ionicons.md_warning,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Colors.indigo[400]
                                          : Colors.indigo[300]),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Text("No schedule available",
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .subhead
                                            .fontSize,
                                        fontFamily: 'Sans',
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                            ],
                          ),
                        )
                      else if (listSchedule.length > 0 && !noOperational)
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return !listSchedule[index].isOff
                                  ? Container(
                                      margin: index == 0
                                          ? EdgeInsets.only(
                                              top: 40.0,
                                            )
                                          : EdgeInsets.only(top: 20.0),
                                      padding: EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                          color: index == 0
                                              ? MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.light
                                                  ? Theme.of(context)
                                                      .backgroundColor
                                                  : Colors.indigo
                                              : Theme.of(context)
                                                  .backgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .dividerColor)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Ionicons.md_calendar,
                                                color: index == 0
                                                    ? MediaQuery.of(context)
                                                                .platformBrightness ==
                                                            Brightness.light
                                                        ? Colors.indigo[300]
                                                        : Colors
                                                            .indigoAccent[100]
                                                    : Theme.of(context)
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
                                                    : dateFormat.format(
                                                        listSchedule[index]
                                                            .date),
                                                style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .fontSize,
                                                    fontFamily: 'Sans',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Divider(),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          if (listSchedule[index].pos.length >
                                              0)
                                            Text(
                                              listSchedule[index].pos,
                                              style: TextStyle(
                                                  fontSize: Theme.of(context)
                                                      .textTheme
                                                      .title
                                                      .fontSize,
                                                  fontFamily: 'OpenSans',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          if (listSchedule[index].pos.length >
                                              0)
                                            SizedBox(
                                              height: 15.0,
                                            ),
                                          Text(
                                            listSchedule[index].shift,
                                            style: TextStyle(
                                                fontSize: Theme.of(context)
                                                    .textTheme
                                                    .subhead
                                                    .fontSize,
                                                fontFamily: 'Google',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: index == 0
                                                  ? MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.light
                                                      ? Colors.grey[100]
                                                      : Colors.indigo[700]
                                                  : MediaQuery.of(context)
                                                              .platformBrightness ==
                                                          Brightness.light
                                                      ? Colors.grey[100]
                                                      : Colors.grey[900],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  timeFormat.format(
                                                          listSchedule[index]
                                                              .startTime) +
                                                      ' AM',
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .body2
                                                        .fontSize,
                                                    fontFamily: 'Sans',
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .caption
                                                        .color,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    for (int i = 0; i < 20; i++)
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 3.5,
                                                            height: 3.5,
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .caption
                                                                    .color,
                                                                shape: BoxShape
                                                                    .circle),
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
                                                          listSchedule[index]
                                                              .endTime) +
                                                      ' PM',
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .body2
                                                        .fontSize,
                                                    fontFamily: 'Sans',
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .caption
                                                        .color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (index == 0 &&
                                              listSchedule[index].isClockIn)
                                            Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 30.0,
                                                ),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  child: Steps(
                                                    // direction: 'vertical',
                                                    steps: listSchedule[index]
                                                            .isOverTime
                                                        ? [
                                                            StepItem('Clockin'),
                                                            StepItem('Break'),
                                                            StepItem(
                                                                'After break'),
                                                            StepItem(
                                                                'Clockout'),
                                                            StepItem('Ovt In'),
                                                            StepItem('Ovt Out'),
                                                          ]
                                                        : [
                                                            StepItem('Clockin'),
                                                            StepItem('Break'),
                                                            StepItem(
                                                                'After break'),
                                                            StepItem(
                                                                'Clockout'),
                                                          ],
                                                    active: listSchedule[index]
                                                        ._active,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          SizedBox(
                                            height: 30.0,
                                          ),
                                          if (listSchedule[index].isOverTime &&
                                                  listSchedule[index]._active <
                                                      5 ||
                                              !listSchedule[index].isClockOut &&
                                                  listSchedule[index]._active <
                                                      5)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                if (index != 0 &&
                                                    !listSchedule[index]
                                                        .isSwitch)
                                                  FlatButton(
                                                    onPressed: () {
                                                      // if (collaps) {
                                                      //   _panelController.open();
                                                      //   setState(() {
                                                      //     collaps = false;
                                                      //     indexList = index;
                                                      //   });
                                                      // } else {
                                                      //   _panelController.close();
                                                      //   setState(() {
                                                      //     collaps = true;
                                                      //     indexList = 0;
                                                      //   });
                                                      // }
                                                    },
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Ionicons.ios_repeat,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                          'Switch',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  'Google',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    color: MediaQuery.of(
                                                                    context)
                                                                .platformBrightness ==
                                                            Brightness.light
                                                        ? Colors.orange
                                                        : Colors.orange[300],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                    splashColor: Colors.black26,
                                                    highlightColor:
                                                        Colors.black26,
                                                  )
                                                else
                                                  Row(
                                                    children: <Widget>[
                                                      if (listSchedule[index]
                                                          .isSwitch)
                                                        Icon(
                                                          FontAwesome
                                                              .hourglass_2,
                                                          size: 16.0,
                                                          color: MediaQuery.of(
                                                                          context)
                                                                      .platformBrightness ==
                                                                  Brightness
                                                                      .light
                                                              ? Colors.orange
                                                              : Colors
                                                                  .orange[300],
                                                        ),
                                                      if (listSchedule[index]
                                                          .isSwitch)
                                                        SizedBox(
                                                          width: 8.0,
                                                        ),
                                                      Text(
                                                        listSchedule[index]
                                                                    ._active >=
                                                                0
                                                            ? 'You late ${listSchedule[index].lateTime} minutes'
                                                            : listSchedule[
                                                                        index]
                                                                    .isSwitch
                                                                ? 'Your switch request\n is being processed'
                                                                : '',
                                                        style: listSchedule[
                                                                    index]
                                                                .isSwitch
                                                            ? TextStyle(
                                                                color: MediaQuery.of(context)
                                                                            .platformBrightness ==
                                                                        Brightness
                                                                            .light
                                                                    ? Colors
                                                                        .orange
                                                                    : Colors.orange[
                                                                        300],
                                                                fontSize: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .caption
                                                                    .fontSize,
                                                                fontFamily:
                                                                    'Sans')
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .caption,
                                                      ),
                                                    ],
                                                  ),
                                                FlatButton(
                                                  onPressed: () {
                                                    if (index == 0) {
                                                      if (!listSchedule[index]
                                                          .isClockIn) {
                                                        _gotoMapsPage(
                                                            10,
                                                            listSchedule[index]
                                                                .shift,
                                                            index,
                                                            listSchedule[index]
                                                                .startTime);
                                                      } else if (listSchedule[
                                                                  index]
                                                              ._active ==
                                                          0) {
                                                        _showAlertDialog(
                                                            'Attention',
                                                            'Are you sure want to break right now?',
                                                            20,
                                                            index);
                                                      } else if (listSchedule[
                                                                  index]
                                                              ._active ==
                                                          1) {
                                                        _gotoMapsPage(
                                                            20,
                                                            listSchedule[index]
                                                                .shift,
                                                            index,
                                                            DateTime.now());
                                                      } else if (listSchedule[
                                                                  index]
                                                              ._active ==
                                                          2) {
                                                        _checkTimeNow(
                                                            index,
                                                            listSchedule[index]
                                                                .shift,
                                                            20);
                                                      } else if (listSchedule[
                                                                  index]
                                                              ._active ==
                                                          3) {
                                                        _gotoMapsPage(
                                                            30,
                                                            listSchedule[index]
                                                                .shift,
                                                            index,
                                                            DateTime.now());
                                                      } else {
                                                        _gotoMapsPage(
                                                            50,
                                                            listSchedule[index]
                                                                .shift,
                                                            index,
                                                            DateTime.now());
                                                      }
                                                    } else {
                                                      // _getReminderSet(index);
                                                    }
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                      if (index != 0)
                                                        Icon(
                                                          Ionicons
                                                              .ios_notifications_outline,
                                                          color: Colors.white,
                                                        ),
                                                      SizedBox(
                                                        width: 5.0,
                                                      ),
                                                      Text(
                                                        index == 0
                                                            ? listSchedule[index]
                                                                        ._active ==
                                                                    0
                                                                ? 'Break'
                                                                : listSchedule[index]
                                                                            ._active ==
                                                                        1
                                                                    ? 'After Break'
                                                                    : listSchedule[index]._active ==
                                                                            2
                                                                        ? 'Clock Out'
                                                                        : listSchedule[index]._active ==
                                                                                3
                                                                            ? 'Overtime In'
                                                                            : listSchedule[index]._active == 4
                                                                                ? 'Overtime Out'
                                                                                : 'Clock in'
                                                            : 'Remind Me',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'Google',
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  color: index == 0
                                                      ? MediaQuery.of(context)
                                                                  .platformBrightness ==
                                                              Brightness.light
                                                          ? Colors.indigo
                                                          : Colors.indigo[900]
                                                      : Theme.of(context)
                                                          .buttonColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0)),
                                                  splashColor: Colors.black26,
                                                  highlightColor:
                                                      Colors.black26,
                                                )
                                              ],
                                            )
                                          else
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                if (index != 0)
                                                  FlatButton(
                                                    onPressed: () {
                                                      // if (collaps) {
                                                      //   _panelController.open();
                                                      //   setState(() {
                                                      //     collaps = false;
                                                      //   });
                                                      // } else {
                                                      //   _panelController.close();
                                                      //   setState(() {
                                                      //     collaps = true;
                                                      //   });
                                                      // }
                                                    },
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Ionicons.ios_repeat,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                          'Switch',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  'Google',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    color: MediaQuery.of(
                                                                    context)
                                                                .platformBrightness ==
                                                            Brightness.light
                                                        ? Colors.orange
                                                        : Colors.orange[300],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                    splashColor: Colors.black26,
                                                    highlightColor:
                                                        Colors.black26,
                                                  )
                                                else
                                                  Column(
                                                    children: <Widget>[
                                                      Text(
                                                        'Your Work Finished',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption,
                                                      ),
                                                      SizedBox(
                                                        height: 10.0,
                                                      )
                                                    ],
                                                  ),
                                                if (index != 0)
                                                  FlatButton(
                                                    onPressed: () {
                                                      if (index == 0) {
                                                        if (!listSchedule[index]
                                                            .isClockIn) {
                                                          _gotoMapsPage(
                                                              10,
                                                              listSchedule[
                                                                      index]
                                                                  .shift,
                                                              index,
                                                              listSchedule[
                                                                      index]
                                                                  .startTime);
                                                        } else if (listSchedule[
                                                                    index]
                                                                ._active ==
                                                            0) {
                                                          _showAlertDialog(
                                                              'Attention',
                                                              'Are you sure want to break right now?',
                                                              20,
                                                              index);
                                                        } else if (listSchedule[
                                                                    index]
                                                                ._active ==
                                                            1) {
                                                          _gotoMapsPage(
                                                              20,
                                                              listSchedule[
                                                                      index]
                                                                  .shift,
                                                              index,
                                                              DateTime.now());
                                                        } else if (listSchedule[
                                                                    index]
                                                                ._active ==
                                                            2) {
                                                          _checkTimeNow(
                                                              index,
                                                              listSchedule[
                                                                      index]
                                                                  .shift,
                                                              20);
                                                        } else if (listSchedule[
                                                                    index]
                                                                ._active ==
                                                            3) {
                                                          _gotoMapsPage(
                                                              30,
                                                              listSchedule[
                                                                      index]
                                                                  .shift,
                                                              index,
                                                              DateTime.now());
                                                        } else {
                                                          _checkTimeNow(
                                                              index,
                                                              listSchedule[
                                                                      index]
                                                                  .shift,
                                                              30);
                                                        }
                                                      } else {
                                                        // _getReminderSet(index);
                                                      }
                                                    },
                                                    child: Row(
                                                      children: <Widget>[
                                                        if (index != 0)
                                                          Icon(
                                                            Ionicons
                                                                .ios_notifications_outline,
                                                            color: Colors.white,
                                                          ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                          index == 0
                                                              ? listSchedule[index]
                                                                          ._active ==
                                                                      0
                                                                  ? 'Break'
                                                                  : listSchedule[index]
                                                                              ._active ==
                                                                          1
                                                                      ? 'After Break'
                                                                      : listSchedule[index]._active ==
                                                                              2
                                                                          ? 'Clock Out'
                                                                          : listSchedule[index]._active == 3
                                                                              ? 'Overtime In'
                                                                              : listSchedule[index]._active == 4 ? 'Overtime Out' : 'Clock in'
                                                              : 'Remind Me',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  'Google',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    color: index == 0
                                                        ? MediaQuery.of(context)
                                                                    .platformBrightness ==
                                                                Brightness.light
                                                            ? Colors.indigo
                                                            : Colors.indigo[900]
                                                        : Theme.of(context)
                                                            .buttonColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                    splashColor: Colors.black26,
                                                    highlightColor:
                                                        Colors.black26,
                                                  )
                                                else
                                                  Column(
                                                    children: <Widget>[
                                                      Text(
                                                        'Thank You!',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption,
                                                      ),
                                                      SizedBox(
                                                        height: 10.0,
                                                      )
                                                    ],
                                                  ),
                                              ],
                                            )
                                        ],
                                      ),
                                    )
                                  : null;
                            })
                      else
                        Container(
                          margin: EdgeInsets.only(
                            top: 40.0,
                          ),
                          padding: EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 16.0, bottom: 10.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                  width: 0.5,
                                  color: Theme.of(context).dividerColor)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    width: 50,
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
                                              spacing: EdgeInsets.zero,
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
                                    width: 50,
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 40.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Feather.layers,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.indigo
                            : Colors.indigo[300],
                        size: 18.0,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        'Menu',
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.subhead.fontSize,
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.indigo
                                : Colors.indigo[300]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: menu.map((index) {
                      return Container(
                        margin: EdgeInsets.only(
                            left: 10, right: 10.0, top: 10.0, bottom: 10.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark
                                        ? Colors.transparent
                                        : Colors.grey[300],
                                offset: Offset(3.0, 3.0),
                                blurRadius: 8.0,
                              )
                            ]),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            // side: BorderSide(
                            //   color: Theme.of(context).dividerColor,
                            //   width: 3.0
                            // )
                          ),
                          onPressed: () {
                            onClick(index.title);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Image.asset(
                                index.img,
                                width: MediaQuery.of(context).size.width * 0.25,
                                filterQuality: FilterQuality.medium,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                index.title,
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .subhead
                                      .fontSize,
                                  fontFamily: 'Sans',
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 100.0,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('\u00a9 2020 Admin Absenin',
                      style: Theme.of(context).textTheme.overline),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
              ],
            ),
          )),
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
