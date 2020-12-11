import 'dart:async';

import 'package:absenin/user/homestaff.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasscodeUser extends StatefulWidget {
  final String email, id, outlet;
  final int action;
  const PasscodeUser(
      {Key key, @required this.email, @required this.action, @required this.outlet, this.id})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PasscodeState();
  }
}

class PasscodeState extends State<PasscodeUser> {
  StreamController<ErrorAnimationType> errorController;
  TextEditingController textEditingController = TextEditingController();
  String passcode = '';
  String message = '';
  String name = '';
  String img = '';
  bool reenter = false;
  bool _canVibrate = true;
  bool _load = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Firestore fs = Firestore.instance;

  @override
  void initState() {
    getDataUserFromPref();
    errorController = StreamController<ErrorAnimationType>();
    errorController.add(ErrorAnimationType.shake);
    super.initState();
    _checkVibrate();
  }

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  void getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('namaUser');
      img = prefs.getString('imgUser');
    });
  }

  Future<FirebaseUser> signIn(String email, String passcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      FirebaseUser user = (await auth.signInWithEmailAndPassword(
              email: email, password: passcode))
          .user;
      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await auth.currentUser();
      if (user.uid == currentUser.uid) {
        prefs.setString('outletUser', widget.outlet);
        Navigator.of(context).pushAndRemoveUntil(
            _createRoute(HomePage()), (Route<dynamic> route) => false);
      }
      return user;
    } catch (e) {
      print('Error Login: $e');
      textEditingController.text = '';
      errorController.add(ErrorAnimationType.shake);
      setState(() {
        message = "Passcode don't match!";
        _load = false;
      });
      showCenterShortToast();
      if (_canVibrate) {
        Vibrate.feedback(FeedbackType.error);
      }
      return null;
    }
  }

  void registerAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      FirebaseUser user = (await auth.createUserWithEmailAndPassword(
              email: widget.email, password: passcode))
          .user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await auth.currentUser();
      if (user.uid == currentUser.uid) {
        await fs.collection('user')
          .document(widget.outlet)
          .collection('listuser')
          .document(widget.id).updateData(
            {'passcode': passcode, 'status': true, 'isSignin': true});
        if (mounted) {
          prefs.setString('outletUser', widget.outlet);
          Navigator.of(context).pushAndRemoveUntil(
              _createRoute(HomePage()), (Route<dynamic> route) => false);
        }
      }
    } catch (e) {
      print('Error Login: $e');
    }
  }

  void updatePasscodeAuth() async {
    FirebaseUser currentUser = await auth.currentUser();
    currentUser.updatePassword(passcode).then((_) async {
      await fs.collection('user')
      .document(widget.outlet)
      .collection('listuser')
      .document(widget.id).updateData({
        'passcode': passcode,
      });
      if (mounted) {
        setState(() {
          message = 'Success';
          showCenterShortToast();
          Navigator.pop(context);
        });
      }
    }).catchError((onError) {
      print(onError.toString());
    });
  }

  _checkVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  // void invisibleErrorMessage(){
  //   Timer(Duration(milliseconds: 1500), (){
  //     setState(() {
  //       message = '';
  //     });
  //   });
  // }

  void showCenterShortToast() {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: Text(widget.action == 30 ? 'Change Passcode' : 'Sign In'),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 30.0, bottom: 30.0),
              child: Column(
                children: <Widget>[
                  if (widget.action == 10)
                    Container(
                      padding: EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).dividerColor.withAlpha(10)),
                      child: ClipOval(
                          child: img != null
                              ? FadeInImage.assetNetwork(
                                  placeholder: 'assets/images/absenin_icon.png',
                                  height: 85.0,
                                  width: 85.0,
                                  image: img,
                                  fadeInDuration: Duration(seconds: 1),
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/absenin_icon.png',
                                  height: 85.0,
                                  width: 85.0,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.medium,
                                )),
                    )
                  else
                    Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.lightGreen[100]
                              : Colors.lightGreen[600],
                        ),
                        child: Icon(
                          FontAwesome.lock,
                          size: 30,
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.lightGreen[800]
                              : Colors.lightGreen[100],
                        )),
                  SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   'Hi! ${widget.email}',
                  //   style: TextStyle(
                  //     fontSize: Theme.of(context).textTheme.body1.fontSize,
                  //     fontFamily: 'Sans'
                  //   )
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.action == 10
                        ? 'Enter Passcode'
                        : reenter
                            ? 'Re-enter Your Passcode'
                            : 'Create New Passcode',
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headline.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Google'),
                  ),
                  // if (action == 10)
                  //   Text(
                  //     'Enter Passcode',
                  //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  //   )
                  // else
                  //   Text(
                  //     'Create Passcode',
                  //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  //   ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'A passcode protects your data and is used \n to unlock your account.',
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.body1.fontSize,
                        fontFamily: 'Sans',
                        color: Theme.of(context).textTheme.caption.color),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                    child: PinCodeTextField(
                      length: 6,
                      obsecureText: false,
                      autoFocus: true,
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
                      textStyle: TextStyle(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.black87
                              : Colors.white,
                          fontSize: 20.0,
                          fontFamily: 'Google',
                          fontWeight: FontWeight.bold),
                      onCompleted: (value) {
                        if (widget.action == 10) {
                          setState(() {
                            passcode = value;
                            _load = true;
                            signIn(widget.email, passcode);
                          });
                        } else {
                          if (!reenter) {
                            textEditingController.text = '';
                            errorController.add(ErrorAnimationType.shake);
                            setState(() {
                              passcode = value;
                              reenter = true;
                            });
                          } else {
                            if (value == passcode) {
                              setState(() {
                                passcode = value;
                                _load = true;
                                if (widget.action == 30) {
                                  updatePasscodeAuth();
                                } else {
                                  registerAuth();
                                }
                              });
                            } else {
                              textEditingController.text = '';
                              errorController.add(ErrorAnimationType.shake);
                              setState(() {
                                message = "Passcode don't match!";
                              });
                              showCenterShortToast();
                              if (_canVibrate) {
                                Vibrate.feedback(FeedbackType.error);
                              }
                              // invisibleErrorMessage();
                            }
                          }
                        }
                      },
                      onChanged: (value) {
                        print(value);
                        // setState(() {
                        //   passcode = value;
                        // });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  if (_load)
                    Container(
                      padding: EdgeInsets.only(
                          left: 10.0, right: 20.0, top: 8.0, bottom: 8.0),
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(50.0)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Loading...',
                            style: TextStyle(
                                fontSize:
                                    Theme.of(context).textTheme.body1.fontSize,
                                fontFamily: 'Sans',
                                color: Theme.of(context).accentColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  if (reenter)
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          passcode = '';
                          reenter = false;
                          textEditingController.text = '';
                        });
                      },
                      child: Text(
                        'Reset Passcode',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold),
                      ),
                      color: Theme.of(context).buttonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      splashColor: Colors.black26,
                      highlightColor: Colors.black26,
                    ),
                ],
              ),
            ),
          )),
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
