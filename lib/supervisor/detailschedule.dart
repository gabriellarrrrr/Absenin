import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:absenin/supervisor/liststaff.dart' as staffpage;
import 'package:shared_preferences/shared_preferences.dart';

class DetailSchedule extends StatefulWidget {

  final String id, shift;
  final DateTime date;
  DateTime startFull, endFull, startPart, endPart;

  DetailSchedule({Key key, @required this.id, @required this.shift, @required this.date, @required this.startFull, @required this.endFull, @required this.startPart, @required this.endPart}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DetailScheduleState();
  }
}

class StaffItem {
  String id;
  String img;
  String name;
  String part;
  int type;
  bool check;
  bool overtime;

  StaffItem(this.id, this.img, this.name, this.part, this.type, this.check, this.overtime);
}

class PartItem {
  String part;
  bool check;

  PartItem(this.part, this.check);
}

class DetailScheduleState extends State<DetailSchedule> {

  Firestore  firestore = Firestore.instance;
  List<StaffItem> listStaff = new List<StaffItem>();
  List<staffpage.StaffItem> listTemp = new List<staffpage.StaffItem>();
  List<PartItem> listPart = new List<PartItem>();
  int fullTimeCount = 0;
  int partTimeCount = 0;
  int staffCountSelected = 0;
  bool staffSelected = false;
  bool _canVibrate = true;
  DateFormat timeFormat = DateFormat.Hm();
  DateFormat monthFormat = DateFormat.yMMMM();
  DateTime startFullTemp, endFullTemp, startPartTemp, endPartTemp;
  bool overtimeTemp = false;
  String outlet;

  PartItem part1 = new PartItem('Inventori', false);
  PartItem part2 = new PartItem('Front Linner', false);
  PartItem part3 = new PartItem('Temperedglass', false);
  PartItem part4 = new PartItem('Online Service', false);

  @override
  void initState() {
    super.initState();
    listPart.add(part1);
    listPart.add(part2);
    listPart.add(part3);
    listPart.add(part4);
    _getDataUserFromPref();
    _checkVibrate();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
      _getListStaff(10);
    });
  }

  _getListStaff(int action) async {
    if(action == 20){
      setState(() {
        fullTimeCount = 0;
        partTimeCount = 0;
      });
    }
    await firestore
      .collection('schedule')
      .document(outlet)
      .collection('scheduledetail')
      .document('${widget.date.year}')
      .collection('${widget.date.month}')
      .document(widget.shift)
      .collection('listday')
      .document(widget.id)
      .collection('liststaff')
      .where('switchAcc', isEqualTo: 0)
      .where('permit', isEqualTo: false)
      .getDocuments()
      .then((snapshot){
        if(snapshot.documents.isEmpty){

        } else {
          snapshot.documents.forEach((f) async {
            String name, img;
            await firestore
                .collection('user')
                .document(outlet)
                .collection('listuser')
                .document(f.documentID)
                .get()
                .then((DocumentSnapshot snapshot) {
              name = snapshot.data['name'];
              img = snapshot.data['img'];
            });
            if(mounted){
              StaffItem item = new StaffItem(f.documentID, img, name, f.data['pos'], f.data['type'], false, f.data['isOvertime']);
              staffpage.StaffItem itemTemp = new staffpage.StaffItem(f.documentID, img, name, 'position', f.data['type'], false, 'phone', 'address', 'email', 'outlet', 'enrol', false);
              setState(() {
                if(f.data['type'] == 1){
                  fullTimeCount++;
                } else {
                  partTimeCount++;
                }
                listStaff.add(item);
                listTemp.add(itemTemp);
              });
            }
          });
        }
      });
      if(mounted){
        setState(() {
          if(action == 20){
            staffSelected = false;
            staffCountSelected = 0;
            Navigator.pop(context);
          }
        });
      }
  }

  _checkVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  _showPostDialog(String title, int position, String shift, bool overtime) async {
    final bool result = await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
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
                            title,
                            style: TextStyle(
                                fontSize:
                                    Theme.of(context).textTheme.title.fontSize,
                                fontFamily: 'Google'),
                          ),
                        )),
                    Divider(
                      height: 0.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 10.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Overtime',
                                style: TextStyle(
                                    fontFamily: 'Google',
                                    fontWeight: FontWeight.bold,
                                    color:
                                        MediaQuery.of(context).platformBrightness ==
                                                Brightness.light
                                            ? Colors.black54
                                            : Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        onTap: (){
                          setState(() {
                            overtimeTemp = !overtime;
                            overtime = !overtime;
                          });
                        },
                        title: Text(
                          shift,
                          style: TextStyle(
                            fontFamily: 'Google',
                          ),
                        ),
                        trailing: Switch(
                          value: overtime, 
                          onChanged: (value){
                            overtimeTemp = value;
                          }
                        ),
                      ),
                    ),
                    Divider(
                      height: 0.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 10.0, bottom: 8.0),
                          child: Text(
                            'Part of',
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
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: listPart.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            ListTile(
                              onTap: () {
                                for (int j = 0; j < listPart.length; j++) {
                                  setState(() {
                                    listPart[j].check = false;
                                  });
                                }
                                setState(() {
                                  listPart[index].check =
                                      !listPart[index].check;
                                });
                              },
                              leading: Icon(
                                listPart[index].check
                                    ? Icons.check_circle
                                    : Icons.panorama_fish_eye,
                                size: 20.0,
                                color: listPart[index].check
                                    ? MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.green
                                        : Colors.green[400]
                                    : Theme.of(context).disabledColor,
                              ),
                              title: Text(
                                listPart[index].part,
                                style: TextStyle(fontFamily: 'Google'),
                              ),
                            ),
                            if (index != listPart.length - 1)
                              Container(
                                margin: EdgeInsets.only(left: 70.0),
                                height: 0.5,
                                color: Theme.of(context).dividerColor,
                              )
                          ],
                        );
                      }
                    ),
                    Divider(
                      height: 0.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ));
          });
        });
    if (result != null) {
      if (result) {
        for (int i = 0; i < listPart.length; i++) {
          if (listPart[i].check) {
            await firestore
                  .collection('schedule')
                  .document(outlet)
                  .collection('scheduledetail')
                  .document('${widget.date.year}')
                  .collection('${widget.date.month}')
                  .document(widget.shift)
                  .collection('listday')
                  .document(widget.id)
                  .collection('liststaff')
                  .document(listStaff[position].id)
                  .updateData({
                    'pos': listPart[i].part,
                    'isOvertime': overtimeTemp,
                  });
                  if(mounted){
                    setState(() {
                      listStaff[position].part = listPart[i].part;
                      listStaff[position].overtime = overtimeTemp;
                    });
                  }
          }
        }
      }
    }
  }

  void _showTimeDialog(String title, DateTime startFull, DateTime endFull, DateTime startPart, DateTime endPart) async {
    final bool result = await showDialog(
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
                        '$title',
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.title.fontSize,
                            fontFamily: 'Google'),
                      ),
                    )),
                Divider(
                  height: 0.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Full Time',
                        style: TextStyle(
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.black54
                                : Colors.grey[400]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                'Clock In',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .fontSize,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TimePickerSpinner(
                                alignment: Alignment.center,
                                itemHeight: 30.0,
                                itemWidth: 30.0,
                                time: startFull,
                                isForce2Digits: true,
                                normalTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[100]
                                        : Colors.indigoAccent.withAlpha(90),
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.w300),
                                highlightedTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[400]
                                        : Colors.indigoAccent[100],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.bold),
                                onTimeChange: (time) {
                                  setState(() {
                                    if (startFull != time) {
                                      startFullTemp = time;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          Container(
                            width: 0.5,
                            height: 80.0,
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Clock Out',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .fontSize,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TimePickerSpinner(
                                alignment: Alignment.center,
                                itemHeight: 30.0,
                                itemWidth: 30.0,
                                time: endFull,
                                isForce2Digits: true,
                                normalTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[100]
                                        : Colors.indigoAccent.withAlpha(90),
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.w300),
                                highlightedTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[400]
                                        : Colors.indigoAccent[100],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.bold),
                                onTimeChange: (time) {
                                  setState(() {
                                    if (endFull != time) {
                                      endFullTemp = time;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 0.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Part Time',
                        style: TextStyle(
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.black54
                                : Colors.grey[400]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                'Clock In',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .fontSize,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TimePickerSpinner(
                                alignment: Alignment.center,
                                itemHeight: 30.0,
                                itemWidth: 30.0,
                                time: startPart,
                                isForce2Digits: true,
                                normalTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[100]
                                        : Colors.indigoAccent.withAlpha(90),
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.w300),
                                highlightedTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[400]
                                        : Colors.indigoAccent[100],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.bold),
                                onTimeChange: (time) {
                                  setState(() {
                                    if (startPart != time) {
                                      startPartTemp = time;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          Container(
                            width: 0.5,
                            height: 80.0,
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Clock Out',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .fontSize,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TimePickerSpinner(
                                alignment: Alignment.center,
                                itemHeight: 30.0,
                                itemWidth: 30.0,
                                time: endPart,
                                isForce2Digits: true,
                                normalTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[100]
                                        : Colors.indigoAccent.withAlpha(90),
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.w300),
                                highlightedTextStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[400]
                                        : Colors.indigoAccent[100],
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .title
                                        .fontSize,
                                    fontWeight: FontWeight.bold),
                                onTimeChange: (time) {
                                  setState(() {
                                    if (endPart != time) {
                                      endPartTemp = time;
                                    }
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
                Divider(
                  height: 0.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                )
              ],
            )
          )
        );
        if(result != null){
          if(result){
            await firestore
                  .collection('schedule')
                  .document(outlet)
                  .collection('scheduledetail')
                  .document('${widget.date.year}')
                  .collection('${widget.date.month}')
                  .document(widget.shift)
                  .collection('listday')
                  .document(widget.id)
                  .updateData({
                    'fullstart': startFullTemp,
                    'fullend': endFullTemp,
                    'partstart': startPartTemp,
                    'partend': endPartTemp
                  });
                  if(mounted){
                    setState(() {
                      widget.startFull = startFullTemp;
                      widget.endFull = endFullTemp;
                      widget.startPart = startPartTemp;
                      widget.endPart = endPartTemp;
                    });
                  }
          }
        }
  }

  _gotoListStaffPage() async {
    final result =
        await Navigator.of(context).push(_createRoute(staffpage.Staff(
      action: 20,
      listCurrent: listTemp,
    )));
    if (result != null) {
      listTemp = result;
      List<StaffItem> newList = new List<StaffItem>();
      if (listTemp.length > 0) {
        for (int i = 0; i < listTemp.length; i++) {
          StaffItem item = new StaffItem(listTemp[i].id, listTemp[i].img, listTemp[i].name, '', listTemp[i].type, false, false);
          newList.add(item);
        }
      }
      int fullTime = 0;
      int partTime = 0;
      for(int i = 0; i < newList.length; i++){
        for(int j = 0; j < listStaff.length; j++){
          if(newList[i].id == listStaff[j].id){
            newList[i].part = listStaff[j].part;
          }
        }
        if(newList[i].type == 1){
          fullTime++;
        } else {
          partTime++;
        }
      }
      for(int j = 0; j < newList.length; j ++){
        if(newList[j].part == '' || newList[j].part == null){
          await firestore
                .collection('schedule')
                .document(outlet)
                .collection('scheduledetail')
                .document('${widget.date.year}')
                .collection('${widget.date.month}')
                .document(widget.shift)
                .collection('listday')
                .document(widget.id)
                .collection('liststaff')
                .document(newList[j].id)
                .setData({
                  'pos': '-',
                  'type': newList[j].type,
                  'clockin': widget.startPart,
                  'clockout': widget.startPart,
                  'break': widget.startPart,
                  'afterbreak': widget.startPart,
                  'late': 0,
                  'isClockIn': false,
                  'isBreak': false,
                  'isAfterBreak': false,
                  'isClockOut': false,
                  'isOvertime': false,
                  'permit': false,
                  'switch': false,
                  'switchAcc': 0
                });
        }
      }
      setState(() {
        listStaff = newList;
        fullTimeCount = fullTime;
        partTimeCount = partTime;
      });
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

  _deleteStaff() async {
    for(int i = 0; i < listStaff.length; i++){
      if(listStaff[i].check){
        await firestore
              .collection('schedule')
              .document(outlet)
              .collection('scheduledetail')
              .document('${widget.date.year}')
              .collection('${widget.date.month}')
              .document(widget.shift)
              .collection('listday')
              .document(widget.id)
              .collection('liststaff')
              .document(listStaff[i].id)
              .delete();
      }
    }
    listStaff.clear();
    listTemp.clear();
    _getListStaff(20);

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            staffSelected ? '$staffCountSelected' : 'Detail Schedule'
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${widget.id} ${monthFormat.format(widget.date)}',
                                  style: TextStyle(
                                      fontFamily: 'Google',
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .headline
                                          .fontSize),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.12,
                                      child: Text(
                                        'Shift',
                                        style: TextStyle(
                                            fontFamily: 'Sans',
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .fontSize,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                      ),
                                    ),
                                    Text(
                                      '${widget.shift}',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Divider(
                                  height: 0.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.12,
                                      child: Text(
                                        'Full start',
                                        style: TextStyle(
                                            fontFamily: 'Sans',
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .fontSize,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                      ),
                                    ),
                                    Text(
                                      '${timeFormat.format(widget.startFull)}',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Divider(
                                  height: 0.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.12,
                                      child: Text(
                                        'Full end',
                                        style: TextStyle(
                                            fontFamily: 'Sans',
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .fontSize,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                      ),
                                    ),
                                    Text(
                                      '${timeFormat.format(widget.endFull)}',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Divider(
                                  height: 0.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.12,
                                      child: Text(
                                        'Part start',
                                        style: TextStyle(
                                            fontFamily: 'Sans',
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .fontSize,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                      ),
                                    ),
                                    Text(
                                      '${timeFormat.format(widget.startPart)}',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Divider(
                                  height: 0.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.12,
                                      child: Text(
                                        'Part end',
                                        style: TextStyle(
                                            fontFamily: 'Sans',
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .fontSize,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                      ),
                                    ),
                                    Text(
                                      '${timeFormat.format(widget.endPart)}',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Divider(height: 0.0,),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Center(
                                  child: FlatButton(
                                    onPressed: () {
                                      _showTimeDialog('${widget.id} ${monthFormat.format(widget.date)}', widget.startFull, widget.endFull, widget.startPart, widget.endPart);
                                    },
                                    textColor: Theme.of(context).buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      'Change time',
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                      ),
                                    )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 30.0, bottom: 10.0),
                child: Text(
                  'Staff',
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      fontFamily: 'Google',
                      fontWeight: FontWeight.bold),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    children: <Widget>[
                      if (listStaff.length > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Set up for ${listStaff.length} staffs',
                                  style: TextStyle(
                                      fontFamily: 'Google',
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .headline
                                          .fontSize),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.12,
                                      child: Text(
                                        'Full time',
                                        style: TextStyle(
                                            fontFamily: 'Sans',
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .fontSize,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                      ),
                                    ),
                                    Text(
                                      '$fullTimeCount staff',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Divider(
                                  height: 0.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                              .size
                                              .width *
                                          0.12,
                                      child: Text(
                                        'Part time',
                                        style: TextStyle(
                                            fontFamily: 'Sans',
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .fontSize,
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color),
                                      ),
                                    ),
                                    Text(
                                      '$partTimeCount staff',
                                      style: TextStyle(
                                          fontFamily: 'Sans',
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .fontSize,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Divider(
                                  height: 0.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  'List staff',
                                  style: TextStyle(
                                      fontFamily: 'Sans',
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .fontSize,
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .color),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Divider(
                                  height: 0.0,
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: listStaff.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: <Widget>[
                                    Material(
                                        color: listStaff[index].check
                                            ? MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.grey[50]
                                                : Colors.grey[900]
                                            : Colors.transparent,
                                        child: ListTile(
                                          onTap: () {
                                            if (staffSelected) {
                                              if (listStaff[index].check ==
                                                  true) {
                                                setState(() {
                                                  listStaff[index].check =
                                                      false;
                                                  staffCountSelected--;
                                                  if (staffCountSelected ==
                                                      0) {
                                                    staffSelected = false;
                                                  }
                                                });
                                              } else {
                                                setState(() {
                                                  listStaff[index].check =
                                                      true;
                                                  staffCountSelected++;
                                                });
                                              }
                                            } else {
                                              for (int i = 0;
                                                  i < listPart.length;
                                                  i++) {
                                                if (listPart[i].part ==
                                                    listStaff[index].part) {
                                                  setState(() {
                                                    listPart[i].check =
                                                        true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    listPart[i].check =
                                                        false;
                                                  });
                                                }
                                              }
                                              _showPostDialog(listStaff[index].name, index, '${widget.id} ${monthFormat.format(widget.date)}', listStaff[index].overtime);
                                            }
                                          },
                                          onLongPress: () {
                                            setState(() {
                                              listStaff[index].check = true;
                                              staffSelected = true;
                                              staffCountSelected++;
                                            });
                                          },
                                          leading: ClipOval(
                                              child:
                                                  FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/images/absenin.png',
                                            height: 50.0,
                                            width: 50.0,
                                            image: listStaff[index].img,
                                            fadeInDuration:
                                                Duration(seconds: 1),
                                            fit: BoxFit.cover,
                                          )),
                                          title: Text(
                                            listStaff[index].name,
                                            style: TextStyle(
                                                fontFamily: 'Google'),
                                          ),
                                          subtitle: Text(
                                            listStaff[index].part != '' && listStaff[index].part != '-'
                                                ? listStaff[index].part
                                                : 'Part = not set',
                                            style: TextStyle(
                                                fontFamily: 'Sans'),
                                          ),
                                          trailing: listStaff[index].check
                                              ? Icon(
                                                  Icons.check_circle,
                                                  size: 18.0,
                                                  color: MediaQuery.of(
                                                                  context)
                                                              .platformBrightness ==
                                                          Brightness.light
                                                      ? Colors.green
                                                      : Colors.green[400],
                                                )
                                              : null,
                                        )),
                                    if (index != listStaff.length - 1)
                                      Container(
                                        height: 0.5,
                                        margin: EdgeInsets.only(
                                            left: 80.0, right: 20.0),
                                        color:
                                            Theme.of(context).dividerColor,
                                      )
                                  ],
                                );
                              }
                            ),
                            Container(
                              width: double.infinity,
                              height: 0.5,
                              color: Theme.of(context).dividerColor,
                              margin: EdgeInsets.only(left: 20.0, right: 20.0),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Center(
                              child: FlatButton(
                                onPressed: () {
                                  if(staffSelected){
                                    _prosesDialog();
                                    _deleteStaff();
                                  } else {
                                    _gotoListStaffPage();
                                  }
                                },
                                textColor: staffSelected ? MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.red : Colors.red[300] : Theme.of(context).buttonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Text(
                                  staffSelected ? 'Delete staff' : 'Add staff',
                                  style: TextStyle(
                                    fontFamily: 'Google',
                                  ),
                                )
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
              )
            ],
          ),
        )
      ),
      onWillPop: () async {
          bool exit = false;
          if (staffSelected) {
            if (staffSelected) {
              setState(() {
                staffSelected = false;
              });
              for (int i = 0; i < listStaff.length; i++) {
                if (listStaff[i].check) {
                  setState(() {
                    listStaff[i].check = false;
                  });
                }
              }
            }
            staffCountSelected = 0;
          } else {
            Navigator.pop(context);
          }
          return exit;
        }
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
