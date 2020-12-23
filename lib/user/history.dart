import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HistoryState();
  }
}

class HistoryItem {
  final String id, shift, lates;
  final DateTime date, start, end;

  HistoryItem(this.id, this.shift, this.lates, this.date, this.start, this.end);
}

class HistoryState extends State<History> {
  final Firestore firestore = Firestore.instance;
  List<HistoryItem> listHistory = new List<HistoryItem>();
  bool isEmptyy;
  String id, outlet;
  int attend, permission, dayOff;
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateFormat timeFormat = DateFormat.Hm();

  @override
  void initState() {
    super.initState();
    getDataUserFromPref();
  }

  void getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('idUser');
      outlet = prefs.getString('outletUser');
      _getListHistory();
      _getDataMonth();
      _getCountDayOff();
    });
  }

  _getCountDayOff() {
    firestore
        .collection('user')
        .document(outlet)
        .collection('listuser')
        .document(id)
        .collection('${DateTime.now().year}')
        .document('count')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data.isEmpty) {
      } else {
        if (snapshot.data['dayOff'] != null) {
          setState(() {
            dayOff = snapshot.data['dayOff'];
          });
        } else {
          dayOff = 0;
        }
      }
    });
  }

  _getDataMonth() {
    firestore
        .collection('history')
        .document(outlet)
        .collection('listhistory')
        .document('${DateTime.now().year}')
        .collection(id)
        .document('${DateTime.now().month}')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data.isEmpty) {
      } else {
        if (snapshot.data['attend'] != null) {
          setState(() {
            attend = snapshot.data['attend'];
          });
        } else {
          attend = 0;
        }
        if (snapshot.data['permission'] != null) {
          setState(() {
            permission = snapshot.data['permission'];
          });
        } else {
          permission = 0;
        }
      }
    });
  }

  _getListHistory() {
    firestore
        .collection('history')
        .document(outlet)
        .collection('listhistory')
        .document('${DateTime.now().year}')
        .collection(id)
        .document('${DateTime.now().month}')
        .collection('listhistory')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.documents.isEmpty) {
      } else {
        snapshot.documents.forEach((f) {
          Timestamp date = f.data['date'];
          Timestamp start = f.data['start'];
          Timestamp end = f.data['end'];
          String latetime;
          if (f.data['late'] != 0) {
            if (f.data['late'] < 60) {
              latetime = '${f.data['late']} Menit';
            } else {
              int hour = f.data['late'] ~/ 60;
              int minutes = f.data['late'] % 60;
              latetime =
                  '${hour.toString().padLeft(2, "0")} Jam ${minutes.toString().padLeft(2, "0")} Menit';
            }
          } else {
            latetime = 'On Time';
          }
          HistoryItem item = new HistoryItem(f.documentID, f.data['shift'],
              latetime, date.toDate(), start.toDate(), end.toDate());
          setState(() {
            listHistory.add(item);
          });
        });
      }
    });
    if (mounted) {
      if (listHistory.length == 0) {
        setState(() {
          isEmptyy = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
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
                  // Image.asset(
                  //   'assets/images/img9.png',
                  //   width: MediaQuery.of(context).size.width * 0.5,
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 30.0, right: 30.0, bottom: 20.0, top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(15),
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.blue[300]
                                        : Colors.blue.withAlpha(50),
                              ),
                              child: Center(
                                  child: Text(
                                'Attend',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14),
                              )),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              attend != null ? '$attend' : '0',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 55.0,
                                  fontFamily: 'Google'),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'day',
                              style:
                                  TextStyle(fontFamily: 'Sans', fontSize: 14),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(15),
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.brown[300]
                                        : Colors.brown.withAlpha(50),
                              ),
                              child: Center(
                                  child: Text(
                                'Permission',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14),
                              )),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              permission != null ? '$permission' : '0',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 55.0,
                                  fontFamily: 'Google'),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'day',
                              style:
                                  TextStyle(fontFamily: 'Sans', fontSize: 14),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(15),
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.red[300]
                                        : Colors.red.withAlpha(50),
                              ),
                              child: Center(
                                  child: Text(
                                'Days Off',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14),
                              )),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              '$dayOff',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 55.0,
                                  fontFamily: 'Google'),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'day',
                              style:
                                  TextStyle(fontFamily: 'Sans', fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                          'My History',
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.headline.fontSize,
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
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'All your history',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.caption.color,
                        fontFamily: 'Sans',
                        fontWeight: FontWeight.bold),
                  ),
                  if (listHistory.length > 0)
                    ListView.builder(
                      itemCount: listHistory.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(top: 15, bottom: 15),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 3),
                                  blurRadius: 8,
                                )
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                dateFormat.format(listHistory[index].date),
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .subhead
                                        .fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sans'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(
                                height: 0,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                listHistory[index].shift,
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontFamily: 'Google',
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    timeFormat
                                            .format(listHistory[index].start) +
                                        ' AM',
                                    style: TextStyle(
                                      fontFamily: 'Sans',
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .fontSize,
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .color,
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
                                    timeFormat.format(listHistory[index].end) +
                                        ' PM',
                                    style: TextStyle(
                                      fontFamily: 'Sans',
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .fontSize,
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .color,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              if (listHistory[index].lates != 'On Time')
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Icon(
                                      Feather.clock,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? Colors.red[400]
                                          : Colors.red[300],
                                      size: 15.0,
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      'Late : ',
                                      style: TextStyle(
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? Colors.red[400]
                                            : Colors.red[300],
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .fontSize,
                                        fontFamily: 'Sans',
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      listHistory[index].lates,
                                      style: TextStyle(
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.light
                                            ? Colors.red[400]
                                            : Colors.red[300],
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .fontSize,
                                        fontFamily: 'Sans',
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  listHistory[index].lates,
                                  style: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.green[400]
                                        : Colors.green[300],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .fontSize,
                                    fontFamily: 'Sans',
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    )
                  else if (!isEmptyy)
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 150.0, bottom: 30.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ))
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
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subtitle
                                    .fontSize),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
