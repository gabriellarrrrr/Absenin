import 'dart:io';
import 'package:absenin/anim/FadeUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPage extends StatefulWidget {
  final String urlImg, id, outlet, nama;

  const PhotoPage(
      {Key key,
      @required this.urlImg,
      @required this.id,
      @required this.outlet,
      @required this.nama})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PhotoPageState();
  }
}

class PhotoPageState extends State<PhotoPage> {
  File _image;
  final Firestore firestore = Firestore.instance;
  final StorageReference fs = FirebaseStorage.instance.ref();
  String urlImg;
  bool update = false;

  _compressImage(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    var name = path.basename(_image.absolute.path);
    var result = await FlutterImageCompress.compressAndGetFile(
      _image.absolute.path,
      dir.absolute.path + '/${DateTime.now()}_$name',
      quality: 60,
    );
    print('before : ' + _image.lengthSync().toString());
    print('after : ' + result.lengthSync().toString());

    setState(() {
      _image = result;
    });
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

  _uploadImageToFirebase() async {
    StorageReference reference =
        fs.child('${widget.outlet}/staff/${widget.nama}_${DateTime.now()}');

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
          updateDataStaff();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void updateDataStaff() async {
    await firestore
        .collection('user')
        .document(widget.outlet)
        .collection('listuser')
        .document(widget.id)
        .updateData({'img': urlImg});
    if (mounted) {
      Navigator.pop(context);
      showCenterShortToast();
      setState(() {
        _image = null;
        update = true;
      });
    }
  }

  void showCenterShortToast() {
    Fluttertoast.showToast(
        msg: 'Success',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
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
    return WillPopScope(
      onWillPop: () {
        if (urlImg != null) {
          Navigator.pop(context, urlImg);
        } else {
          Navigator.pop(context, 'null');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
            size: 20.0,
            color: Colors.white70,
          ),
          textTheme: TextTheme(
              title: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 19.0,
            fontFamily: 'Google',
          )),
          title: Text('Photo Profile'),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  MaterialIcons.edit,
                  size: 20.0,
                ),
                onPressed: () {
                  _getImage();
                })
          ],
        ),
        body: Container(
          child: Stack(
            children: <Widget>[
              Hero(
                  tag: 'photo',
                  child: _image != null
                      ? Center(
                          child: Image.file(
                            _image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            filterQuality: FilterQuality.medium,
                          ),
                        )
                      : PhotoView(
                          imageProvider:
                              NetworkImage(update ? urlImg : widget.urlImg))),
              if (_image != null)
                Positioned(
                    bottom: 30.0,
                    left: 0.0,
                    right: 0.0,
                    child: Center(
                      child: FadeUp(
                        1,
                        FlatButton(
                            onPressed: () {
                              _prosesDialog();
                              _uploadImageToFirebase();
                            },
                            color: Theme.of(context).buttonColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            child: Text(
                              'Update',
                              style: TextStyle(
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                      ),
                    ))
            ],
          ),
        ),
      ),
    );
  }
}
