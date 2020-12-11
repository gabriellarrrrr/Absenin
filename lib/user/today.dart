import 'dart:async';

import 'package:absenin/user/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_vant_kit/widgets/steps.dart';

class TodayPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodayPageState();
  }

}

class TodayPageState extends State<TodayPage> {

  int _active = -1;
  bool isClockin = false;
  bool isClockOut = false;
  bool isNoClockOut = false;

  void _stepCounter() {
    setState(() {
      _active++;
      if (_active == 3) {
        Timer(Duration(seconds: 1), () => _showAlertDialog());
      }
    });
  }

  void _showAlertDialog() {
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
                  padding:
                    const EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Are You Overtime?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Google', 
                        fontSize: Theme.of(context).textTheme.subhead.fontSize
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/img2.png',
                  height: 200,
                ),
                SizedBox(
                  height: 20,
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
                      setState(() {
                        isClockOut = true;
                      });
                    },
                    child: Text(
                      'YES',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold
                      ),
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
                      setState(() {
                        isNoClockOut = true;
                      });
                    },
                    child: Text(
                      'NO',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black54 : Colors.grey[400]
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        )
      )
    );
  }

  _gotoClockInPage() async {
    final result = await Navigator.of(context).push(_createRoute(MapPage()));
    if(result != null && result != false){
      setState(() {
        isClockin = true;
        _stepCounter();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.indigo : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 5.0, top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'My Attendance',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline.fontSize,
                      fontFamily: 'Google',
                      color: Colors.white
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Feather.x,
                      size: 20.0,
                      color: Colors.white
                    ), 
                    onPressed: (){
                      Navigator.pop(context);
                    }
                  )
                ],
              ),
            ),
            Hero(
              tag: 'body0', 
              child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8.0,
                      color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black12 : Colors.transparent,
                      offset: Offset(0.0, 3.0)
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Ionicons.md_calendar,
                          color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.indigo[300] : Colors.indigoAccent[100],
                        ),
                        SizedBox(width: 10.0,),
                        Text(
                          'Today, 04 Mei 2020',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.subhead.fontSize,
                            fontFamily: 'Sans',
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 10.0,),
                    Text(
                      'Shift 1',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.title.fontSize,
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 5.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '07:00 AM',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.body2.fontSize,
                            fontFamily: 'Sans',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.caption.color,
                          ),
                        ),
                        Text(
                          '...............................',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.body2.fontSize,
                            fontFamily: 'Sans',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.caption.color,
                          ),
                        ),
                        Text(
                          '15:00 PM',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.body2.fontSize,
                            fontFamily: 'Sans',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.caption.color,
                          ),
                        ),
                      ],
                    ),
                    if(isClockin)
                    Column(
                      children: <Widget>[
                        SizedBox(height: 30.0,),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Steps(
                            // direction: 'vertical',
                            steps: isClockOut
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
                            active: _active,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0,),
                    if (!isNoClockOut && _active < 5)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _active >= 0 ? '' : '15 minutes again',
                          style: Theme.of(context).textTheme.caption,
                        ),
                        FlatButton(
                          onPressed: (){
                            if (_active == 3 && isClockOut == false) {
                              _showAlertDialog();
                            } else {
                              if (isClockin) {
                                _stepCounter();
                              } else {
                                _gotoClockInPage();
                              }
                            }
                          }, 
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 5.0,),
                              Text(
                                _active == 0 ? 'Break'
                                  : _active == 1
                                      ? 'After Break'
                                      : _active == 2
                                          ? 'Clock Out'
                                          : _active == 3
                                              ? 'Overtime In'
                                              : _active == 4
                                                  ? 'Overtime Out'
                                                  : 'Clock in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                          color: MediaQuery.of(context).platformBrightness == Brightness.light ?  Colors.indigo : Colors.indigo[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          splashColor: Colors.black26,
                          highlightColor: Colors.black26,
                        )
                      ],
                    ) 
                    else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Your Work Finished',
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Text(
                          'Thank You!',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        )
      )
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

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

}