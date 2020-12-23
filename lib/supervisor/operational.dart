import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OperationalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OperationalPageState();
  }
}

class OperationalPageState extends State {
  final nameController = TextEditingController();
  DateTime startFull = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 08, 00),
      endFull = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 15, 10),
      startPart = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 09, 30),
      endPart = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 15, 00),
      startFullTemp,
      endFullTemp,
      startPartTemp,
      endPartTemp;
  bool _buttonActive = false;
  String outlet;
  final Firestore firestore = Firestore.instance;

  @override
  void initState() {
    _getDataUserFromPref();
    super.initState();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
    });
  }

  enableButton() {
    if (nameController.text != '') {
      setState(() {
        _buttonActive = true;
      });
    } else {
      setState(() {
        _buttonActive = false;
      });
    }
  }

  _saveOperational() async {
    firestore
        .collection('outlet')
        .where('name', isEqualTo: outlet)
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.isNotEmpty) {
        snapshot.documents.forEach((f) {
          firestore
              .collection('outlet')
              .document(f.documentID)
              .collection('oprational')
              .document(nameController.text)
              .setData({
            'name': nameController.text,
            'startfull': startFullTemp,
            'endfull': endFullTemp,
            'startpart': startPartTemp,
            'endpart': endPartTemp,
            'startfull2': Jiffy(startFullTemp).add(minutes: 30),
            'endfull2': Jiffy(endFullTemp).add(minutes: 30),
            'startpart2': Jiffy(startPartTemp).add(minutes: 30),
            'endpart2': Jiffy(endPartTemp).add(minutes: 30),
          });
          if (mounted) {
            Timer(Duration(seconds: 2), () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            });
          }
        });
      }
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
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Add New Operational'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Operational',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.body1.fontSize,
                          fontFamily: 'Google',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: nameController,
                        onChanged: (value) {
                          enableButton();
                        },
                        decoration: InputDecoration(
                            hintText: 'Operational name',
                            border: OutlineInputBorder(),
                            helperText: 'Ex: Shift 1'),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 50,
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.subhead.fontSize,
                            fontFamily: 'Sans'),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Full Time',
                        style: TextStyle(fontFamily: 'Google'),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Row(
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
                                    startFullTemp = time;
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
                                    endFullTemp = time;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Divider(
                        height: 0.0,
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Text(
                        'Part Time',
                        style: TextStyle(
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.black54
                                : Colors.grey[400]),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      Row(
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
                                    startPartTemp = time;
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
                                    endPartTemp = time;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Theme.of(context).backgroundColor
                        : Theme.of(context).scaffoldBackgroundColor,
                    padding: EdgeInsets.all(15.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: FlatButton(
                        onPressed: _buttonActive
                            ? () {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                _prosesDialog();
                                _saveOperational();
                              }
                            : () {},
                        child: Text(
                          'Save',
                          style: TextStyle(
                              fontFamily: 'Google',
                              fontWeight: FontWeight.bold),
                        ),
                        color: _buttonActive
                            ? Theme.of(context).buttonColor
                            : Theme.of(context).disabledColor.withOpacity(0.1),
                        textColor: _buttonActive
                            ? Colors.white
                            : Theme.of(context).disabledColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
