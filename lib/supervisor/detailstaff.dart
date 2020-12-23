import 'package:absenin/supervisor/addstaf.dart';
import 'package:absenin/user/photoview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailStaff extends StatefulWidget {
  final String id, name, position, outlet, phone, address, emails, enrol, img;
  final int type;
  final bool signin;

  const DetailStaff(
      {Key key,
      @required this.id,
      @required this.name,
      @required this.position,
      @required this.outlet,
      @required this.phone,
      @required this.address,
      @required this.emails,
      @required this.enrol,
      @required this.img,
      @required this.type,
      @required this.signin})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DetailStaffState();
  }
}

class DetailStaffState extends State<DetailStaff> {
  final Firestore firestore = Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String url_downloadApp;
  bool update = false;
  String urlImg;

  @override
  void initState() {
    super.initState();
    _getDataUserFromPref();
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      url_downloadApp = prefs.getString('d_absenin');
    });
  }

  void deleteAccount() async {
    if (widget.signin) {
      await firestore
          .collection('user')
          .document(widget.outlet)
          .collection('listuser')
          .document(widget.id)
          .updateData({'delete': true});
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true);
      }
    } else {
      await firestore
          .collection('user')
          .document(widget.outlet)
          .collection('listuser')
          .document(widget.id)
          .delete();
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true);
      }
    }
  }

  void sendEmailResetPasscode() async {
    await auth.sendPasswordResetEmail(email: widget.emails);
    if (mounted) {
      Navigator.pop(context);
      showCenterShortToast('Success');
    }
  }

  void _sendEmail() async {
    String username = 'official.absenin@gmail.com';
    String password = 'Absenin2020';

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Absenin Official')
      ..recipients.add('${widget.emails}')
      ..subject = "Hi! ${widget.name}. Here's your Absenin Account"
      ..html =
          "<h1>Welcome to Absenin!</h1><br><br><center><img src='https://i.ibb.co/9nk62sz/Group-29.png' width='235'></center><br><br><p style='font-size: 18px'><b>This is your Account😊</b></p><p style='font-size: 14px'>Email : <span style='font-size: 20px; font-weight: bold'>${widget.emails}</span></p><p style='font-size: 14px'>Enrol Key : <span style='font-size: 20px; font-weight: bold'>${widget.enrol}</span></p><br><br><br><center><button style='background-color: #37474f; color: white; border-radius: 8px; padding: 8px 20px; text-align: center; text-decoration: none; margin: 2px;'><a href ='$url_downloadApp'>Download App</a></button></center><p style='text-align: center;'><i>Open Your Apps and Enjoy!</i> \u00a9 2020 Absenin</p>";

    try {
      final sendReport = await send(message, smtpServer);
      Navigator.pop(context);
      showCenterShortToast('Succes sent enrol to ${widget.emails}');
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      Navigator.pop(context);
      showCenterShortToast('Failed sent enrol! Try again');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
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

  void _showAlertDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
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
                          'Delete this Account?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Google',
                              fontSize:
                                  Theme.of(context).textTheme.subhead.fontSize),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Image.asset(
                      'assets/images/delete.png',
                      height: 200,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(
                      height: 0.5,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                          onPressed: () {
                            deleteAccount();
                            Navigator.pop(context);
                            _prosesDialog();
                          },
                          child: Text(
                            'Yes',
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                    Divider(
                      height: 0.5,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'No',
                            style: TextStyle(
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold,
                                color:
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.light
                                        ? Colors.black54
                                        : Colors.grey[400]),
                          )),
                    )
                  ],
                ),
              ],
            )));
  }

  void _gotoAddStaff() async {
    final result = await Navigator.of(context).push(_createRoute(AddStaf(
      action: 20,
      id: widget.id,
      name: widget.name,
      position: widget.position,
      outlet: widget.outlet,
      phone: widget.phone,
      address: widget.address,
      emails: widget.emails,
      img: widget.img,
      type: widget.type,
    )));

    if (result != null && result != false) {
      Navigator.pop(context, true);
    }
  }

  void showCenterShortToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Staff'),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                MaterialIcons.edit,
                size: 20.0,
              ),
              onPressed: () {
                _gotoAddStaff();
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 30, bottom: 10),
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
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PhotoPage(
                                      urlImg: widget.img,
                                      id: widget.id,
                                      outlet: widget.outlet,
                                      nama: widget.name,
                                    )));
                        if (result != null) {
                          if (result != 'null') {
                            setState(() {
                              urlImg = result;
                              update = true;
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
                            imageUrl: update ? urlImg : widget.img,
                            height: 100.0,
                            width: 100.0,
                            fit: BoxFit.cover,
                          )
                              //     FadeInImage.assetNetwork(
                              //   placeholder: 'assets/images/absenin.png',
                              //   height: 100.0,
                              //   width: 100.0,
                              //   image: update ? urlImg : widget.img,
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
                      widget.name,
                      style: TextStyle(
                          fontSize: Theme.of(context).textTheme.title.fontSize,
                          fontFamily: 'Google'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(widget.position,
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
                    leading: Icon(
                      FontAwesome.bullseye,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      widget.outlet,
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
                    leading: Icon(
                      FontAwesome.id_badge,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.indigo[300]
                          : Colors.indigoAccent[100],
                    ),
                    title: Text(
                      widget.type == 1 ? 'Full Time' : 'Part Time',
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
                      leading: Icon(
                        FontAwesome.key,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.indigo[300]
                            : Colors.indigoAccent[100],
                      ),
                      title: Text(
                        widget.enrol,
                        style: TextStyle(
                          fontFamily: 'Google',
                          fontSize:
                              Theme.of(context).textTheme.subhead.fontSize,
                        ),
                      ),
                      trailing: ClipOval(
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                              icon: Icon(
                                FontAwesome.share_alt,
                                size: 18,
                              ),
                              onPressed: () {
                                _prosesDialog();
                                _sendEmail();
                              }),
                        ),
                      )),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        FontAwesome.phone,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.indigo[300]
                            : Colors.indigoAccent[100],
                      ),
                      title: Text(
                        widget.phone,
                        style: TextStyle(
                          fontFamily: 'Google',
                          fontSize:
                              Theme.of(context).textTheme.subhead.fontSize,
                        ),
                      ),
                    ),
                    Container(
                      height: 0.5,
                      margin: EdgeInsets.only(left: 55.0, right: 5.0),
                      color: Theme.of(context).dividerColor,
                    ),
                    ListTile(
                      leading: Icon(
                        Ionicons.ios_mail,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.indigo[300]
                            : Colors.indigoAccent[100],
                      ),
                      title: Text(
                        widget.emails,
                        style: TextStyle(
                          fontFamily: 'Google',
                          fontSize:
                              Theme.of(context).textTheme.subhead.fontSize,
                        ),
                      ),
                    ),
                    Container(
                      height: 0.5,
                      margin: EdgeInsets.only(left: 55.0, right: 5.0),
                      color: Theme.of(context).dividerColor,
                    ),
                    ListTile(
                      leading: Icon(
                        FontAwesome.home,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.indigo[300]
                            : Colors.indigoAccent[100],
                      ),
                      title: Text(
                        widget.address,
                        style: TextStyle(
                          fontFamily: 'Google',
                          fontSize:
                              Theme.of(context).textTheme.subhead.fontSize,
                        ),
                      ),
                    ),
                  ],
                ),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        onTap: () {
                          _prosesDialog();
                          sendEmailResetPasscode();
                        },
                        leading: Icon(
                          MaterialIcons.lock,
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.indigo[300]
                              : Colors.indigoAccent[100],
                        ),
                        title: Text(
                          'Reset Passcode',
                          style: TextStyle(
                            fontFamily: 'Google',
                            fontSize:
                                Theme.of(context).textTheme.subhead.fontSize,
                          ),
                        ),
                        subtitle: Text(
                          'Reset user passcode',
                          style: TextStyle(
                            fontFamily: 'Sans',
                          ),
                        ),
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
                          _showAlertDialog();
                        },
                        leading: Icon(
                          MaterialIcons.delete_forever,
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Colors.indigo[300]
                              : Colors.indigoAccent[100],
                        ),
                        title: Text(
                          'Delete Account',
                          style: TextStyle(
                            fontFamily: 'Google',
                            fontSize:
                                Theme.of(context).textTheme.subhead.fontSize,
                          ),
                        ),
                        subtitle: Text(
                          'Delete user account',
                          style: TextStyle(
                            fontFamily: 'Sans',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
