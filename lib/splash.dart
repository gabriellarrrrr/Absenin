import 'dart:async';
import 'package:absenin/login.dart';
import 'package:absenin/supervisor/passcodespv.dart';
import 'package:absenin/user/passcode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;
  int role = 0;
  String outlet;

  @override
  void initState() {
    super.initState();
    getDataUserFromPref();
  }

  _getCurrentUser() async {
    FirebaseUser currentUser = await auth.currentUser();
    if (currentUser != null) {
      if (role == 0) {
        Timer(Duration(seconds: 1), () {
          Navigator.of(context).pushReplacement(_createRoute(PasscodeSpv(
            email: currentUser.email,
            outlet: outlet,
          )));
        });
      } else {
        await firestore
        .collection('user')
        .document(outlet)
        .collection('listuser')
        .where('email', isEqualTo: currentUser.email).getDocuments().then((snapshot){
          if(snapshot.documents.isNotEmpty){
            snapshot.documents.forEach((f) async {
              if(f.data['delete']){
                await currentUser.delete();
                if(mounted){
                  await firestore
                  .collection('user')
                  .document(outlet)
                  .collection('listuser')
                  .document(f.documentID).delete();
                  if(mounted){
                    Timer(Duration(seconds: 1), () {
                      Navigator.of(context).pushReplacement(_createRoute(SignIn()));
                    });
                  }
                }
              } else {
                Timer(Duration(seconds: 1), () {
                  Navigator.of(context).pushReplacement(_createRoute(PasscodeUser(
                    email: currentUser.email,
                    action: 10,
                    outlet: outlet,
                  )));
                });
              }
            });
          }
        });
      }
    } else {
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(_createRoute(SignIn()));
      });
    }
  }

  void getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getInt('roleUser');
      outlet = prefs.getString('outletUser');
      _getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/absenin.png",
          width: 220,
          height: 220,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  Route _createRoute(Widget destination) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
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
