import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:random_color/random_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleTime extends StatefulWidget {

  final int action;
  final String id;

  const ScheduleTime({Key key, @required this.action, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScheduleState();
  }
}

class OverviewSchedule {
  
  final DateTime date, startTime, endTime;
  final String shift, pos;
  final int lateTime, type;
  bool isClockIn,
      isBreak,
      isAfterBreak,
      isClockOut,
      isOverTime,
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
      this.isOff,
      this.isPermit,
      this.isSwitch,
      this.isSwitchAcc,
      this._active);
}

class ScheduleState extends State<ScheduleTime> {

  final Firestore firestore = Firestore.instance;
  DateTime dateTime = DateTime.now();
  String id, outlet;
  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateFormat timeFormat = DateFormat.Hm();

  List<OverviewSchedule> listSchedule = new List<OverviewSchedule>();
  List<Color> generatedColors = <Color>[];
  final List<ColorHue> _hueType = <ColorHue>[
    ColorHue.green,
    ColorHue.red,
    ColorHue.pink,
    ColorHue.purple,
    ColorHue.blue,
    ColorHue.yellow,
    ColorHue.orange
  ];
  ColorBrightness _colorLuminosity = ColorBrightness.random;
  ColorSaturation _colorSaturation = ColorSaturation.random;

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
      _getListSchedule();
    });
  }

  _getListSchedule() async {
    for(int i = 0; i < 7; i++){
      await firestore
          .collection('schedule')
          .document(outlet)
          .collection('scheduledetail')
          .document('${Jiffy().add(days: i).year}')
          .collection('${Jiffy().add(days: i).month}')
          .document('Shift 1')
          .collection('listday')
          .document('${Jiffy().add(days: i).day}')
          .collection('liststaff')
          .document(id)
          .get()
          .then((snapshot2) async {
            if(snapshot2.exists){
              bool isClockIn = snapshot2.data['isClockIn'];
              bool isBreak = snapshot2.data['isBreak'];
              bool isAfterBreak = snapshot2.data['isAfterBreak'];
              bool isClockOut = snapshot2.data['isClockOut'];
              bool isOverTime = snapshot2.data['isOvertime'];
              bool isPermit = snapshot2.data['permit'];
              bool isSwitch = snapshot2.data['switch'];
              int isSwitchAcc = snapshot2.data['switchAcc'];
              int lateTime = snapshot2.data['late'];
              int type = snapshot2.data['type'];
              String pos = snapshot2.data['pos'];
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

              await firestore
                    .collection('schedule')
                    .document(outlet)
                    .collection('scheduledetail')
                    .document('${dateTime.year}')
                    .collection('${dateTime.month}')
                    .document('Shift 1')
                    .collection('listday')
                    .document('${Jiffy().add(days: i).day}')
                    .get()
                    .then((snapshoots) {
                  if (snapshoots.exists) {
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
                        false,
                        isPermit,
                        isSwitch,
                        isSwitchAcc,
                        active);
                    if(!isPermit && isSwitchAcc != 1){
                      listSchedule.add(item);
                    }
                  }
                });
            } else {
              await firestore
                    .collection('schedule')
                    .document(outlet)
                    .collection('scheduledetail')
                    .document('${Jiffy().add(days: i).year}')
                    .collection('${Jiffy().add(days: i).month}')
                    .document('Shift 2')
                    .collection('listday')
                    .document('${Jiffy().add(days: i).day}')
                    .collection('liststaff')
                    .document(id)
                    .get()
                    .then((snapshot2) async {
                      if(snapshot2.exists){
                        bool isClockIn = snapshot2.data['isClockIn'];
                        bool isBreak = snapshot2.data['isBreak'];
                        bool isAfterBreak = snapshot2.data['isAfterBreak'];
                        bool isClockOut = snapshot2.data['isClockOut'];
                        bool isOverTime = snapshot2.data['isOvertime'];
                        bool isPermit = snapshot2.data['permit'];
                        bool isSwitch = snapshot2.data['switch'];
                        int isSwitchAcc = snapshot2.data['switchAcc'];
                        int lateTime = snapshot2.data['late'];
                        int type = snapshot2.data['type'];
                        String pos = snapshot2.data['pos'];
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

                        await firestore
                              .collection('schedule')
                              .document(outlet)
                              .collection('scheduledetail')
                              .document('${dateTime.year}')
                              .collection('${dateTime.month}')
                              .document('Shift 2')
                              .collection('listday')
                              .document('${Jiffy().add(days: i).day}')
                              .get()
                              .then((snapshoots) {
                            if (snapshoots.exists) {
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
                                  false,
                                  isPermit,
                                  isSwitch,
                                  isSwitchAcc,
                                  active);
                              if(!isPermit && isSwitchAcc != 1){
                                listSchedule.add(item);
                              }
                            }
                          });
                      }
                    });
            }
          });
    }
    setState(() {
      
    });
  }

  void accSwitchRequest(int index) async {
    await firestore
      .collection('switchschedule')
      .document(outlet)
      .collection('listswitch')
      .document(widget.id)
      .updateData({
        'posTo' : listSchedule[index].pos,
        'dateto' : listSchedule[index].date,
        'shiftto' : listSchedule[index].shift,
        'toAcc' : true
      });
      if(mounted){
        await firestore
          .collection('user')
          .document(outlet)
          .collection('listuser')
          .document(id)
          .collection('${DateTime.now().year}')
          .document('request')
          .updateData({
            'switch' : false,
          });
          if(mounted){
            Navigator.pop(context);
            showCenterShortToast();
            Navigator.pop(context);
          }
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

  Color getRandomColor(int index) {
    Color _color;

    if (generatedColors.length > index) {
      _color = generatedColors[index];
    } else {
      _color = RandomColor().randomColor(
          colorHue: ColorHue.multiple(colorHues: _hueType),
          colorSaturation: _colorSaturation,
          colorBrightness: _colorLuminosity);

      generatedColors.add(_color);
    }

    return _color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.action == 10 ? 'Schedule' : 'Choose Schedule'
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              margin: EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
                color: Theme.of(context).backgroundColor,
              ),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/schedule.png',
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                  SizedBox(height: 30.0,),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'My Schedule',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.headline.fontSize,
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
                              onPressed: (){}
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.action == 10 ? 'All your schedule' : 'Choose one of your schedule',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.caption.color,
                      fontFamily: 'Sans',
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  if(listSchedule.length > 0)
                  ListView.builder(
                      itemCount: listSchedule.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(
                            bottom: 5,
                            top: 15,
                          ),
                          padding: EdgeInsets.only(left: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: getRandomColor(index),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 3),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Container(
                            padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 10.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Theme.of(context).backgroundColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  dateFormat.format(listSchedule[index].date),
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.body1.fontSize,
                                    fontFamily: 'Sans',
                                    color: Theme.of(context).textTheme.caption.color
                                  ),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Text(
                                  listSchedule[index].shift,
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.title.fontSize,
                                    fontFamily: 'Google',
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      timeFormat.format(listSchedule[index].startTime),
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.body1.fontSize,
                                        fontFamily: 'Sans',
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        for(int i = 0; i < 20; i++)
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 3.5,
                                              height: 3.5,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).textTheme.caption.color,
                                                shape: BoxShape.circle
                                              ),
                                            ),
                                            if(i < 19)
                                            SizedBox(width: 5.0,),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      timeFormat.format(listSchedule[index].endTime),
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.body1.fontSize,
                                        fontFamily: 'Sans',
                                      ),
                                    ),
                                  ],
                                ),
                                if(widget.action == 20)
                                SizedBox(height: 20.0,),
                                if(widget.action == 20)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FlatButton(
                                    onPressed: (){
                                      _prosesDialog();
                                      accSwitchRequest(index);
                                    }, 
                                    child: Text(
                                      'Choose',
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    color: Theme.of(context).buttonColor,
                                    textColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    splashColor: Colors.black26,
                                    highlightColor: Colors.black26,
                                  ),
                                )
                                else
                                SizedBox(height: 15.0,),
                              ],
                            ),
                          ),
                        );
                      }
                  )
                  else 
                  Center(
                    child: Padding(
                    padding: const EdgeInsets.only(top: 150.0, bottom: 30.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
