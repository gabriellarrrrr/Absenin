import 'package:absenin/supervisor/addschedule.dart';
import 'package:absenin/supervisor/detailschedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListSchedule extends StatefulWidget {

  final String shift;
  final DateTime month;

  const ListSchedule({Key key, @required this.shift, @required this.month}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ListScheduleState();
  }
}

class DayItem {
  final String id;
  final DateTime startFull, endFull, startPart, endPart;

  DayItem(this.id, this.startFull, this.endFull, this.startPart, this.endPart);

}

class ListScheduleState extends State<ListSchedule> {

  final Firestore firestore = Firestore.instance;
  List<DayItem> listDay = new List<DayItem>();
  DateFormat timeFormat = DateFormat.Hm();
  DateFormat monthFormat = DateFormat.yMMMM();
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
      .listen((snapshot){
        if(snapshot.documents.isEmpty){

        } else {
          listDay.clear();
          snapshot.documents.forEach((f){
            Timestamp startFull = f.data['fullstart'];
            Timestamp endFull = f.data['fullend'];
            Timestamp startPart = f.data['partstart'];
            Timestamp endPart = f.data['partend'];
            DayItem item = new DayItem(f.documentID, startFull.toDate(), endFull.toDate(), startPart.toDate(), endPart.toDate());
            setState(() {
              listDay.add(item);
            });
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Theme.of(context).backgroundColor
              : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.shift),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24.0,
        ),
        onPressed: () {
          Navigator.of(context).push(_createRoute(AddSchedule(title: widget.shift, month: widget.month,)));
        }
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListView.builder(
              itemCount: listDay.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                return Column(
                  children: <Widget>[
                    ListTile(
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
                                .fontSize
                            ),
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
                      trailing: Icon(
                        Feather.chevron_right,
                      ),
                      onTap: () {
                        Navigator.of(context).push(_createRoute(DetailSchedule(shift: widget.shift, id: listDay[index].id, date: widget.month, startFull: listDay[index].startFull, endFull: listDay[index].endFull, startPart: listDay[index].startPart, endPart: listDay[index].endPart,)));
                      },
                    ),
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
              }
            )
          ],
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
