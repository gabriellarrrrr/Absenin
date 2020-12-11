import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:random_string/random_string.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class AddStaf extends StatefulWidget {
  final int action;
  final String id, name, position, outlet, phone, address, emails, img;
  final int type;

  const AddStaf(
      {Key key,
      @required this.action,
      this.id,
      this.name,
      this.position,
      this.outlet,
      this.phone,
      this.address,
      this.emails,
      this.img,
      this.type})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddStafState();
  }
}

class AddStafState extends State<AddStaf> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDataUserFromPref();
    if (widget.action == 20) {
      setState(() {
        nameController.text = widget.name;
        emailController.text = widget.emails;
        phoneController.text = widget.phone.substring(3, (widget.phone.length));
        addressController.text = widget.address;
        _outlet = widget.outlet;
        _position = widget.position;
        if (widget.type == 1) {
          _typeStaff = 'Full Time';
        } else {
          _typeStaff = 'Part Time';
        }
      });
    }
  }

  List outletDazzle = [
    'Dazzle Gejayan',
    'Dazzle Jakal',
  ];

  List positionStaff = [
    'Kasir',
    'Karyawan',
  ];

  List typeOfStaff = [
    'Part Time',
    'Full Time',
  ];

  String _outlet;
  String _position;
  bool autoVal = false;
  String _typeStaff;
  String name;
  String email;
  String phone;
  String address;
  File _image;
  String dialcode = '+62';
  String urlImg;
  String outlet;

  final Firestore firestore = Firestore.instance;
  final StorageReference fs = FirebaseStorage.instance.ref();

  _getDataUserFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      outlet = prefs.getString('outletUser');
    });
  }

  void saveDataStaff() async {
    int type;
    String enrol;
    enrol = randomAlphaNumeric(6);
    if (_typeStaff == 'Full Time') {
      type = 1;
    } else {
      type = 2;
    }
    await firestore
    .collection('user')
    .document(outlet)
    .collection('listuser')
    .add({
      'outlet': _outlet,
      'position': _position,
      'name': nameController.text,
      'email': emailController.text,
      'phone': dialcode + phoneController.text,
      'address': addressController.text,
      'type': type,
      'enrol': enrol,
      'img': urlImg,
      'status': false,
      'passcode': enrol,
      'isSignin': false,
      'role': 1,
      'delete': false
    }).then((data){
      firestore
        .collection('user')
        .document(outlet)
        .collection('listuser')
        .document(data.documentID)
        .collection('${DateTime.now().year}')
        .document('count')
        .setData({
        'dayOff' : 0
      });
    });
    if (mounted) {
      _sendEmail(enrol);
    }
  }

  void updateDataStaff() async {
    int type;
    if (_typeStaff == 'Full Time') {
      type = 1;
    } else {
      type = 2;
    }
    await firestore
      .collection('user')
      .document(outlet)
      .collection('listuser')
      .document(widget.id)
      .updateData({
      'outlet': _outlet,
      'position': _position,
      'name': nameController.text,
      'phone': dialcode + phoneController.text,
      'address': addressController.text,
      'type': type,
      //'img': urlImg
    });
    if (mounted) {
      Navigator.pop(context);
      showCenterShortToast();
      Navigator.pop(context, true);
    }
  }

  void showCenterShortToast() {
    Fluttertoast.showToast(
        msg: 'Success',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }

  String validateName(String name) {
    if (name.isEmpty) {
      return 'Enter user name!';
    }
    return null;
  }

  String validateEmail(String email) {
    if (email.isEmpty) {
      return 'Enter email address!';
    }
    return null;
  }

  String validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Enter phone number!';
    }
    return null;
  }

  String validateAddress(String address) {
    if (address.isEmpty) {
      return 'Enter address!';
    }
    return null;
  }

  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
        _compressImage(_image);
      });
    }
  }

  _compressImage(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    var name = path.basename(_image.absolute.path);
    var result = await FlutterImageCompress.compressAndGetFile(
      _image.absolute.path,
      dir.absolute.path + '/$name',
      quality: 60,
    );
    print('before : ' + _image.lengthSync().toString());
    print('after : ' + result.lengthSync().toString());

    setState(() {
      _image = result;
    });
  }

  _uploadImageToFirebase() async {
    StorageReference reference = fs.child('$outlet/staff/' + nameController.text);

    try {
      StorageUploadTask uploadTask = reference.putFile(_image);

      if (uploadTask.isInProgress) {
        uploadTask.events.listen((persen) async {
          double persentase = 100 *
              (persen.snapshot.bytesTransferred.toDouble() /
                  persen.snapshot.totalByteCount.toDouble());
          print(persentase);
        });

        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        final String url = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          urlImg = url;
          saveDataStaff();
        });
      } else if (uploadTask.isComplete) {
        final String url = await reference.getDownloadURL();
        print(url);
        setState(() {
          urlImg = url;
          saveDataStaff();
          Navigator.pop(context, true);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _sendEmail(String enrol) async {
    String username = 'official.absenin@gmail.com';
    String password = 'Absenin2020';

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Absenin Official')
      ..recipients.add('${emailController.text}')
      ..subject = "Hay ${nameController.text}. Here's your Absenin Account"
      ..html =
          "<h1>Welcome to Absenin!</h1><br><center><img src='https://i.ibb.co/9nk62sz/Group-29.png' width='235'></center><br><br><p style='font-size: 18px'><b>This is your Account😊</b></p><p style='font-size: 14px'>Email : <span style='font-size: 20px; font-weight: bold'>${emailController.text}</span></p><p style='font-size: 14px'>Enrol Key : <span style='font-size: 20px; font-weight: bold'>$enrol</span></p><br><br><br><center><button style='background-color: #37474f; color: white; border-radius: 8px; padding: 8px 20px; text-align: center; text-decoration: none; margin: 2px;'>Download App</button><br><p><i>Open Your Apps and Enjoy!</i> \u00a9 2020 Absenin</p></center>";

    try {
      final sendReport = await send(message, smtpServer);
      Navigator.pop(context);
      Navigator.pop(context, true);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? Theme.of(context).backgroundColor
              : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.action == 10 ? 'Add Staff' : 'Edit Staff'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Office',
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .fontSize,
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'Choose Outlet',
                            style: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.body1.fontSize,
                              fontFamily: 'Google',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField(
                            items: outletDazzle.map((permit) {
                              return DropdownMenuItem(
                                  value: permit,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        permit,
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .subhead
                                                .fontSize,
                                            fontFamily: 'Sans'),
                                      ),
                                    ],
                                  ));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _outlet = value);
                            },
                            value: _outlet,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                              border: OutlineInputBorder(),
                              hintText: 'Outlet',
                              hintStyle: TextStyle(
                                fontFamily: 'Sans',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'Choose Position',
                            style: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.body1.fontSize,
                              fontFamily: 'Google',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField(
                            items: positionStaff.map((permit) {
                              return DropdownMenuItem(
                                  value: permit,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        permit,
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .subhead
                                                .fontSize,
                                            fontFamily: 'Sans'),
                                      ),
                                    ],
                                  ));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _position = value);
                            },
                            value: _position,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                              border: OutlineInputBorder(),
                              hintText: 'Position Staff',
                              hintStyle: TextStyle(
                                fontFamily: 'Sans',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'Choose Type of Staff',
                            style: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.body1.fontSize,
                              fontFamily: 'Google',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DropdownButtonFormField(
                            items: typeOfStaff.map((permit) {
                              return DropdownMenuItem(
                                  value: permit,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        permit,
                                        style: TextStyle(
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .subhead
                                                .fontSize,
                                            fontFamily: 'Sans'),
                                      ),
                                    ],
                                  ));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _typeStaff = value);
                            },
                            value: _typeStaff,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                              border: OutlineInputBorder(),
                              hintText: 'Type of Staff',
                              hintStyle: TextStyle(
                                fontFamily: 'Sans',
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Divider(
                            height: 0.0,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'User Profile',
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .fontSize,
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'Profile picture',
                            style: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.body1.fontSize,
                              fontFamily: 'Google',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: widget.action == 20
                                ? GestureDetector(
                                    onTap: () {
                                      _getImage();
                                    },
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/images/absenin.png',
                                      height: 170.0,
                                      width: double.infinity,
                                      image: widget.img,
                                      fadeInDuration: Duration(seconds: 1),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _image != null
                                    ? Image.file(
                                        _image,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 170.0,
                                        filterQuality: FilterQuality.medium,
                                      )
                                    : Container(
                                        height: 170.0,
                                        color: Theme.of(context).dividerColor,
                                        child: Center(
                                          child: IconButton(
                                            icon: Icon(FontAwesome.picture_o),
                                            onPressed: (){
                                              _getImage();
                                            },
                                          ),
                                        ),
                                      ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Form(
                            key: formKey,
                            autovalidate: autoVal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Name',
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .fontSize,
                                    fontFamily: 'Google',
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: nameController,
                                  validator: validateName,
                                  onSaved: (value) {
                                    name = value;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Full name',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLength: 50,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .fontSize,
                                      fontFamily: 'Sans'),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .fontSize,
                                    fontFamily: 'Google',
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  validator: validateEmail,
                                  readOnly: widget.action == 20 ? true : false,
                                  onSaved: (value) {
                                    email = value;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'example@mail.com',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  maxLength: 50,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .fontSize,
                                      fontFamily: 'Sans'),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Phone number',
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .fontSize,
                                    fontFamily: 'Google',
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: phoneController,
                                  validator: validatePhone,
                                  onSaved: (value) {
                                    phone = value;
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: CountryListPick(
                                      isShowFlag: false,
                                      isShowTitle: false,
                                      isDownIcon: true,
                                      initialSelection: dialcode,
                                      onChanged: (CountryCode code) {
                                        print(code.name);
                                        print(code.code);
                                        print(code.dialCode);
                                        print(code.flagUri);
                                        setState(() {
                                          dialcode = code.dialCode;
                                        });
                                      },
                                    ),
                                    hintText: '878xxx',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 13,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .fontSize,
                                      fontFamily: 'Sans'),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Address',
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .fontSize,
                                    fontFamily: 'Google',
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: addressController,
                                  validator: validateAddress,
                                  onSaved: (value) {
                                    address = value;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Gedongan',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.text,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLength: 100,
                                  maxLines: null,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .fontSize,
                                      fontFamily: 'Sans'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Theme.of(context).backgroundColor
                        : Theme.of(context).scaffoldBackgroundColor,
                    padding: EdgeInsets.all(15.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: FlatButton(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          final formVal = formKey.currentState;
                          if (formVal.validate()) {
                            setState(() {
                              if (widget.action == 20) {
                                _prosesDialog();
                                updateDataStaff();
                              } else {
                                if(_outlet != null && _position != null && _typeStaff != null && _image != null){
                                  _prosesDialog();
                                  _uploadImageToFirebase();
                                }
                              }
                              autoVal = true;
                            });
                            formVal.save();
                          } else {
                            autoVal = true;
                          }
                        },
                        child: Text(
                          widget.action == 20 ? 'Update' : 'Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Google',
                              fontWeight: FontWeight.bold),
                        ),
                        color: Theme.of(context).buttonColor,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
