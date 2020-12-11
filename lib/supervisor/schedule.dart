import 'package:absenin/supervisor/monthschedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Schedule extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScheduleState();
  }
}

class MonthItem {
  final DateTime month, created;

  MonthItem(this.month, this.created);
}

class ScheduleState extends State<Schedule> {

  List<MonthItem> listMonth = new List<MonthItem>();
  List<DateTime> monthChoose = new List<DateTime>();
  DateFormat yearFormat = DateFormat.y();
  DateFormat monthFormat = DateFormat.MMMM();
  DateFormat timeFormat = DateFormat.MMMd();
  DateTime dateTime = DateTime.now();
  bool isEmptyy = false;
  bool isNext = false;
  int nextCount = 0;
  bool isLoad = true;
  String outlet;
  final Firestore firestore = Firestore.instance;

  @override
  void initState() {
    super.initState();
    _getDataUserFromPref();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
      _getScheduleMonth();
    });
  }

  _getScheduleMonth() async {
    firestore
        .collection('schedule')
        .document(outlet)
        .collection('scheduledetail')
        .document('detail')
        .collection('${dateTime.year}')
        .getDocuments()
        .then((snapshot){
          if(snapshot.documents.isEmpty){
            setState(() {
              isEmptyy = true;
              listMonth.clear();
            });
          } else {
            listMonth.clear();
            snapshot.documents.forEach((f){
              Timestamp month = f.data['month'];
              Timestamp created = f.data['created'];
              MonthItem item = new MonthItem(month.toDate(), created.toDate());
              setState(() {
                listMonth.add(item);
                isLoad = false;
              });
            });
          }
        });
  }

  _saveScheduleAdd(DateTime date) async {
    await firestore
        .collection('schedule')
        .document(outlet)
        .collection('scheduledetail')
        .document('detail')
        .collection('${date.year}')
        .document('${date.month}')
        .setData({
          'month' : date,
          'created' : DateTime.now()
        });

      if(mounted){
        listMonth.clear();
        _getScheduleMonth();
        Navigator.pop(context);
      }
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
                        '${dateTime.year}',
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
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                    itemCount: monthChoose.length,
                    itemBuilder: (context, index) {
                      bool checkDis = false;
                      for (int i = 0; i < listMonth.length; i++) {
                        if (listMonth[i].month.month == monthChoose[index].month) {
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
                                Navigator.pop(context);
                                _prosesDialog();
                                _saveScheduleAdd(monthChoose[index]);
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
                                monthFormat.format(monthChoose[index]),
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
                          if (index != monthChoose.length - 1)
                            Container(
                              margin: EdgeInsets.only(left: 70.0),
                              height: 0.5,
                              color: Theme.of(context).dividerColor,
                            )
                        ],
                      );
                    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24.0,
        ),
        onPressed: () {
          monthChoose.clear();
          DateTime timeStart = Jiffy(DateTime(dateTime.year, dateTime.month, 1)).subtract(months: (dateTime.month - 1));
          for(int i = 0; i < 12; i++){
            monthChoose.add(Jiffy(timeStart).add(months: i));
          }
          _showScheduleDialog();
        }
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Feather.chevron_left
                    ), 
                    onPressed: isNext ? (){
                      setState(() {
                        var prev = Jiffy(dateTime).subtract(years: 1);
                        dateTime = prev;
                        nextCount--;
                        if(nextCount == 0){
                          isNext = false;
                        }
                        isLoad = true;
                        isEmptyy = false;
                        _getScheduleMonth();
                      });
                    } : null
                  ) ,
                  Text(
                    yearFormat.format(dateTime),
                    style: TextStyle(
                      fontFamily: 'Google',
                      fontSize: Theme.of(context).textTheme.title.fontSize
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Feather.chevron_right
                    ), 
                    onPressed: (){
                      setState(() {
                        var next = Jiffy(dateTime).add(years: 1);
                        dateTime = next;
                        isNext = true;
                        nextCount++;
                        isLoad = true;
                        isEmptyy = false;
                        _getScheduleMonth();
                      });
                    }
                  )
                ],
              ),
            ),
            if(listMonth.length > 0 && !isLoad)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: listMonth.map((data){
                  return GestureDetector(
                    onTap: (){
                      Navigator.of(context).push(_createRoute(MonthSchedule(month: data.month,)));
                    },
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Theme.of(context).backgroundColor,
                        border: Border.all(
                          color: data.month.month == dateTime.month ? Theme.of(context).accentColor : Theme.of(context).backgroundColor
                        )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Feather.calendar,
                            color: data.month.month == dateTime.month ? Theme.of(context).accentColor : Theme.of(context).disabledColor,
                          ),
                          Spacer(),
                          Text(
                            monthFormat.format(data.month),
                            style: TextStyle(
                              fontFamily: 'Google',
                              fontSize: Theme.of(context).textTheme.subhead.fontSize
                            ),
                          ),
                          SizedBox(height: 3.0,),
                          Text(
                            'Created ${timeFormat.format(data.created)}',
                            style: TextStyle(
                              fontFamily: 'Sans',
                              fontSize: Theme.of(context).textTheme.overline.fontSize,
                              color: Theme.of(context).textTheme.caption.color
                            ),
                          ),
                        ],
                      )
                    ),
                  );
                }).toList(),
              ),
            )
            else if(!isEmptyy)
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
                    'No data to display',
                    style: TextStyle(
                        fontFamily: 'Sans',
                        color: Theme.of(context).disabledColor,
                        fontSize:
                            Theme.of(context).textTheme.title.fontSize),
                  )
                ],
              ),
            )
          ],
        )
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
