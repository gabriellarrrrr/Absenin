import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Help extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HelpState();
  }
}

class HelpState extends State<Help> {
  List listHelp = [
    'What is Absenin?',
    'How to make Attendance?',
    'How to make Permission?',
    'How can i switch my schedule?'
  ];

  void _showAlertDialog(String title, String message) {
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
                            '$title',
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
                            textAlign: TextAlign.justify,
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
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0, bottom: 30.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/images/help.png',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              SizedBox(
                height: 60.0,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: listHelp.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        Material(
                            color: Colors.transparent,
                            child: ListTile(
                                onTap: () {
                                  if (index == 0) {
                                    _showAlertDialog('Absenin',
                                        'Absenin is an application that can help you make online attendance. This application uses location-based services that can find out your accurate position when making attendance');
                                  } else if (index == 1) {
                                    _showAlertDialog("Make Attendance",
                                        "👉 First, make sure the location features on your cellphone are active \n\n 👉 Second, do a clock in to be able to find your current position \n\n 👉 Third, don't forget to take a selfie as proof that you are already at the location where you work");
                                  } else if (index == 2) {
                                    _showAlertDialog('Permission',
                                        "If you want to apply for permission, make sure you send your online form 2 weeks before to day off and 3 days before for illness or other needs.\n\n Don't forget to include files in pdf format to support submitting your permission.");
                                  } else {
                                    _showAlertDialog('Switch Schedule',
                                        'Switch schedule are still done manually for approval to be submitted to the supervisor. \n\nBeforehand, so make sure you have contacted your supervisor before you make a submission in this application');
                                  }
                                },
                                leading: Icon(Feather.help_circle),
                                title: Text(
                                  listHelp[index],
                                  style: TextStyle(
                                      fontFamily: 'Google',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                                trailing: Icon(
                                  Feather.chevron_right,
                                  size: 15.0,
                                ))),
                        Container(
                          height: 0.5,
                          margin: EdgeInsets.only(left: 80.0),
                          color: Theme.of(context).dividerColor,
                        ),
                      ],
                    );
                  }),
              SizedBox(
                height: 100.0,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text('\u00a9 2020 Absenin',
                    style: Theme.of(context).textTheme.overline),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
