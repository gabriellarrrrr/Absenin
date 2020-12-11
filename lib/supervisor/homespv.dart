import 'package:absenin/login.dart';
import 'package:absenin/supervisor/approval.dart';
import 'package:absenin/supervisor/profilespv.dart';
import 'package:absenin/supervisor/report.dart';
import 'package:absenin/supervisor/liststaff.dart';
import 'package:absenin/supervisor/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpvHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SpvHomeState();
  }
}

class Menu {
  final String title, img;

  Menu(this.title, this.img);
}

class SpvHomeState extends State<SpvHome> {
  Menu menu1 = new Menu('Schedule', 'assets/images/schedule.png');
  Menu menu2 = new Menu('Staff', 'assets/images/staff.png');
  Menu menu3 = new Menu('Approve', 'assets/images/approve.png');
  Menu menu4 = new Menu('Report', 'assets/images/report.png');

  String id = '',
      name = '',
      img = '',
      position = '',
      outlet = '',
      phone = '',
      email = '',
      address = '',
      passcode = '';
  int role = 0;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;

  void onClick(String title) {
    if (title == 'Schedule') {
      Navigator.of(context).push(_createRoute(Schedule()));
    } else if (title == 'Staff') {
      Navigator.of(context).push(_createRoute(Staff(
        action: 10,
      )));
    } else if (title == 'Approve') {
      Navigator.of(context).push(_createRoute(Approval()));
    } else if (title == 'Report') {
      Navigator.of(context).push(_createRoute(ReportPage()));
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseUser currentUser = await auth.currentUser();
    outlet = prefs.getString('outletUser');
    firestore
        .collection('user')
        .document(outlet)
        .collection('listuser')
        .where('email', isEqualTo: currentUser.email)
        .snapshots()
        .listen((data) {
      if (data.documents.isNotEmpty) {
        data.documents.forEach((f) {
          setState(() {
            id = f.documentID;
            name = f.data['name'];
            position = f.data['position'];
            img = f.data['img'];
            phone = f.data['phone'];
            email = f.data['email'];
            address = f.data['address'];
            role = f.data['role'];
            passcode = f.data['passcode'];
            prefs.setString('idUser', id);
            prefs.setString('namaUser', name);
            prefs.setString('positionUser', position);
            prefs.setString('imgUser', img);
            prefs.setString('phoneUser', phone);
            prefs.setString('emailUser', email);
            prefs.setString('addressUser', address);
            prefs.setInt('roleUser', role);
            prefs.setString('passcodeUser', passcode);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Menu> menu = [menu1, menu2, menu3, menu4];
    return Scaffold(
      appBar: AppBar(
        // leading: Image.asset(
        //   'assets/images/absenin.png',
        //   width: 20.0,
        //   height: 20.0,
        // ),
        title: Text('Absenin'),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Feather.settings,
                color: MediaQuery.of(context).platformBrightness ==
                        Brightness.light
                    ? Colors.indigo
                    : Colors.indigo[300],
                size: 20.0,
              ),
              onPressed: () {
                Navigator.of(context).push(_createRoute(ProfileSpv()));
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 30.0, bottom: 50.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).dividerColor.withAlpha(10)),
                    child: ClipOval(
                        child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/absenin_icon.png',
                      height: 85.0,
                      width: 85.0,
                      image: img,
                      fadeInDuration: Duration(seconds: 1),
                      fit: BoxFit.cover,
                    )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.headline,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(position,
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.orange[800]
                            : Colors.orange[300],
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 40.0,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Feather.layers,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Colors.indigo
                        : Colors.indigo[300],
                    size: 18.0,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Menu',
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.subhead.fontSize,
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Colors.indigo
                            : Colors.indigo[300]),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: menu.map((index) {
                  return Container(
                    margin: EdgeInsets.only(
                        left: 10, right: 10.0, top: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.transparent
                                : Colors.grey[300],
                            offset: Offset(3.0, 3.0),
                            blurRadius: 8.0,
                          )
                        ]),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        // side: BorderSide(
                        //   color: Theme.of(context).dividerColor,
                        //   width: 3.0
                        // )
                      ),
                      onPressed: () {
                        onClick(index.title);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Image.asset(
                            index.img,
                            width: 120,
                            filterQuality: FilterQuality.medium,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            index.title,
                            style: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.subhead.fontSize,
                              fontFamily: 'Sans',
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
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
