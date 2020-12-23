import 'package:absenin/reportsetup/reportcontroler.dart';
import 'package:absenin/reportsetup/reportstaffmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryStaff extends StatefulWidget {
  final String id, name;

  const HistoryStaff({Key key, @required this.id, @required this.name})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HistoryStaffState();
  }
}

class HistoryItem {
  final DateTime date, clockin, breakk, afterbreak, clockout, overin, overout;
  final int dayin, lateday, overtime;
  final String shift,
      posisi,
      latetotaltime,
      overtimetotaltime,
      totalbreaktime,
      dayintotaltime;

  HistoryItem(
      this.date,
      this.dayin,
      this.dayintotaltime,
      this.lateday,
      this.latetotaltime,
      this.overtime,
      this.overtimetotaltime,
      this.totalbreaktime,
      this.clockin,
      this.breakk,
      this.afterbreak,
      this.clockout,
      this.overin,
      this.overout,
      this.shift,
      this.posisi);
}

class HistoryStaffState extends State<HistoryStaff> {
  Firestore firestore = Firestore.instance;
  List<HistoryItem> listHistory = List<HistoryItem>();
  String outlet, owner, city, spv, url_staff, url_staffDownload;
  bool isEmptyy = false;
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateFormat dayFormat = DateFormat.yMMMMd();
  DateFormat dayFormatFull = DateFormat.yMMMEd();
  DateFormat timeFormat = DateFormat.Hms();

  @override
  void initState() {
    super.initState();
    _getDataUserFromPref();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
      owner = prefs.getString('owner');
      city = prefs.getString('city');
      spv = prefs.getString('namaUser');
      url_staff = prefs.getString("r_staff's");
      url_staffDownload = prefs.getString("d_staff's");
      _getDataHistory();
    });
  }

  _setupTitleHeader() {
    FeedbackReportStaff titleHeader = FeedbackReportStaff(
        'LAPORAN PRESENSI KARYAWAN',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '');

    ReportController reportController = new ReportController((String response) {
      if (response == ReportController.STATUS_SUCCESS) {
        print('Success Title Header');
        _setupNama();
      } else {
        print("Error Occurred!");
      }
    });

    reportController.submitStaffReport(titleHeader, url_staff);
  }

  _setupNama() {
    FeedbackReportStaff outletReport = FeedbackReportStaff(
        'Nama', widget.name, '', '', '', '', '', '', '', '', '', '', '', '');

    ReportController reportController2 =
        new ReportController((String response) {
      if (response == ReportController.STATUS_SUCCESS) {
        print('Success Nama');
        _setupOutlet();
      } else {
        print("Error Occurred!");
      }
    });

    reportController2.submitStaffReport(outletReport, url_staff);
  }

  _setupOutlet() {
    FeedbackReportStaff outletReport = FeedbackReportStaff(
        'Outlet', outlet, '', '', '', '', '', '', '', '', '', '', '', '');

    ReportController reportController2 =
        new ReportController((String response) {
      if (response == ReportController.STATUS_SUCCESS) {
        print('Success Outlet');
        _setupSpace(10);
      } else {
        print("Error Occurred!");
      }
    });

    reportController2.submitStaffReport(outletReport, url_staff);
  }

  _setupSpace(int action) {
    FeedbackReportStaff space = FeedbackReportStaff(
        '---------',
        '---------',
        '---------',
        '---------',
        '---------',
        '---------',
        '---------',
        '---------',
        '---------',
        '---------',
        '---------',
        '---------',
        '---------',
        '---------');

    ReportController reportController = new ReportController((String response) {
      if (response == ReportController.STATUS_SUCCESS) {
        print('Success Space');
        if (action != 20) {
          _setupTitle();
        } else {
          _setupCityFooter();
        }
      } else {
        print("Error Occurred!");
      }
    });

    reportController.submitStaffReport(space, url_staff);
  }

  _setupTitle() {
    FeedbackReportStaff headReport = FeedbackReportStaff(
        'No. ',
        'Tanggal',
        'Shift',
        'Posisi',
        'Jam Masuk',
        'Jam Istirahat',
        'Jam Masuk 2',
        'Jam Keluar',
        'Jam Masuk Lembur',
        'Jam Keluar Lembur',
        'Total Jam Kerja',
        'Total Jam Istirahat',
        'Total Jam Lembur',
        'Total Jam Terlambat');

    ReportController reportController = ReportController((String response) {
      if (response == ReportController.STATUS_SUCCESS) {
        print('Success Title');
        _createStaffReport();
      } else {
        print("Error Occurred!");
      }
    });

    reportController.submitStaffReport(headReport, url_staff);
  }

  _setupCityFooter() {
    FeedbackReportStaff cityFooter = FeedbackReportStaff(
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '$city, ${dayFormatFull.format(DateTime.now())}',
        '');

    ReportController reportController = ReportController((String response) {
      if (response == ReportController.STATUS_SUCCESS) {
        print('Success City Footer');
        _setupJabatanFooter();
      } else {
        print("Error Occurred!");
      }
    });

    reportController.submitStaffReport(cityFooter, url_staff);
  }

  _setupJabatanFooter() {
    FeedbackReportStaff jabatanFooter = FeedbackReportStaff('', '', '', '', '',
        '', '', '', '', '', 'Pemilik $outlet', '', 'Supervisor $outlet', '');

    ReportController reportController = ReportController((String response) {
      if (response == ReportController.STATUS_SUCCESS) {
        print('Success Jabatan Footer');
        // _setupSpace2(action);
        _setupnameFooter();
      } else {
        print("Error Occurred!");
      }
    });

    reportController.submitStaffReport(jabatanFooter, url_staff);
  }

  _setupnameFooter() {
    FeedbackReportStaff nameFooter = FeedbackReportStaff(
        '', '', '', '', '', '', '', '', '', '', '$owner', '', '$spv', '');

    ReportController reportController = ReportController((String response) {
      if (response == ReportController.STATUS_SUCCESS) {
        print('Success Name Footer');
        Navigator.pop(context);
        showCenterShortToast();
        _gotoDownloadReport();
      } else {
        print("Error Occurred!");
      }
    });

    reportController.submitStaffReport(nameFooter, url_staff);
  }

  _getDataHistory() async {
    await firestore
        .collection('report')
        .document(outlet)
        .collection('listreport')
        .document('${DateTime.now().year}')
        .collection('${DateTime.now().month}')
        .document(widget.id)
        .collection('listreport')
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.isEmpty) {
        setState(() {
          isEmptyy = true;
        });
      } else {
        snapshot.documents.forEach((f) {
          Timestamp date = f.data['date'];
          Timestamp clockin = f.data['clockin'];
          Timestamp breakk = f.data['break'];
          Timestamp afterbreak = f.data['afterbreak'];
          Timestamp clockout = f.data['clockout'];
          Timestamp overin;
          Timestamp overout;
          if (f.data['overtimeday'] == 1) {
            overin = f.data['overtimein'];
            overout = f.data['overtimeout'];
          }

          String timeLate, overtime, breaktime, dayintime;

          if (f.data['latetotaltime'] != 0) {
            if (f.data['latetotaltime'] < 60) {
              timeLate = '${f.data['latetotaltime']} Menit';
            } else {
              int hour = f.data['latetotaltime'] ~/ 60;
              int minutes = f.data['latetotaltime'] % 60;
              timeLate =
                  '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
            }
          } else {
            timeLate = '-';
          }

          if (f.data['overtimetotaltime'] != 0) {
            if (f.data['overtimetotaltime'] < 60) {
              overtime = '${f.data['overtimetotaltime']} Menit';
            } else {
              int hour = f.data['overtimetotaltime'] ~/ 60;
              int minutes = f.data['overtimetotaltime'] % 60;
              overtime =
                  '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
            }
          } else {
            overtime = '-';
          }

          if (f.data['totalbreaktime'] != 0) {
            if (f.data['totalbreaktime'] < 60) {
              breaktime = '${f.data['totalbreaktime']} Menit';
            } else {
              int hour = f.data['totalbreaktime'] ~/ 60;
              int minutes = f.data['totalbreaktime'] % 60;
              breaktime =
                  '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
            }
          } else {
            breaktime = '-';
          }

          if (f.data['dayintotaltime'] != 0) {
            if (f.data['dayintotaltime'] < 60) {
              dayintime = '${f.data['dayintotaltime']} Menit';
            } else {
              int hour = f.data['dayintotaltime'] ~/ 60;
              int minutes = f.data['dayintotaltime'] % 60;
              dayintime =
                  '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
            }
          } else {
            dayintime = '-';
          }

          if (f.data['overtimeday'] == 1) {
            HistoryItem item = new HistoryItem(
                date.toDate(),
                f.data['dayin'],
                dayintime,
                f.data['lateday'],
                timeLate,
                f.data['overtimeday'],
                overtime,
                breaktime,
                clockin.toDate(),
                breakk.toDate(),
                afterbreak.toDate(),
                clockout.toDate(),
                overin.toDate(),
                overout.toDate(),
                f.data['shift'],
                f.data['pos']);
            listHistory.add(item);
          } else {
            HistoryItem item = new HistoryItem(
                date.toDate(),
                f.data['dayin'],
                dayintime,
                f.data['lateday'],
                timeLate,
                f.data['overtimeday'],
                overtime,
                breaktime,
                clockin.toDate(),
                breakk.toDate(),
                afterbreak.toDate(),
                clockout.toDate(),
                DateTime(2020, 01, 01),
                DateTime(2020, 01, 01),
                f.data['shift'],
                f.data['pos']);
            listHistory.add(item);
          }
        });
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  _createStaffReport() async {
    for (int i = 0; i < listHistory.length; i++) {
      FeedbackReportStaff feedbackReport;
      if (listHistory[i].overtime == 1) {
        feedbackReport = FeedbackReportStaff(
            '${i + 1}',
            dayFormat.format(listHistory[i].date),
            listHistory[i].shift,
            listHistory[i].posisi,
            timeFormat.format(listHistory[i].clockin),
            timeFormat.format(listHistory[i].breakk),
            timeFormat.format(listHistory[i].afterbreak),
            timeFormat.format(listHistory[i].clockout),
            timeFormat.format(listHistory[i].overin),
            timeFormat.format(listHistory[i].overout),
            listHistory[i].dayintotaltime,
            listHistory[i].totalbreaktime,
            listHistory[i].overtimetotaltime,
            listHistory[i].latetotaltime);
      } else {
        feedbackReport = FeedbackReportStaff(
            '${i + 1}',
            dayFormat.format(listHistory[i].date),
            listHistory[i].shift,
            listHistory[i].posisi,
            timeFormat.format(listHistory[i].clockin),
            timeFormat.format(listHistory[i].breakk),
            timeFormat.format(listHistory[i].afterbreak),
            timeFormat.format(listHistory[i].clockout),
            '-',
            '-',
            listHistory[i].dayintotaltime,
            listHistory[i].totalbreaktime,
            '-',
            listHistory[i].latetotaltime);
      }

      ReportController reportController = ReportController((String response) {
        print("Response: $response");
        if (response == ReportController.STATUS_SUCCESS) {
          print("Feedback Submitted");
          if (i == listHistory.length - 1) {
            _setupSpace(20);
          }
        } else {
          print("Error Occurred!");
        }
      });

      print("Submitting Feedback");
      reportController.submitStaffReport(feedbackReport, url_staff);
    }
  }

  _gotoDownloadReport() async {
    String url = url_staffDownload;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Tidak Dapat Membuka Link ' + url;
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
        barrierDismissible: false,
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

  void _showAlertDialog(String title, String dayintime, String breaktime,
      String overtime, String latetime) {
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
                          left: 20.0, top: 30.0, right: 20.0),
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
                            height: 30.0,
                          ),
                          Divider(
                            height: 0.5,
                          ),
                          ListTile(
                            title: Text(
                              'Dayin Time : ' + dayintime,
                            ),
                          ),
                          Divider(
                            height: 0.5,
                          ),
                          ListTile(
                            title: Text(
                              'Break Time : ' + breaktime,
                            ),
                          ),
                          Divider(
                            height: 0.5,
                          ),
                          ListTile(
                            title: Text(
                              'Overtime : ' + overtime,
                            ),
                          ),
                          Divider(
                            height: 0.5,
                          ),
                          ListTile(
                            title: Text(
                              'Late Time : ' + latetime,
                            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Theme.of(context).backgroundColor
              : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.name),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () {
                _prosesDialog();
                _setupTitleHeader();
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (listHistory.length > 0)
              ListView.builder(
                  itemCount: listHistory.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          onTap: () {
                            _showAlertDialog(
                                dateFormat.format(listHistory[index].date),
                                listHistory[index].dayintotaltime,
                                listHistory[index].totalbreaktime,
                                listHistory[index].overtimetotaltime,
                                listHistory[index].latetotaltime);
                          },
                          leading: Icon(Ionicons.ios_clock,
                              color: listHistory[index].lateday == 1
                                  ? Colors.red
                                  : Colors.green),
                          title: Text(
                            dateFormat.format(listHistory[index].date),
                          ),
                          subtitle: Text(listHistory[index].lateday == 1
                              ? 'Late total time : ${listHistory[index].latetotaltime}'
                              : 'Ontime!'),
                        ),
                        Divider(
                          height: 0.5,
                        )
                      ],
                    );
                  })
            else if (!isEmptyy)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Image.asset(
                        'assets/images/nodata.png',
                        width: MediaQuery.of(context).size.width * 0.4,
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
                              Theme.of(context).textTheme.subtitle.fontSize),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
