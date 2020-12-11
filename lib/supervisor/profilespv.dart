import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';

class ProfileSpv extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileSpvState();
  }
}

class ProfileSpvState extends State<ProfileSpv> {
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
  bool collaps = true;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getDataUserFromPref();
  }

   _signOutFromAuth() async {
    if (auth.currentUser() != null) {
      await auth.signOut();
      if (mounted) {
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(_createRoute(SignIn()), (Route<dynamic> route) => false);
      }
    }
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
      passcode = prefs.getString('passcodeUser');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding:
                  EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0)),
                color: Theme.of(context).backgroundColor,
              ),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoPage()));
                      },
                      child: Hero(
                        tag: 'photo',
                        child: Container(
                          padding: EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).dividerColor),
                          child: ClipOval(
                              child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/absenin.png',
                            height: 100.0,
                            width: 100.0,
                            image: img,
                            fadeInDuration: Duration(seconds: 1),
                            fit: BoxFit.cover,
                          )),
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
                          fontSize: Theme.of(context).textTheme.title.fontSize,
                          fontFamily: 'Google'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(position,
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                        color: MediaQuery.of(context).platformBrightness ==
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
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      outlet,
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
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
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      phone,
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
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
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      email,
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
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
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      address,
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
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
              padding: EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Theme.of(context).backgroundColor,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 0.5,
                    margin: EdgeInsets.only(left: 55.0, right: 5.0),
                    color: Theme.of(context).dividerColor,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Ionicons.ios_notifications,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Notification',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
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
                          });
                        }),
                  ),
                  Container(
                    height: 0.5,
                    margin: EdgeInsets.only(left: 55.0, right: 5.0),
                    color: Theme.of(context).dividerColor,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      MaterialIcons.lock,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Change Passcode',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      ),
                    ),
                    subtitle: Text(
                      'Change your passcode',
                      style: TextStyle(
                        fontFamily: 'Sans',
                      ),
                    ),
                  ),
                  Container(
                    height: 0.5,
                    margin: EdgeInsets.only(left: 55.0, right: 5.0),
                    color: Theme.of(context).dividerColor,
                  ),
                  ListTile(
                    onTap: (){
                      _signOutFromAuth();
                    },
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Feather.log_out,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                      ),
                    ),
                    subtitle: Text(
                      'Sign out your current account',
                      style: TextStyle(
                        fontFamily: 'Sans',
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
              height: 50.0,
            ),
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
