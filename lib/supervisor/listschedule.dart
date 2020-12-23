import 'package:absenin/supervisor/addschedule.dart';
import 'package:absenin/supervisor/detailschedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListSchedule extends StatefulWidget {
  final String shift;
  final DateTime month,
      startfull,
      endfull,
      startpart,
      endpart,
      startfull2,
      endfull2,
      startpart2,
      endpart2;

  const ListSchedule(
      {Key key,
      @required this.shift,
      @required this.month,
      @required this.startfull,
      @required this.endfull,
      @required this.startpart,
      @required this.endpart,
      @required this.startfull2,
      @required this.endfull2,
      @required this.startpart2,
      @required this.endpart2})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListScheduleState();
  }
}

class DayItem {
  final String id;
  final DateTime startFull,
      endFull,
      startPart,
      endPart,
      startFull2,
      endFull2,
      startPart2,
      endPart2;
  bool check;

  DayItem(
      this.id,
      this.startFull,
      this.endFull,
      this.startPart,
      this.endPart,
      this.startFull2,
      this.endFull2,
      this.startPart2,
      this.endPart2,
      this.check);
}

class ListScheduleState extends State<ListSchedule> {
  final Firestore firestore = Firestore.instance;
  List<DayItem> listDay = new List<DayItem>();
  List<DayItem> listDelete = new List<DayItem>();
  DateFormat timeFormat = DateFormat.Hm();
  DateFormat monthFormat = DateFormat.yMMMM();
  String outlet;

  int dayCountSelected = 0;
  bool daySelected = false;

  @override
  void initState() {
    super.initState();
    _getDataUserFromPref();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
      _getListSchedule();
    });
  }

  _getListSchedule() {
    firestore
        .collection('schedule')
        .document(outlet)
        .collection('scheduledetail')
        .document('${widget.month.year}')
        .collection('${widget.month.month}')
        .document(widget.shift)
        .collection('listday')
        .orderBy('fullstart')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.documents.isEmpty) {
      } else {
        listDay.clear();
        snapshot.documents.forEach((f) {
          Timestamp startFull = f.data['fullstart'];
          Timestamp endFull = f.data['fullend'];
          Timestamp startPart = f.data['partstart'];
          Timestamp endPart = f.data['partend'];
          Timestamp startFull2 = f.data['fullstart2'];
          Timestamp endFull2 = f.data['fullend2'];
          Timestamp startPart2 = f.data['partstart2'];
          Timestamp endPart2 = f.data['partend2'];
          DayItem item = new DayItem(
              f.documentID,
              startFull.toDate(),
              endFull.toDate(),
              startPart.toDate(),
              endPart.toDate(),
              startFull2.toDate(),
              endFull2.toDate(),
              startPart2.toDate(),
              endPart2.toDate(),
              false);
          setState(() {
            listDay.add(item);
          });
        });
      }
    });
  }

  _deleteListSchedule() async {
    for (int i = 0; i < listDay.length; i++) {
      if (listDay[i].check) {
        listDelete.add(listDay[i]);
      }
    }
    for (int i = 0; i < listDelete.length; i++) {
      await firestore
          .collection('schedule')
          .document(outlet)
          .collection('scheduledetail')
          .document('${widget.month.year}')
          .collection('${widget.month.month}')
          .document(widget.shift)
          .collection('listday')
          .document(listDelete[i].id)
          .delete();
      if (mounted) {
        print('BERHASIL DELETE => ${listDelete[i].id}');
      }
    }
    Navigator.pop(context);
    setState(() {
      listDelete.clear();
      daySelected = false;
      dayCountSelected = 0;
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

  void _showAlertDialog() {
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
                          'Delete this Day?',
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
                      'assets/images/delete.png',
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
                            _deleteListSchedule();
                            Navigator.pop(context);
                            _prosesDialog();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Theme.of(context).backgroundColor
                  : Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(daySelected ? '$dayCountSelected' : widget.shift),
            actions: <Widget>[
              if (daySelected && listDay.length > 0)
                FlatButton(
                  onPressed: () {
                    _showAlertDialog();
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 24.0,
                  ),
                )
            ],
          ),
          floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 24.0,
              ),
              onPressed: () {
                Navigator.of(context).push(_createRoute(AddSchedule(
                  title: widget.shift,
                  month: widget.month,
                  startfull: widget.startfull,
                  endfull: widget.endfull,
                  startpart: widget.startpart,
                  endpart: widget.endpart,
                  startfull2: widget.startfull2,
                  endfull2: widget.endfull2,
                  startpart2: widget.startpart2,
                  endpart2: widget.endpart2,
                )));
              }),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListView.builder(
                    itemCount: listDay.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(
                        children: <Widget>[
                          Material(
                              color: listDay[index].check
                                  ? MediaQuery.of(context).platformBrightness ==
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
                                  '${listDay[index].id} ${monthFormat.format(widget.month)}',
                                  style: TextStyle(
                                      fontFamily: 'Google',
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .fontSize),
                                ),
                                subtitle: Text(
                                  'View details',
                                  style: TextStyle(
                                      fontFamily: 'Sans',
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .fontSize),
                                ),
                                trailing: listDay[index].check
                                    ? Icon(
                                        Icons.check_circle,
                                        size: 18.0,
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? Colors.green
                                            : Colors.green[400],
                                      )
                                    : Icon(Feather.chevron_right),
                                onLongPress: () {
                                  setState(() {
                                    listDay[index].check = true;
                                    daySelected = true;
                                    dayCountSelected++;
                                  });
                                },
                                onTap: () {
                                  if (daySelected) {
                                    if (listDay[index].check == true) {
                                      setState(() {
                                        listDay[index].check = false;
                                        dayCountSelected--;
                                        if (dayCountSelected == 0) {
                                          daySelected = false;
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        listDay[index].check = true;
                                        dayCountSelected++;
                                      });
                                    }
                                  } else {
                                    Navigator.of(context)
                                        .push(_createRoute(DetailSchedule(
                                      shift: widget.shift,
                                      id: listDay[index].id,
                                      date: widget.month,
                                      startFull: listDay[index].startFull,
                                      endFull: listDay[index].endFull,
                                      startPart: listDay[index].startPart,
                                      endPart: listDay[index].endPart,
                                      startFull2: listDay[index].startFull2,
                                      endFull2: listDay[index].endFull2,
                                      startPart2: listDay[index].startPart2,
                                      endPart2: listDay[index].endPart2,
                                    )));
                                  }
                                },
                              )),
                          if (index < listDay.length - 1)
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(left: 70.0),
                              color: Theme.of(context).dividerColor,
                            )
                          else
                            Divider(
                              height: 0.0,
                            )
                        ],
                      );
                    })
              ],
            ),
          ),
        ),
        onWillPop: () async {
          bool exit = false;
          if (daySelected) {
            setState(() {
              daySelected = false;
            });
            for (int i = 0; i < listDay.length; i++) {
              if (listDay[i].check) {
                setState(() {
                  listDay[i].check = false;
                });
              }
            }
            dayCountSelected = 0;
          } else {
            exit = true;
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
