import 'dart:async';

import 'package:absenin/user/passcode.dart';
import 'package:absenin/user/photoview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }
}

class ProfileState extends State<ProfileUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final PanelController _panelController = new PanelController();
  StreamController<ErrorAnimationType> errorController;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TextEditingController textEditingController = TextEditingController();
  bool notif = false;
  String id = '',
      name = '',
      img = '',
      position = '',
      outlet = '',
      phone = '',
      email = '',
      address = '',
      passcode = '';
  int type = 0;
  bool collaps = true;

  @override
  void initState() {
    super.initState();
    getDataUserFromPref();
    errorController = StreamController<ErrorAnimationType>();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  void getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('idUser');
      name = prefs.getString('namaUser');
      position = prefs.getString('positionUser');
      img = prefs.getString('imgUser');
      outlet = prefs.getString('outletUser');
      phone = prefs.getString('phoneUser');
      email = prefs.getString('emailUser');
      address = prefs.getString('addressUser');
      type = prefs.getInt('typeUser');
      passcode = prefs.getString('passcodeUser');
    });
  }

  _showNotif() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '1.0', 'Absenin', 'Reminder Notification',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Reminder For You',
        "You have schedule today! Don't forget to attend.",
        platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Profile'),
            ),
            body: SlidingUpPanel(
              minHeight: 0.0,
              maxHeight: MediaQuery.of(context).size.height * 0.25,
              backdropEnabled: true,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              parallaxEnabled: true,
              parallaxOffset: 0.5,
              color: Theme.of(context).backgroundColor,
              isDraggable: true,
              controller: _panelController,
              onPanelClosed: () {
                setState(() {
                  collaps = true;
                  FocusScope.of(context).requestFocus(new FocusNode());
                  textEditingController.text = '';
                });
              },
              panel: Padding(
                padding: EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 10.0, bottom: 30.0),
                child: Column(
                  children: [
                    Container(
                      width: 35.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Theme.of(context).dividerColor),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      'Enter your passcode',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Google',
                          fontSize:
                              Theme.of(context).textTheme.subhead.fontSize),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                      child: PinCodeTextField(
                        length: 6,
                        obsecureText: false,
                        autoFocus: false,
                        autoDismissKeyboard: false,
                        animationType: AnimationType.fade,
                        shape: PinCodeFieldShape.box,
                        animationDuration: Duration(milliseconds: 300),
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        backgroundColor: Theme.of(context).backgroundColor,
                        activeColor: Theme.of(context).accentColor,
                        inactiveColor: Theme.of(context).dividerColor,
                        fieldWidth: 40,
                        errorAnimationController: errorController,
                        controller: textEditingController,
                        textInputType: TextInputType.number,
                        autoDisposeControllers: false,
                        textStyle: TextStyle(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.black87
                                : Colors.white,
                            fontSize: 20.0,
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold),
                        onCompleted: (value) {
                          if (value == passcode) {
                            if (collaps) {
                              _panelController.open();
                              setState(() {
                                collaps = false;
                              });
                            } else {
                              _panelController.close();
                              setState(() {
                                collaps = true;
                              });
                            }
                            Navigator.of(context)
                                .push(_createRoute(PasscodeUser(
                              email: email,
                              action: 30,
                              outlet: outlet,
                              id: id,
                            )));
                            textEditingController.text = '';
                          } else {
                            textEditingController.text = '';
                            errorController.add(ErrorAnimationType.shake);
                          }
                        },
                        onChanged: (value) {
                          print(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          top: 30, left: 15, right: 15, bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0)),
                        color: Theme.of(context).backgroundColor,
                      ),
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PhotoPage(
                                              urlImg: img,
                                              id: id,
                                              outlet: outlet,
                                              nama: name,
                                            )));
                                if (result != null) {
                                  if (result != 'null') {
                                    setState(() {
                                      img = result;
                                      prefs.setString('imgUser', result);
                                    });
                                  }
                                }
                              },
                              child: Hero(
                                tag: 'photo',
                                child: Container(
                                  padding: EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).dividerColor),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: img,
                                      height: 100.0,
                                      width: 100.0,
                                      fit: BoxFit.cover,
                                    ),
                                    //     FadeInImage.assetNetwork(
                                    //   placeholder: 'assets/images/absenin.png',
                                    //   height: 100.0,
                                    //   width: 100.0,
                                    //   image: img,
                                    //   fadeInDuration: Duration(seconds: 1),
                                    //   fit: BoxFit.cover,
                                    // )
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: 25,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Text(
                              name,
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .title
                                      .fontSize,
                                  fontFamily: 'Google'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(position,
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .fontSize,
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.orange[800]
                                        : Colors.orange[300],
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              FontAwesome.bullseye,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.indigo[300]
                                      : Colors.indigoAccent[100],
                            ),
                            title: Text(
                              outlet,
                              style: TextStyle(
                                fontFamily: 'Google',
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .fontSize,
                              ),
                            ),
                          ),
                          Container(
                            height: 0.5,
                            margin: EdgeInsets.only(left: 55.0, right: 5.0),
                            color: Theme.of(context).dividerColor,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              FontAwesome.id_badge,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.indigo[300]
                                      : Colors.indigoAccent[100],
                            ),
                            title: Text(
                              type == 1 ? 'Full Time' : 'Part Time',
                              style: TextStyle(
                                fontFamily: 'Google',
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .fontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 30.0, bottom: 15.0),
                      child: Text(
                        'About',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.caption.color,
                            fontFamily: 'Sans',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Theme.of(context).backgroundColor,
                      ),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              FontAwesome.phone,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.indigo[300]
                                      : Colors.indigoAccent[100],
                            ),
                            title: Text(
                              phone,
                              style: TextStyle(
                                fontFamily: 'Google',
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .fontSize,
                              ),
                            ),
                          ),
                          Container(
                            height: 0.5,
                            margin: EdgeInsets.only(left: 55.0, right: 5.0),
                            color: Theme.of(context).dividerColor,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Ionicons.ios_mail,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.indigo[300]
                                      : Colors.indigoAccent[100],
                            ),
                            title: Text(
                              email,
                              style: TextStyle(
                                fontFamily: 'Google',
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .fontSize,
                              ),
                            ),
                          ),
                          Container(
                            height: 0.5,
                            margin: EdgeInsets.only(left: 55.0, right: 5.0),
                            color: Theme.of(context).dividerColor,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              FontAwesome.home,
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Colors.indigo[300]
                                      : Colors.indigoAccent[100],
                            ),
                            title: Text(
                              address,
                              style: TextStyle(
                                fontFamily: 'Google',
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .fontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 30.0, bottom: 15.0),
                      child: Text(
                        'Settings',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.caption.color,
                            fontFamily: 'Sans',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Theme.of(context).backgroundColor,
                      ),
                      child: Column(
                        children: <Widget>[
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  notif = !notif;
                                  if (notif) {
                                    _showNotif();
                                  }
                                });
                              },
                              leading: Icon(
                                Ionicons.ios_notifications,
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[300]
                                        : Colors.indigoAccent[100],
                              ),
                              title: Text(
                                'Notification',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .subhead
                                      .fontSize,
                                ),
                              ),
                              subtitle: Text(
                                'Get all notification for you',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                ),
                              ),
                              trailing: Switch(
                                  value: notif,
                                  onChanged: (value) {
                                    setState(() {
                                      notif = value;
                                      if (value) {
                                        _showNotif();
                                      }
                                    });
                                  }),
                            ),
                          ),
                          Container(
                            height: 0.5,
                            margin: EdgeInsets.only(left: 55.0, right: 5.0),
                            color: Theme.of(context).dividerColor,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              onTap: () {
                                if (collaps) {
                                  _panelController.open();
                                  setState(() {
                                    collaps = false;
                                  });
                                } else {
                                  _panelController.close();
                                  setState(() {
                                    collaps = true;
                                  });
                                }
                              },
                              leading: Icon(
                                MaterialIcons.lock,
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[300]
                                        : Colors.indigoAccent[100],
                              ),
                              title: Text(
                                'Change Passcode',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .subhead
                                      .fontSize,
                                ),
                              ),
                              subtitle: Text(
                                'Change your passcode',
                                style: TextStyle(
                                  fontFamily: 'Sans',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100.0,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text('\u00a9 2020 Absenin',
                          style: Theme.of(context).textTheme.overline),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                  ],
                ),
              ),
            )),
        onWillPop: () async {
          bool exit = false;
          if (_panelController.isPanelOpen) {
            setState(() {
              _panelController.close();
            });
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
