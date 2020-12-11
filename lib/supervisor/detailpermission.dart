import 'package:flutter/material.dart';

class DetailPermission extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DetailPermissionState();
  }
}

class DetailPermissionState extends State<DetailPermission> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Permission'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Text('detail Permission'),
          ],
        ),
      ),
    );
  }
}
