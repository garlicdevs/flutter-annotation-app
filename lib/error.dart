import 'package:flutter/material.dart';
import 'package:scanner_mobile/terms.dart';
import 'package:scanner_mobile/utils.dart';

import 'login.dart';

class ErrorScreen extends StatefulWidget {
  final value;
  ErrorScreen(this.value);

  @override
  ErrorScreenState createState() {
    return ErrorScreenState();
  }
}

class ErrorScreenState extends State<ErrorScreen>{

  bool connected = false;

  @override
  Widget build(BuildContext context) {
    if(Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    if (connected) {
      return widget.value ? TermsScreen() : LoginScreen();
    } else {
      Future.delayed(Duration.zero, () =>
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                    width: 50,
                    height: 200,
                    decoration: new BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.amber,
                      borderRadius: new BorderRadius.all(
                          new Radius.circular(8.0)),
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        new Text("INFORMATION", style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child:
                          new Text("Could not connect to the server !"),
                        ),
                        new RaisedButton(color: Colors.pink,
                            child: Text("Try Again"),
                            onPressed: () async {
                              Navigator.pop(context);
                              bool c = await Utils.isConnected(context);
                              setState(() {
                                connected = c;
                              });
                            })
                      ],
                    )
                ),
              );
            },
          ));
      return Container(
        color: Colors.amber,
      );
    }
  }
}