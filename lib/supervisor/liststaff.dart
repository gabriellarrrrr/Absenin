import 'package:absenin/supervisor/addstaf.dart';
import 'package:absenin/supervisor/detailstaff.dart';
import 'package:absenin/transition/revealroute.dart';
import 'package:content_placeholder/content_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Staff extends StatefulWidget {
  final int action;
  final List<StaffItem> listCurrent;

  const Staff({Key key, @required this.action, this.listCurrent})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StaffState();
  }
}

class StaffItem {
  String id;
  String img;
  String name;
  String position;
  int type;
  String phone;
  String address;
  String email;
  String outlet;
  bool check;
  bool signin;
  String enrol;

  StaffItem(
    this.id,
    this.img,
    this.name,
    this.position,
    this.type,
    this.check,
    this.phone,
    this.address,
    this.email,
    this.outlet,
    this.enrol,
    this.signin
  );
}

class StaffState extends State<Staff> {
  List<StaffItem> listStaff = new List<StaffItem>();
  ScrollController controller;
  bool fabIsVisible = true;
  bool isEmptyy = false;
  final Firestore db = Firestore.instance;
  String outlet;

  @override
  void initState() {
    super.initState();
    _getDataUserFromPref();
    controller = ScrollController();
    controller.addListener(() {
      setState(() {
        fabIsVisible =
            controller.position.userScrollDirection == ScrollDirection.forward;
      });
    });
  }

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
      getStaff();
    });
  }

  void getStaff() async {
      db
        .collection('user')
        .document(outlet)
        .collection('listuser')
        .where('role', isEqualTo: 1)
        .where('delete', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.documents.isEmpty) {
        setState(() {
          isEmptyy = true;
        });
      } else {
        listStaff.clear();
        snapshot.documents.forEach((f) {
          StaffItem item = new StaffItem(
              f.documentID,
              f.data['img'],
              f.data['name'],
              f.data['position'],
              f.data['type'],
              false,
              f.data['phone'],
              f.data['address'],
              f.data['email'],
              f.data['outlet'],
              f.data['enrol'],
              f.data['isSignin']);
          setState(() {
            listStaff.add(item);
          });
        });
        if (widget.action == 20) {
          if (widget.listCurrent.length > 0) {
            for (int i = 0; i < listStaff.length; i++) {
              for (int j = 0; j < widget.listCurrent.length; j++) {
                if (listStaff[i].id == widget.listCurrent[j].id) {
                  listStaff[i].check = true;
                }
              }
            }
          }
        }
      }
    });
  }

  // void _gotoDetailStaff(int index) async {
  //   final result = await Navigator.of(context).push(_createRoute(DetailStaff(
  //     id: listStaff[index].id,
  //     name: listStaff[index].name,
  //     position: listStaff[index].position,
  //     outlet: listStaff[index].outlet,
  //     phone: listStaff[index].phone,
  //     address: listStaff[index].address,
  //     emails: listStaff[index].email,
  //     enrol: listStaff[index].enrol,
  //     img: listStaff[index].img,
  //     type: listStaff[index].type,
  //     signin: listStaff[index].signin,
  //   )));
  //   if (result != null && result != false) {
  //     listStaff.clear();
  //     getStaff();
  //   }
  // }

  // void _gotoAddStaff() async {
  //   final result = await Navigator.push(
  //     context,
  //     RevealRoute(
  //       page: AddStaf(
  //         action: 10,
  //       ),
  //       maxRadius: MediaQuery.of(context).size.height + 100,
  //       centerAlignment: Alignment.bottomRight,
  //     ),
  //   );
  //   if (result != null && result != false) {
  //     listStaff.clear();
  //     getStaff();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Theme.of(context).backgroundColor
              : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.action == 10 ? 'List Staff' : 'Choose Staff'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Ionicons.ios_search),
              onPressed: () {
                List user = List();
                for (int i = 0; i < listStaff.length; i++) {
                  user.add(listStaff[i].name);
                }
                showSearch(context: context, delegate: DataSearch(user, listStaff));
              }),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        child: widget.action == 10
            ? FloatingActionButton(
                child: Icon(Icons.add, size: 24.0, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    RevealRoute(
                      page: AddStaf(
                        action: 10,
                      ),
                      maxRadius: MediaQuery.of(context).size.height + 100,
                      centerAlignment: Alignment.bottomRight,
                    ),
                  );
                })
            : FloatingActionButton(
                child: Icon(Icons.done, size: 24.0, color: Colors.white),
                onPressed: () {
                  List<StaffItem> listChoose = new List<StaffItem>();
                  for (int i = 0; i < listStaff.length; i++) {
                    if (listStaff[i].check) {
                      listChoose.add(listStaff[i]);
                    }
                  }
                  Navigator.pop(context, listChoose);
                }),
        opacity: fabIsVisible ? 1 : 0,
        duration: Duration(milliseconds: 300),
      ),
      body: SingleChildScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            if (listStaff.length > 0)
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: listStaff.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        Material(
                            color: Colors.transparent,
                            child: ListTile(
                                onTap: () {
                                  if (widget.action == 10) {
                                    // _gotoDetailStaff(index);
                                    Navigator.of(context).push(_createRoute(DetailStaff(
                                      id: listStaff[index].id,
                                      name: listStaff[index].name,
                                      position: listStaff[index].position,
                                      outlet: listStaff[index].outlet,
                                      phone: listStaff[index].phone,
                                      address: listStaff[index].address,
                                      emails: listStaff[index].email,
                                      enrol: listStaff[index].enrol,
                                      img: listStaff[index].img,
                                      type: listStaff[index].type,
                                      signin: listStaff[index].signin,
                                    )));
                                  } else {
                                    setState(() {
                                      listStaff[index].check =
                                          !listStaff[index].check;
                                    });
                                  }
                                },
                                leading: ClipOval(
                                    child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/images/absenin.png',
                                  height: 50.0,
                                  width: 50.0,
                                  image: listStaff[index].img,
                                  fadeInDuration: Duration(seconds: 1),
                                  fit: BoxFit.cover,
                                )),
                                title: Text(
                                  listStaff[index].name,
                                  style: TextStyle(fontFamily: 'Google'),
                                ),
                                subtitle: Text(
                                  widget.action == 10
                                      ? listStaff[index].position
                                      : listStaff[index].type == 1
                                          ? 'Full Time'
                                          : 'Part Time',
                                  style: TextStyle(fontFamily: 'Sans'),
                                ),
                                trailing: widget.action == 10
                                    ? Icon(
                                        Feather.chevron_right,
                                      )
                                    : ClipOval(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: IconButton(
                                              icon: Icon(
                                                listStaff[index].check
                                                    ? Icons.check_circle
                                                    : Icons.panorama_fish_eye,
                                                size: 20.0,
                                                color: listStaff[index].check
                                                    ? MediaQuery.of(context)
                                                                .platformBrightness ==
                                                            Brightness.light
                                                        ? Colors.green
                                                        : Colors.green[400]
                                                    : Theme.of(context)
                                                        .disabledColor,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  listStaff[index].check =
                                                      !listStaff[index].check;
                                                });
                                              }),
                                        ),
                                      ))),
                        if (index != listStaff.length - 1)
                          Container(
                            height: 0.5,
                            margin: EdgeInsets.only(left: 80.0),
                            color: Theme.of(context).dividerColor,
                          )
                      ],
                    );
                  })
            else if (!isEmptyy)
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        if (index == 0)
                          SizedBox(
                            height: 10.0,
                          ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 15.0,
                            ),
                            ContentPlaceholder(
                              height: 50.0,
                              width: 50.0,
                              spacing: EdgeInsets.zero,
                              borderRadius: 100.0,
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ContentPlaceholder(
                                  height: 20,
                                  width: 160,
                                  spacing: EdgeInsets.zero,
                                ),
                                ContentPlaceholder(
                                  height: 15,
                                  width: 90,
                                  spacing: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            Spacer(),
                            ContentPlaceholder(
                              height: 20,
                              width: 20,
                              spacing: EdgeInsets.zero,
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                          ],
                        ),
                        if (index != 14)
                          Container(
                            margin: EdgeInsets.only(left: 80.0),
                            child: ContentPlaceholder(
                              height: 1,
                              width: double.infinity,
                              spacing: EdgeInsets.zero,
                            ),
                          )
                      ],
                    );
                  })
            else
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.2),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Image.asset(
                        'assets/images/nodata.png',
                        width: MediaQuery.of(context).size.width * 0.6,
                      ),
                    ),
                    SizedBox(
                      height: 18.0,
                    ),
                    Text(
                      'No data to display',
                      style: TextStyle(
                          fontFamily: 'Sans',
                          color: Theme.of(context).disabledColor,
                          fontSize: Theme.of(context).textTheme.title.fontSize),
                    )
                  ],
                ),
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

class DataSearch extends SearchDelegate<String> {
  final List user;
  final List<StaffItem> listStaff;
  bool edit = false;

  DataSearch(this.user, this.listStaff);

  @override
  String get searchFieldLabel => 'Search name';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
        primaryColor: theme.appBarTheme.color,
        primaryIconTheme: theme.appBarTheme.iconTheme,
        primaryColorBrightness: theme.primaryColorBrightness,
        textTheme: TextTheme(
            title: TextStyle(
          fontFamily: 'Sans',
          fontSize: 18.0,
        )));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Feather.x),
          onPressed: () {
            if (query == "") {
              close(context, null);
            } else {
              query = "";
            }
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionsList = query.isEmpty
        ? null
        : user
            .where((p) => p.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return suggestionsList != null ? ListView.builder(
        itemCount: suggestionsList.length,
        itemBuilder: (context, i) {
          return ListTile(
            onTap: () async {
              for(int j = 0; j < listStaff.length; j++){
                if(suggestionsList[i] == listStaff[j].name){
                  Navigator.of(context).push(_createRoute(DetailStaff(
                    id: listStaff[j].id,
                    name: listStaff[j].name,
                    position: listStaff[j].position,
                    outlet: listStaff[j].outlet,
                    phone: listStaff[j].phone,
                    address: listStaff[j].address,
                    emails: listStaff[j].email,
                    enrol: listStaff[j].enrol,
                    img: listStaff[j].img,
                    type: listStaff[j].type,
                    signin: listStaff[j].signin,
                  )));
                }
              }
            },
            leading: Icon(
              Icons.history,
            ),
            title: Text(suggestionsList[i],
                style: TextStyle(
                  color: Theme.of(context).textTheme.body1.color,
                  fontFamily: 'Sans',
                )),
            trailing: Icon(
              Feather.chevron_right,
            ),
          );
        }) : Center(
          child: Text(
            ''
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
