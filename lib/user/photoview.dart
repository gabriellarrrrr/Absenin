import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPage extends StatefulWidget {
  final String urlImg;

  const PhotoPage({Key key, @required this.urlImg}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PhotoPageState();
  }
}

class PhotoPageState extends State<PhotoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: () {})
        ],
      ),
      body: Container(
        child: Hero(
            tag: 'photo',
            child: PhotoView(imageProvider: NetworkImage(widget.urlImg))),
      ),
    );
  }
}
