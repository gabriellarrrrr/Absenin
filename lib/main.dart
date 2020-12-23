import 'package:absenin/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absenin',
      theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.grey[100],
          backgroundColor: Colors.white,
          primaryColor: Colors.blue,
          accentColor: Colors.blue,
          buttonColor: Colors.blue,
          appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              elevation: 0.5,
              color: Colors.white,
              iconTheme: IconThemeData(
                size: 20.0,
                color: Colors.black87,
              ),
              textTheme: TextTheme(
                  title: TextStyle(
                color: Colors.black87,
                fontSize: 19.0,
                fontFamily: 'Google',
              ))),
          tabBarTheme: TabBarTheme(
              labelColor: Colors.blue,
              labelStyle:
                  TextStyle(fontFamily: 'Google', fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  TextStyle(fontFamily: 'Google', fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(
            size: 20.0,
          ),
          textTheme: TextTheme(
              headline: TextStyle(fontFamily: 'Google'),
              caption: TextStyle(fontFamily: 'Sans'))),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          backgroundColor: Color.fromRGBO(26, 26, 26, 1),
          primaryColor: Color.fromRGBO(26, 26, 26, 1),
          accentColor: Colors.blue[400],
          buttonColor: Colors.blue[400],
          dialogBackgroundColor: Color.fromRGBO(26, 26, 26, 1),
          appBarTheme: AppBarTheme(
              brightness: Brightness.dark,
              elevation: 0.0,
              iconTheme: IconThemeData(
                size: 20.0,
                color: Colors.white60,
              ),
              textTheme: TextTheme(
                  title: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 19.0,
                fontFamily: 'Google',
              ))),
          tabBarTheme: TabBarTheme(
              labelColor: Colors.blue[400],
              labelStyle:
                  TextStyle(fontFamily: 'Google', fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  TextStyle(fontFamily: 'Google', fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(
            size: 20.0,
            color: Colors.white70,
          ),
          textTheme: TextTheme(
              headline: TextStyle(fontFamily: 'Google'),
              caption: TextStyle(fontFamily: 'Sans'))),
      home: SplashScreen(),
    );
  }
}

