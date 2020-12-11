import 'package:absenin/anim/FadeUp.dart';
import 'package:absenin/transition/revealroute.dart';
import 'package:absenin/user/addpermission.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPermission extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListPermissionState();
  }
}

class PermissionItem {
  final String id, enddate, startdate, type, explanation, file, filePath;
  int status;
  DateTime submitted, checked;

  PermissionItem(this.id, this.enddate, this.startdate, this.type, this.status,
      this.submitted, this.checked, this.explanation, this.file, this.filePath);
}

class ListPermissionState extends State<ListPermission> {
  List<PermissionItem> listpermission = new List<PermissionItem>();
  ScrollController controller;
  bool fabIsVisible = true;
  String id, outlet;
  bool isEmptyy = false;
  final Firestore db = Firestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  DateFormat dateFormat = DateFormat.yMMMMEEEEd();
  DateFormat timeFormat = DateFormat.Hm();

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    controller.addListener(() {
      setState(() {
        fabIsVisible =
            controller.position.userScrollDirection == ScrollDirection.forward;
      });
    });
    getDataUserFromPref();
  }

  void getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('idUser');
      outlet = prefs.getString('outletUser');
      getPermission();
    });
  }

  void getPermission() async {
      db
        .collection('permission')
        .document(outlet)
        .collection('listpermission')
        .where('user', isEqualTo: id)
        // .orderBy('submitted', descending: true)
        .snapshots()
        .listen((snapshot) {
      snapshot.documents.forEach((f) {
        Timestamp submitted = f.data['submitted'];
        Timestamp checked = f.data['checked'];
        PermissionItem item = new PermissionItem(
            f.documentID,
            f.data['enddate'],
            f.data['startdate'],
            f.data['type'],
            f.data['status'],
            submitted.toDate(),
            checked.toDate(),
            f.data['explanation'],
            f.data['file'],
            f.data['filePath']);
        setState(() {
          listpermission.add(item);
        });
      });
    });
    if (mounted) {
      if (listpermission.length == 0) {
        setState(() {
          isEmptyy = true;
        });
      }
    }
    print(listpermission);
  }

  void deletePermission(String id, String path) async {
    await db.collection('permission')
    .document(outlet)
    .collection('listpermission')
    .document(id).delete();
    if (mounted) {
      deleteFile(path);
    }
  }

  Future<void> deleteFile(String path) async {
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(path);
    await firebaseStorageRef.delete();
    if (mounted) {
      Navigator.pop(context);
      listpermission.clear();
      getPermission();
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

  void _showAlertDialog(int index) {
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
                          'Delete this Permission?',
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
                            Navigator.pop(context);
                            _prosesDialog();
                            deletePermission(listpermission[index].id,
                                listpermission[index].filePath);
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

  _gotoAddPermissionPage(int action, String id, String type, String start,
      String end, String explan) async {
    final result = await Navigator.push(
      context,
      RevealRoute(
        page: MakePermission(
          action: action,
          id: id,
          type: type,
          start: start,
          end: end,
          explan: explan,
        ),
        maxRadius: MediaQuery.of(context).size.height + 100,
        centerAlignment: Alignment.bottomRight,
      ),
    );
    if (result != null && result != false) {
      listpermission.clear();
      getPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Permissions'),
        ),
        floatingActionButton: AnimatedOpacity(
          child: FloatingActionButton(
            onPressed: () {
              _gotoAddPermissionPage(10, '', '', '', '', '');
            },
            child: Icon(
              Icons.add,
              size: 24.0,
              color: Colors.white,
            ),
          ),
          opacity: fabIsVisible ? 1 : 0,
          duration: Duration(milliseconds: 300),
        ),
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  margin: EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0)),
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/acc.png',
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'My Permissions',
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .fontSize,
                                fontFamily: 'Google',
                              ),
                            ),
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: IconButton(
                                    icon: Icon(
                                      MaterialIcons.more_vert,
                                      size: 20.0,
                                    ),
                                    onPressed: () {}),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'All your permissions',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.caption.color,
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.bold),
                    ),
                    if (listpermission.length > 0)
                      ListView.builder(
                          itemCount: listpermission.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return FadeUp(
                                0.5 + index / 2,
                                GestureDetector(
                                  onLongPress: () {
                                    // deletePermission(listpermission[index].id);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      bottom: 15,
                                      top: 15,
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 15.0,
                                        bottom: 20.0),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(0, 3),
                                            blurRadius: 8,
                                          )
                                        ]),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                listpermission[index].type,
                                                style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .fontSize,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Google'),
                                              ),
                                              if (listpermission[index]
                                                      .status ==
                                                  0)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    ClipOval(
                                                      child: Material(
                                                        color: MediaQuery.of(
                                                                        context)
                                                                    .platformBrightness ==
                                                                Brightness.light
                                                            ? Colors.indigo[50]
                                                            : Colors.indigo
                                                                .withAlpha(50),
                                                        child: GestureDetector(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Icon(
                                                              MaterialIcons
                                                                  .edit,
                                                              size: 15.0,
                                                              color: MediaQuery.of(
                                                                              context)
                                                                          .platformBrightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? Colors.indigo[
                                                                      300]
                                                                  : Colors.indigoAccent[
                                                                      100],
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            _gotoAddPermissionPage(
                                                                20,
                                                                listpermission[
                                                                        index]
                                                                    .id,
                                                                listpermission[
                                                                        index]
                                                                    .type,
                                                                listpermission[
                                                                        index]
                                                                    .startdate,
                                                                listpermission[
                                                                        index]
                                                                    .enddate,
                                                                listpermission[
                                                                        index]
                                                                    .explanation);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    ClipOval(
                                                      child: Material(
                                                        color: MediaQuery.of(
                                                                        context)
                                                                    .platformBrightness ==
                                                                Brightness.light
                                                            ? Colors.red[50]
                                                            : Colors.red
                                                                .withAlpha(50),
                                                        child: GestureDetector(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Icon(
                                                              MaterialIcons
                                                                  .delete,
                                                              size: 15.0,
                                                              color: MediaQuery.of(
                                                                              context)
                                                                          .platformBrightness ==
                                                                      Brightness
                                                                          .light
                                                                  ? Colors
                                                                      .red[300]
                                                                  : Colors.redAccent[
                                                                      100],
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            _showAlertDialog(
                                                                index);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    'Checked: ${dateFormat.format(listpermission[index].checked)} at ${timeFormat.format(listpermission[index].checked)}',
                                                    style: TextStyle(
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              .fontSize,
                                                      fontFamily: 'Sans',
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .caption
                                                          .color,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Divider(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                padding: EdgeInsets.all(15),
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    // color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[50] : Colors.green.withAlpha(30),
                                                    border: Border.all(
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.light
                                                          ? Colors.green[100]
                                                          : Colors.green
                                                              .withAlpha(50),
                                                    )),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      'Start Date',
                                                      style: TextStyle(
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption
                                                                  .fontSize,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption
                                                                  .color,
                                                          fontFamily: 'Sans'),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      listpermission[index]
                                                          .startdate,
                                                      style: TextStyle(
                                                          color: MediaQuery.of(
                                                                          context)
                                                                      .platformBrightness ==
                                                                  Brightness
                                                                      .light
                                                              ? Colors
                                                                  .green[900]
                                                              : Colors.white,
                                                          fontFamily: 'Google'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Text(
                                                    listpermission[index]
                                                                .status ==
                                                            0
                                                        ? 'waiting'
                                                        : listpermission[index]
                                                                    .status ==
                                                                1
                                                            ? 'Accepted'
                                                            : 'Rejected',
                                                    style: TextStyle(
                                                        color: listpermission[index].status == 0
                                                            ? MediaQuery.of(context)
                                                                        .platformBrightness ==
                                                                    Brightness
                                                                        .light
                                                                ? Colors
                                                                    .blue[800]
                                                                : Colors
                                                                    .blue[400]
                                                            : listpermission[index].status == 2
                                                                ? MediaQuery.of(context)
                                                                            .platformBrightness ==
                                                                        Brightness
                                                                            .light
                                                                    ? Colors.red[
                                                                        800]
                                                                    : Colors.red[
                                                                        400]
                                                                : MediaQuery.of(context).platformBrightness ==
                                                                        Brightness.light
                                                                    ? Colors.green[800]
                                                                    : Colors.green[400],
                                                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                                                        fontFamily: 'Sans'),
                                                  ),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      for (int i = 0;
                                                          i < 12;
                                                          i++)
                                                        Row(
                                                          children: <Widget>[
                                                            Container(
                                                              width: 3.5,
                                                              height: 3.5,
                                                              decoration: BoxDecoration(
                                                                  color: listpermission[index]
                                                                              .status ==
                                                                          0
                                                                      ? MediaQuery.of(context).platformBrightness == Brightness.light
                                                                          ? Colors.blue[
                                                                              300]
                                                                          : Colors.blue.withAlpha(
                                                                              100)
                                                                      : listpermission[index].status ==
                                                                              2
                                                                          ? MediaQuery.of(context).platformBrightness == Brightness.light
                                                                              ? Colors.red[
                                                                                  300]
                                                                              : Colors.red.withAlpha(
                                                                                  100)
                                                                          : MediaQuery.of(context).platformBrightness == Brightness.light
                                                                              ? Colors.green[300]
                                                                              : Colors.green.withAlpha(100),
                                                                  shape: BoxShape.circle),
                                                            ),
                                                            if (i < 19)
                                                              SizedBox(
                                                                width: 5.0,
                                                              ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(15),
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    // color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.green[50] : Colors.green.withAlpha(30),
                                                    border: Border.all(
                                                      color: MediaQuery.of(
                                                                      context)
                                                                  .platformBrightness ==
                                                              Brightness.light
                                                          ? Colors.green[100]
                                                          : Colors.green
                                                              .withAlpha(50),
                                                    )),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      'End Date',
                                                      style: TextStyle(
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption
                                                                  .fontSize,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption
                                                                  .color,
                                                          fontFamily: 'Sans'),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      listpermission[index]
                                                          .enddate,
                                                      style: TextStyle(
                                                          color: MediaQuery.of(
                                                                          context)
                                                                      .platformBrightness ==
                                                                  Brightness
                                                                      .light
                                                              ? Colors
                                                                  .green[900]
                                                              : Colors.white,
                                                          fontFamily: 'Google'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ));
                          })
                    else if (!isEmptyy)
                      Center(
                          child: Padding(
                        padding:
                            const EdgeInsets.only(top: 150.0, bottom: 30.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      ))
                    else
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.1),
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Image.asset(
                                'assets/images/nodata.png',
                                width: MediaQuery.of(context).size.width * 0.4,
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
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .subtitle
                                      .fontSize),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              )
            ],
          ),
        ));
  }
}
