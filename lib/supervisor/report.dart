import 'package:absenin/reportsetup/reportcontroler.dart';
import 'package:absenin/reportsetup/reportmodel.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReportPagrState();
  }
}

class ReportItem {
  DateTime date;
  double dayin;
  double notattend;
  double dayoff;
  double permission;
  double ontime;
  double latee;

  ReportItem(this.date, this.dayin, this.notattend, this.dayoff, this.permission,
      this.ontime, this.latee);
}

// class ReportField{
  
//   String name, dayin, dayintotaltime, totalbreaktime, overtime, overtimetotaltime, latee, latetotaltime, dayoff, permission, notattend;

//   ReportField(this.name, this.dayin, this.dayintotaltime, this.totalbreaktime, this.overtime, this.overtimetotaltime, this.latee, this.latetotaltime, this.dayoff, this.permission, this.notattend);
// }

class ReportPagrState extends State<ReportPage> {
  DateFormat monthFormat = DateFormat.yMMMM();
  DateFormat dayFormat = DateFormat.MMMEd();
  DateFormat dayFormatFull = DateFormat.yMMMEd();
  List<DateTime> selectedDates = List();
  List<ReportItem> listReport = new List<ReportItem>();
  int touchedIndex;
  bool alphaVal = false;
  bool sakitVal = false;
  bool izinVal = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Firestore firestore = Firestore.instance;
  List<String> listID = new List<String>();
  List listNama = ['Dany Pratama Saputra', 'Gabriella renata', 'Alyssa'];
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
      _getUserFromDb();
    });
  }

  _showRangeCalendarDialog() async {
    List<DateTime> choosedate = await DateRangePicker.showDatePicker(
      context: context, 
      initialFirstDate: DateTime.now(), 
      initialLastDate: Jiffy().add(days: 7), 
      firstDate: Jiffy().subtract(years: 1), 
      lastDate: Jiffy().add(years: 1)
    );
    if(mounted){
      if(choosedate != null && choosedate.length == 2){
        setState(() {
          selectedDates = choosedate;
          _customReport();
          _prosesDialog();
        });
      }
    }
  }

  _getUserFromDb() async {
    await firestore
      .collection('user')
      .document(outlet)
      .collection('listuser')
      .where('role', isEqualTo: 1)
      .getDocuments()
      .then((snapshot){
        if(snapshot.documents.length > 0){
          snapshot.documents.forEach((f){
            listID.add(f.documentID);
          });
        }
      });

      if(mounted){
        setState(() {});
        print('List User : $listID');
        _getGraphicValue();
      }
  }

  _monthlyReport() async {

    for(int i = 0; i < listID.length; i++){
      await firestore
        .collection('report')
        .document(outlet)
        .collection('listreport')
        .document('${DateTime.now().year}')
        .collection('${DateTime.now().month}')
        .document(listID[i])
        .collection('listreport')
        .getDocuments()
        .then((snapshot){
          if(snapshot.documents.length > 0){
            String name;
            int dayin = 0, dayintotaltime = 0, totalbreaktime = 0, overtime = 0, overtimetotaltime = 0, latee = 0, latetotaltime = 0, dayoff = 0, permission = 0, notattend = 0;
            snapshot.documents.forEach((f){
              name = f.data['name'];
              var dayinF = f.data['dayin'];
              var dayintotaltimeF = f.data['dayintotaltime'];
              var totalbreaktimeF = f.data['totalbreaktime'];
              var overtimedayF = f.data['overtimeday'];
              var overtimetotaltimeF = f.data['overtimetotaltime'];
              var latedayF = f.data['lateday'];
              var latetotaltimeF = f.data['latetotaltime']; 
              if(dayinF == 0){
                notattend++;
              } else if(dayinF == 1){
                dayin++;
              } else if(dayinF == 2){
                dayoff++;
              } else {
                permission++;
              }
              dayintotaltime += dayintotaltimeF;
              totalbreaktime += totalbreaktimeF;
              if(overtimedayF == 1){
                overtime++;
              }
              overtimetotaltime += overtimetotaltimeF;
              latee += latedayF;
              latetotaltime += latetotaltimeF;
            });
            String dayintotaltimeS;
            if(dayintotaltime != 0){
              int hour = dayintotaltime ~/ 60;
              int minutes = dayintotaltime % 60;
              dayintotaltimeS = '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
            } else {
              dayintotaltimeS = '-';
            }

            String totalbreaktimeS;
            if(totalbreaktime != 0){
              int hour = totalbreaktime ~/ 60;
              int minutes = totalbreaktime % 60;
              totalbreaktimeS = '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
            } else {
              totalbreaktimeS = '-';
            }
            
            String overtimetotaltimeS;
            if(overtimetotaltime != 0){
              int hour = overtimetotaltime ~/ 60;
              int minutes = overtimetotaltime % 60;
              overtimetotaltimeS = '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
            } else {
              overtimetotaltimeS = '-';
            }
            
            String latetotaltimeS;
            if(latetotaltime != 0){
              int hour = latetotaltime ~/ 60;
              int minutes = latetotaltime % 60;
              latetotaltimeS = '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
            } else {
              latetotaltimeS = '-';
            }

            FeedbackReport feedbackReport = FeedbackReport(
              name, dayin.toString(), dayintotaltimeS, totalbreaktimeS, overtime.toString(), overtimetotaltimeS, latee.toString(), latetotaltimeS, dayoff.toString(), permission.toString(), notattend.toString());

            ReportController reportController = ReportController((String response){

              print("Response: $response");
              if(response == ReportController.STATUS_SUCCESS){
                print("Feedback Submitted");
              } else {
                print("Error Occurred!");
              }

            });

            print("Submitting Feedback");
            reportController.submitReport(feedbackReport);
          }
        });
    }
    Navigator.pop(context);
    showCenterShortToast();
  }

  _customReport() async {

    // FeedbackReport periodeReport = FeedbackReport(
    //   'Periode', '${dayFormat.format(selectedDates[0])} - ${dayFormatFull.format(selectedDates[selectedDates.length - 1])}', '', '', '', '', '', '', '', '', '');

    // ReportController reportController = ReportController((String response){

    //   print("Response: $response");
    //   if(response == ReportController.STATUS_SUCCESS){
    //     print("Feedback Submitted");
    //   } else {
    //     print("Error Occurred!");
    //   }

    // });

    // reportController.submitReport(periodeReport);

    // FeedbackReport outletReport = FeedbackReport(
    //   'Outlet', outlet, '', '', '', '', '', '', '', '', '');

    // ReportController reportController2 = ReportController((String response){

    //   print("Response: $response");
    //   if(response == ReportController.STATUS_SUCCESS){
    //     print("Feedback Submitted");
    //   } else {
    //     print("Error Occurred!");
    //   }

    // });

    // reportController2.submitReport(outletReport);

    // FeedbackReport space = FeedbackReport(
    //   '', '', '', '', '', '', '', '', '', '', '');

    // ReportController reportController3 = ReportController((String response){

    //   print("Response: $response");
    //   if(response == ReportController.STATUS_SUCCESS){
    //     print("Feedback Submitted");
    //   } else {
    //     print("Error Occurred!");
    //   }

    // });

    // reportController3.submitReport(space);

    // FeedbackReport headReport = FeedbackReport(
    //   'Nama', 'Masuk Kerja', 'Total Jam Kerja', 'Total Jam Istirahat', 'Lembur', 'Total Jam Lembur', 'Terlambat', 'Total Jam Terlambat', 'Total Cuti', 'Total Ijin', 'Total Tidak Masuk');

    // ReportController reportController4 = ReportController((String response){

    //   print("Response: $response");
    //   if(response == ReportController.STATUS_SUCCESS){
    //     print("Feedback Submitted");
    //   } else {
    //     print("Error Occurred!");
    //   }

    // });

    // reportController4.submitReport(headReport);

    for(int i = 0; i < listID.length; i++){
      await firestore
        .collection('report')
        .document(outlet)
        .collection('listreport')
        .document('${DateTime.now().year}')
        .collection('${DateTime.now().month}')
        .document(listID[i])
        .collection('listreport')
        .where('date', isGreaterThan: Jiffy(selectedDates[0]).subtract(days: 1))
        .where('date', isLessThan: Jiffy(selectedDates[selectedDates.length - 1]).add(days: 1))
        .getDocuments()
        .then((snapshot){
          if(snapshot.documents.length > 0){
            String name;
            int dayin = 0, dayintotaltime = 0, totalbreaktime = 0, overtime = 0, overtimetotaltime = 0, latee = 0, latetotaltime = 0, dayoff = 0, permission = 0, notattend = 0;
            snapshot.documents.forEach((f){
              Timestamp time = f.data['date'];
              var times = time.toDate();
              print('Tanggal : $times');
              name = f.data['name'];
              var dayinF = f.data['dayin'];
              var dayintotaltimeF = f.data['dayintotaltime'];
              var totalbreaktimeF = f.data['totalbreaktime'];
              var overtimedayF = f.data['overtimeday'];
              var overtimetotaltimeF = f.data['overtimetotaltime'];
              var latedayF = f.data['lateday'];
              var latetotaltimeF = f.data['latetotaltime']; 
              if(dayinF == 0){
                notattend++;
              } else if(dayinF == 1){
                dayin++;
              } else if(dayinF == 2){
                dayoff++;
              } else {
                permission++;
              }
              dayintotaltime += dayintotaltimeF;
              totalbreaktime += totalbreaktimeF;
              if(overtimedayF == 1){
                overtime++;
              }
              overtimetotaltime += overtimetotaltimeF;
              latee += latedayF;
              latetotaltime += latetotaltimeF;
            });
            String dayintotaltimeS;
            if(dayintotaltime != 0){
              if(dayintotaltime < 60){
                dayintotaltimeS = '$dayintotaltime Menit';
              } else {
                int hour = dayintotaltime ~/ 60;
                int minutes = dayintotaltime % 60;
                dayintotaltimeS = '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
              }
            } else {
              dayintotaltimeS = '-';
            }

            String totalbreaktimeS;
            if(totalbreaktime != 0){
              if(totalbreaktime < 60){
                totalbreaktimeS = '$totalbreaktime Menit';
              } else {
                int hour = totalbreaktime ~/ 60;
                int minutes = totalbreaktime % 60;
                totalbreaktimeS = '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
              }
            } else {
              totalbreaktimeS = '-';
            }
            
            String overtimetotaltimeS;
            if(overtimetotaltime != 0){
              if(overtimetotaltime < 60){
                overtimetotaltimeS = '$overtimetotaltime Menit';
              } else {
                int hour = overtimetotaltime ~/ 60;
                int minutes = overtimetotaltime % 60;
                overtimetotaltimeS = '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
              }
            } else {
              overtimetotaltimeS = '-';
            }
            
            String latetotaltimeS;
            if(latetotaltime != 0){
              if(latetotaltime < 60){
                latetotaltimeS = '$latetotaltime Menit';
              } else {
                int hour = latetotaltime ~/ 60;
                int minutes = latetotaltime % 60;
                latetotaltimeS = '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
              }
            } else {
              latetotaltimeS = '-';
            }

            FeedbackReport feedbackReport = FeedbackReport(
              name, dayin.toString(), dayintotaltimeS, totalbreaktimeS, overtime.toString(), overtimetotaltimeS, latee.toString(), latetotaltimeS, dayoff.toString(), permission.toString(), notattend.toString());

            ReportController reportController = ReportController((String response){

              print("Response: $response");
              if(response == ReportController.STATUS_SUCCESS){
                print("Feedback Submitted");
              } else {
                print("Error Occurred!");
              }

            });

            print("Submitting Feedback");
            reportController.submitReport(feedbackReport);
          }
        });
    }
    if(mounted){
      Navigator.pop(context);
      showCenterShortToast();
      _gotoDownloadReport();
    }
  }

  _getGraphicValue() async {

    for(int i = 0; i < listID.length; i++){
      await firestore
        .collection('report')
        .document(outlet)
        .collection('listreport')
        .document('${DateTime.now().year}')
        .collection('${DateTime.now().month}')
        .document(listID[i])
        .collection('listreport')
        .orderBy('date')
        .getDocuments()
        .then((snapshot){
          if(snapshot.documents.length > 0){
            int indexDay = 0;
            snapshot.documents.forEach((f){
              Timestamp date = f.data['date'];
              print('Ada loh : ${date.toDate()}');
              var dayinF = f.data['dayin'];
              var latetotaltimeF = f.data['latetotaltime']; 
              double dayin = 0, notattend = 0, dayoff = 0, permission = 0, ontime = 0, latee = 0;
              if(dayinF == 0){
                notattend++;
              } else if(dayinF == 1){
                dayin++;
                if(latetotaltimeF > 0){
                  latee++;
                } else {
                  ontime++;
                }
              } else if(dayinF == 2){
                dayoff++;
              } else {
                permission++;
              }

              if(listReport.length < 1){
                ReportItem item = new ReportItem(date.toDate(), dayin, notattend, dayoff, permission, ontime, latee);
                listReport.add(item);
              } else {
                listReport[indexDay].dayin += dayin; 
                listReport[indexDay].notattend += notattend;
                listReport[indexDay].dayoff += dayoff;
                listReport[indexDay].permission += permission;
                listReport[indexDay].ontime += ontime;
                listReport[indexDay].latee += latee;
              }
              indexDay++;
            });
          }
        });
    }

    if(mounted){
      setState(() {});
    }

  }

  _gotoDownloadReport() async {
    String url = 'https://docs.google.com/spreadsheets/d/1kjB8N5zhlupX3gq2tb9NskII3EuSpMi9OJNkgOVYgDs/export?format=xlsx';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Tidak Dapat Membuka Link '+url;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Report',
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0)),
                child: Container(
                  padding: EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 25.0, bottom: 35.0),
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'You can download attendance reports based on the available period',
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.title.fontSize,
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 35.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: (){
                              _showRangeCalendarDialog();
                              // _customReport();
                              // _prosesDialog();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.width / 3,
                                decoration: BoxDecoration(
                                    color: Colors.indigo[50],
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Center(
                                        child: Container(
                                          width: 50.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  offset: Offset(0, 3),
                                                  blurRadius: 8,
                                                )
                                              ]),
                                          child: Center(
                                            child: Text(
                                              'C',
                                              style: TextStyle(
                                                  fontFamily: 'Google',
                                                  color: Colors.indigo,
                                                  fontSize: Theme.of(context)
                                                      .textTheme
                                                      .headline
                                                      .fontSize),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Text(
                                        'Custom',
                                        style: TextStyle(
                                          fontFamily: 'Google',
                                          color: Colors.indigo,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .fontSize,
                                          // fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                          GestureDetector(
                            onTap: (){
                              _monthlyReport();
                              _prosesDialog();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.width / 3,
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Center(
                                        child: Container(
                                          width: 50.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  offset: Offset(0, 3),
                                                  blurRadius: 8,
                                                )
                                              ]),
                                          child: Center(
                                            child: Text(
                                              'M',
                                              style: TextStyle(
                                                  fontFamily: 'Google',
                                                  color: Colors.blue,
                                                  fontSize: Theme.of(context)
                                                      .textTheme
                                                      .headline
                                                      .fontSize),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Text(
                                        'Monthly',
                                        style: TextStyle(
                                          fontFamily: 'Google',
                                          color: Colors.blue,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .fontSize,
                                          // fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 25.0, bottom: 10.0),
                child: Text(
                  'Attendance chart',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.caption.color,
                      fontFamily: 'Sans',
                      fontWeight: FontWeight.bold),
                ),
              ),
              if(listReport.length > 0)
              ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: BezierChart(
                            fromDate: Jiffy().subtract(days: (DateTime.now().day - 1)),
                            toDate: DateTime.now(),
                            bezierChartScale: BezierChartScale.WEEKLY,
                            selectedDate: DateTime.now(),
                            series: [
                              BezierLine(
                                label: "Masuk",
                                lineColor: Colors.blue[300],
                                lineStrokeWidth: 3.0,
                                onMissingValue: (dateTime) {
                                  return 0.0;
                                },
                                data: [
                                  for (int i = 0; i < listReport.length; i++)
                                    DataPoint<DateTime>(
                                        value: listReport[i].dayin,
                                        xAxis: listReport[i].date),
                                ],
                              ),
                              if (alphaVal)
                                BezierLine(
                                  label: "Alpha",
                                  lineColor: Colors.orange[300],
                                  lineStrokeWidth: 3.0,
                                  onMissingValue: (dateTime) {
                                    return 0.0;
                                  },
                                  data: [
                                    for (int i = 0; i < listReport.length; i++)
                                      DataPoint<DateTime>(
                                          value: listReport[i].notattend,
                                          xAxis: listReport[i].date),
                                  ],
                                ),
                              if (sakitVal)
                                BezierLine(
                                  label: "Cuti",
                                  lineColor: Colors.deepOrange[300],
                                  lineStrokeWidth: 3.0,
                                  onMissingValue: (dateTime) {
                                    return 0.0;
                                  },
                                  data: [
                                    for (int i = 0; i < listReport.length; i++)
                                      DataPoint<DateTime>(
                                          value: listReport[i].dayoff,
                                          xAxis: listReport[i].date),
                                  ],
                                ),
                              if (izinVal)
                                BezierLine(
                                  label: "Izin",
                                  lineColor: Colors.brown[300],
                                  lineStrokeWidth: 3.0,
                                  onMissingValue: (dateTime) {
                                    return 0.0;
                                  },
                                  data: [
                                    for (int i = 0; i < listReport.length; i++)
                                      DataPoint<DateTime>(
                                          value: listReport[i].permission,
                                          xAxis: listReport[i].date),
                                  ],
                                ),
                              BezierLine(
                                label: "On Time",
                                lineColor: Colors.green[300],
                                lineStrokeWidth: 3.0,
                                onMissingValue: (dateTime) {
                                  return 0.0;
                                },
                                data: [
                                  for (int i = 0; i < listReport.length; i++)
                                    DataPoint<DateTime>(
                                        value: listReport[i].ontime,
                                        xAxis: listReport[i].date),
                                ],
                              ),
                              BezierLine(
                                label: "Late",
                                lineColor: Colors.red[300],
                                lineStrokeWidth: 3.0,
                                onMissingValue: (dateTime) {
                                  return 0.0;
                                },
                                data: [
                                  for (int i = 0; i < listReport.length; i++)
                                    DataPoint<DateTime>(
                                        value: listReport[i].latee,
                                        xAxis: listReport[i].date),
                                ],
                              ),
                            ],
                            config: BezierChartConfig(
                                verticalIndicatorStrokeWidth: 5.0,
                                verticalIndicatorColor:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.black12
                                        : Colors.white12,
                                showVerticalIndicator: true,
                                verticalIndicatorFixedPosition: false,
                                backgroundGradient: LinearGradient(
                                  colors: [
                                    // Colors.indigo[400],
                                    Color.fromRGBO(69, 104, 220, 1),
                                    // Color.fromRGBO(71, 118, 230, 1),
                                    Color.fromRGBO(142, 84, 233, 1),
                                    // Color.fromRGBO(176, 106, 179, 1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                backgroundColor:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[400]
                                        : Theme.of(context).backgroundColor,
                                footerHeight: 55.0,
                                bubbleIndicatorColor: Colors.white,
                                bubbleIndicatorLabelStyle: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'Sans',
                                ),
                                bubbleIndicatorTitleStyle: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Google',
                                ),
                                bubbleIndicatorValueStyle: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: 'Sans',
                                ),
                                xAxisTextStyle: TextStyle(
                                    color: MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : Colors.white60,
                                    fontFamily: 'Google',
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .fontSize),
                                yAxisTextStyle: TextStyle(
                                    color: MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : Colors.white60,
                                    fontFamily: 'Google',
                                    fontSize: Theme.of(context).textTheme.caption.fontSize),
                                startYAxisFromNonZeroValue: true,
                                stepsYAxis: 2,
                                displayYAxis: true,
                                updatePositionOnTap: true),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 20.0, bottom: 20.0),
                          child: Row(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Alpha"),
                                  Checkbox(
                                    value: alphaVal,
                                    onChanged: (bool value) {
                                      setState(() {
                                        alphaVal = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Cuti"),
                                  Checkbox(
                                    value: sakitVal,
                                    onChanged: (bool value) {
                                      setState(() {
                                        sakitVal = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Izin"),
                                  Checkbox(
                                    value: izinVal,
                                    onChanged: (bool value) {
                                      setState(() {
                                        izinVal = value;
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
                  )
                )
                else
                Center(
                  child: Padding(padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                    ),
                  ),
                )
            ],
          ),
        ));
  }
}
