import 'dart:async';

import 'package:absenin/user/passcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class EnrollKey extends StatefulWidget {
  final String email, enrol, outlet, id;

  const EnrollKey(
      {Key key,
      @required this.email,
      @required this.enrol,
      @required this.outlet,
      @required this.id})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return EnrollKeyState();
  }
}

class EnrollKeyState extends State<EnrollKey> {
  StreamController<ErrorAnimationType> errorController;
  TextEditingController textEditingController = TextEditingController();
  String message = '';
  bool _canVibrate = false;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    errorController.add(ErrorAnimationType.shake);
    super.initState();
    _checkVibrate();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    errorController.close();
    super.dispose();
  }

  // void invisibleErrorMessage(){
  //   Timer(Duration(milliseconds: 1500), (){
  //     setState(() {
  //       message = '';
  //     });
  //   });
  // }

  _checkVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  void showCenterShortToast() {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }

  String validateEmail(String enrolkey) {
    if (enrolkey.isEmpty) {
      return 'Masukkan Enrol Key!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Sign In'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 30.0, bottom: 30.0),
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[100]
                          : Colors.indigo[600],
                    ),
                    child: Icon(
                      FontAwesome.send,
                      size: 30,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[800]
                          : Colors.indigo[100],
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
                  'Enter Enrol Key',
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
                  'To continue, please enter the enrol key that you already have.',
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
                    errorAnimationController: errorController, //error
                    controller: textEditingController, //nampung inputan
                    textInputType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textStyle: TextStyle(
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.black87
                            : Colors.white,
                        fontSize: 20.0,
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold),
                    onCompleted: (value) {
                      //ketika sudah keisi ditampung di variabel value
                      if (value == widget.enrol.toUpperCase()) {
                        print('Enrol Diterima');
                        Navigator.of(context)
                            .pushReplacement(_createRoute(PasscodeUser(
                          email: widget.email,
                          action: 20, //aksi create passcode baru
                          outlet: widget.outlet,
                          id: widget.id,
                        )));
                      } else {
                        textEditingController.text =
                            ''; //di kosongin karena gak sesuai
                        errorController
                            .add(ErrorAnimationType.shake); //efek goyang
                        setState(() {
                          message = 'Enrol salah!';
                        });
                        showCenterShortToast();
                        if (_canVibrate) {
                          Vibrate.feedback(FeedbackType.error);
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
                // Container(
                //   padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                //   decoration: BoxDecoration(
                //     color: message != '' && message != 'Loading...' ? MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.red[100] : Colors.red[600] : Theme.of(context).primaryColor,
                //     borderRadius: BorderRadius.circular(50.0)
                //   ),
                //   child: Text(
                //     message,
                //     style: TextStyle(
                //       fontSize: Theme.of(context).textTheme.body1.fontSize,
                //       fontFamily: 'Sans',
                //       color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.red[800] : Colors.grey[300],
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
              ],
            ),
          ),
        ));
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
