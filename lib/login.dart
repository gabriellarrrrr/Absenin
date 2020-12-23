import 'dart:async';
import 'package:absenin/anim/FadeDown.dart';
import 'package:absenin/anim/FadeUp.dart';
import 'package:absenin/supervisor/passcodespv.dart';
import 'package:absenin/user/enrol.dart';
import 'package:absenin/user/help.dart';
import 'package:absenin/user/passcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignInState();
  }
}

class SignInState extends State<SignIn> {
  final PanelController _panelController = new PanelController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  String email, message, outlet;
  bool collaps = true;
  bool autoVal = false;
  bool clicked = false;
  bool incorent = false;
  double widthCircular = 0;
  double heightCircular = 0;
  final firestore = Firestore.instance;
  List<String> listOutlet = List<String>();

  @override
  void initState() {
    super.initState();
    _getOutletFromDb();
  }

  _getOutletFromDb() async {
    //ambil list outlet
    firestore.collection('outlet').getDocuments().then((snapshot) {
      if (snapshot.documents.isEmpty) {
        print('No data to display');
      } else {
        listOutlet.clear();
        snapshot.documents.forEach((f) {
          setState(() {
            listOutlet.add(f.data['name']);
          });
        });
      }
    });
  }

  String validateEmail(String email) {
    if (email.isEmpty) {
      return 'Masukkan email!';
    } else if (incorent) {
      return 'Email tidak valid!';
    }
    return null;
  }

  void checkEmail() async {
    //method ketika signin di klik
    firestore
        .collection('user')
        .document(outlet)
        .collection('listuser')
        .where('email', isEqualTo: email)
        .getDocuments()
        .then((data) {
      if (data.documents.isNotEmpty) {
        //kalau email ada
        data.documents.forEach((f) {
          String id = f.documentID;
          int role = f.data['role'];

          if (role == 0) {
            bool statusin = f.data['status'];
            Timer(Duration(seconds: 2), () {
              Navigator.of(context).push(_createRoute(PasscodeSpv(
                  id: id, email: email, outlet: outlet, status: statusin)));
              setState(() {
                clicked = false;
                widthCircular = 0;
                heightCircular = 0;
                autoVal = false;
              });
            });
          } else {
            //role = 1
            String enrol = f.data['enrol'];
            print('Enrol key: $enrol');
            bool statusin = f.data['status'];
            bool isSignin = f.data['isSignin'];
            if (statusin) {
              //statusin = true -> ketika sudah enrol
              if (!isSignin) {
                //issignin = true -> ketika sudah berhasil bikin passcode
                Timer(Duration(seconds: 2), () {
                  Navigator.of(context).push(_createRoute(PasscodeUser(
                    email: email,
                    action: 10,
                    outlet: outlet,
                  )));
                  setState(() {
                    clicked = false;
                    widthCircular = 0;
                    heightCircular = 0;
                    autoVal = false;
                  });
                });
              } else {
                //cek kalau issignin = true, tdk bs signin lagi
                Timer(Duration(seconds: 2), () {
                  setState(() {
                    widthCircular = 0;
                    heightCircular = 0;
                    clicked = false;
                    incorent = true;
                    message = "You've already Sign In on another device!";
                    _showAlertDialog();
                  });
                });
              }
            } else {
              //cek statusin = false -> enrol dulu
              Timer(Duration(seconds: 2), () {
                Navigator.of(context).push(_createRoute(EnrollKey(
                  email: email, //untuk di daftar ke auth
                  enrol: enrol,
                  outlet: outlet,
                  id: id, //untuk rubah status dan signin
                )));
                setState(() {
                  clicked = false;
                  widthCircular = 0;
                  heightCircular = 0;
                  autoVal = false;
                });
              });
            }
          }
        });
      } else {
        //kalau email tidak ada atau null
        Timer(Duration(seconds: 2), () {
          setState(() {
            widthCircular = 0;
            heightCircular = 0;
            clicked = false;
            incorent = true;
            message = 'Email not registered!';
            _showAlertDialog();
          });
        });
      }
    });
  }

  void _showOutletDialog() {
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
                        'Choose your office',
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.title.fontSize,
                            fontFamily: 'Google'),
                      ),
                    )),
                Divider(
                  height: 0.0,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: listOutlet.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: <Widget>[
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  outlet = listOutlet[index];
                                });
                                Navigator.pop(context);
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
                                Ionicons.md_locate,
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.indigo[300]
                                        : Colors.indigoAccent[100],
                              ),
                              title: Text(
                                listOutlet[index],
                                style: TextStyle(fontFamily: 'Google'),
                              ),
                            ),
                          ),
                          if (index != listOutlet.length - 1)
                            Container(
                              margin: EdgeInsets.only(left: 70.0),
                              height: 0.5,
                              color: Theme.of(context).dividerColor,
                            )
                        ],
                      );
                    }),
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
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 30.0, right: 20.0, bottom: 30.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Attention',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Google',
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .subhead
                                    .fontSize),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            '$message',
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption.color,
                                fontFamily: 'Sans',
                                fontSize:
                                    Theme.of(context).textTheme.body1.fontSize),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
                        child: Text(
                          'Close',
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
                    )
                  ],
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(
                    Feather.x,
                    size: Theme.of(context).appBarTheme.iconTheme.size,
                  ),
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  }),
              title: Text('Sign In'),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Feather.help_circle,
                      size: Theme.of(context).appBarTheme.iconTheme.size,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(_createRoute(Help()));
                    }),
              ],
            ),
            body: SlidingUpPanel(
              minHeight: 0.0,
              maxHeight: MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio > 1500 ? MediaQuery.of(context).size.height * 0.55 : MediaQuery.of(context).size.height * 0.65,
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
                  emailController.text = '';
                  incorent = false;
                });
              },
              panel: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    padding: EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 10.0, bottom: 30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 35.0,
                              height: 5.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Theme.of(context).dividerColor),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .fontSize,
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold),
                            ),
                            AnimatedContainer(
                              width: widthCircular,
                              height: heightCircular,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.fastOutSlowIn,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.blue
                                        : Colors.blue[300]),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          'Email Address',
                          style: Theme.of(context).textTheme.caption,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Form(
                            key: formKey,
                            autovalidate: autoVal,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: emailController,
                                  validator: validateEmail,
                                  onSaved: (value) {
                                    email = value;
                                  },
                                  decoration: InputDecoration(
                                      helperText: 'example@mail.com',
                                      hintText: 'Enter your email address',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(
                                        Feather.mail,
                                        size: 20.0,
                                      )),
                                  keyboardType: TextInputType.emailAddress,
                                  maxLength: 50,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .fontSize,
                                      fontFamily: 'Sans'),
                                )
                              ],
                            )),
                        SizedBox(
                          height: 60,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Next',
                              style: TextStyle(
                                  color: !clicked
                                      ? Theme.of(context).buttonColor
                                      : Theme.of(context).dividerColor,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .title
                                      .fontSize,
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold),
                            ),
                            ClipOval(
                                child: SizedBox(
                              width: 55.0,
                              height: 55.0,
                              child: Material(
                                color: !clicked
                                    ? Theme.of(context).buttonColor
                                    : Theme.of(context).dividerColor,
                                child: IconButton(
                                  icon: Icon(
                                    Feather.chevron_right,
                                    color: Colors.white,
                                  ),
                                  onPressed: !clicked
                                      ? () {
                                          final formVal = formKey.currentState;
                                          if (formVal.validate()) {
                                            setState(() {
                                              clicked = true;
                                              autoVal = true;
                                              widthCircular = 18.0;
                                              heightCircular = 18.0;
                                            });
                                            formVal.save();
                                            checkEmail();
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          } else {
                                            autoVal = true;
                                          }
                                        }
                                      : null,
                                  splashColor: Colors.black26,
                                  highlightColor: Colors.black26,
                                ),
                              ),
                            )),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, right: 25.0, top: 70.0, bottom: 50.0),
                  child: Column(
                    children: <Widget>[
                      FadeDown(
                        1.0,
                        Image.asset(
                          'assets/images/main.png',
                          width: MediaQuery.of(context).size.width * 0.6,
                        ),
                      ),
                      SizedBox(
                        height: 60.0,
                      ),
                      FadeDown(
                        1.5,
                        Text(
                          'Absenin',
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.headline4.fontSize,
                            fontFamily: 'Google',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      FadeDown(
                        2.0,
                        Text(
                          'Helps you manage your attendance easily. Make everything easy just in your hand!',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Sans',
                              color: Theme.of(context).textTheme.caption.color),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 70.0,
                      ),
                      FadeUp(
                        3.0,
                        SizedBox(
                            width: 120.0,
                            height: 42.0,
                            child: FlatButton(
                              onPressed: () {
                                _showOutletDialog();
                              },
                              child: Text(
                                'Start',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontFamily: 'Google',
                                    fontWeight: FontWeight.bold),
                              ),
                              color: Theme.of(context).buttonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              splashColor: Colors.black26,
                              highlightColor: Colors.black26,
                            )),
                      ),
                      SizedBox(
                        height: 100.0,
                      )
                    ],
                  ),
                ),
              ),
            )),
        onWillPop: _onBackPressed);
  }

  Future<bool> _onBackPressed() {
    return _panelController.isPanelOpen
        ? _panelController.close()
        : SystemChannels.platform.invokeMethod('SystemNavigator.pop');
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
