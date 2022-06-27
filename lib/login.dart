import 'package:flutter/material.dart';
import 'package:scanner_mobile/register.dart';
import 'package:scanner_mobile/service.dart';
import 'package:scanner_mobile/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'display.dart';


class LoginScreen extends StatefulWidget {
  final didSurvey;

  LoginScreen({@required this.didSurvey});

  @override
  LoginScreenState createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen>{
  final emailController = new TextEditingController();
  final emailFocus = new FocusNode();
  final passwordController = new TextEditingController();
  final passwordFocus = new FocusNode();
  bool isShowFirstTime = false;

  void unfocus() {
    setState(() {
      emailFocus.unfocus();
      passwordFocus.unfocus();
    });
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('email') != null && prefs.getString('email') != '') {
      emailController.text = prefs.getString('email');
      if (prefs.getString('password') != null && prefs.getString('password') != '') {
        prefs.setBool('anonymous', false);
        await RestService.login(
            context, prefs.getString('email'), prefs.getString('password'));
      }
    }
  }

  void showConfirmDialog(BuildContext context, String msg, String link) {
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
                color: Colors.orange,
                borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new Text('One more step', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: new Text(msg,textAlign: TextAlign.center),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: new InkWell(
                        child: new Text(link, textAlign: TextAlign.center, style: TextStyle(
                            color: Colors.lightBlue,
                            fontStyle: FontStyle.italic
                        ),),
                        onTap: () {
                          launch(link);
                          Utils.didSurvey();
                          Navigator.pop(context);
                          init();
                        }
                    ),
                  ),
                  new Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        new RaisedButton(color: Colors.pink, child: Text("Do it later"),onPressed: () {
                          Navigator.pop(context);
                          init();
                        }),
                      ])
                ],
              )
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    // Just show the survey at the first time
    // if (isShowFirstTime == false) {
    //   isShowFirstTime = true;
    //   debugPrint('Did Survey:' + widget.didSurvey.toString());
    //   if (widget.didSurvey == null || !widget.didSurvey) {
    //     Future.delayed(Duration.zero, () => showConfirmDialog(context,
    //         'The next part of this study will involve completing a 5-minute survey. Please click the link below to complete the survey and then return to this app to start capturing images!',
    //         'https://researchsurveys.deakin.edu.au/jfe/form/SV_b2UAgl3rvZJTQz4'));
    //   } else {
    //     init();
    //   }
    // } else {
    //   init();
    // }
    init();

    return Scaffold(
      backgroundColor: Colors.amber,
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: Center(child:ListView(shrinkWrap: true, children: [
        Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('LOGIN', style: TextStyle(
              fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold
          )),
          SizedBox(height: 10),
          Image(image: AssetImage('assets/logo.png'), width: 180),
          SizedBox(height: 40),
          Container(
            padding: EdgeInsets.only(left: 30, right: 30),
            child:
            TextField(
              focusNode: emailFocus,
              controller: emailController,
              autofocus: false,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Email Address',
                hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
                contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 30, right: 30),
            child:
            TextField(
              obscureText: true,
              focusNode: passwordFocus,
              controller: passwordController,
              autofocus: false,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Password',
                hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
                contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonTheme(
                  minWidth: 150,
                  height: 50,
                  child: RaisedButton(onPressed: () {
                    unfocus();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          RegisterScreen(
                            // Pass the appropriate camera to the TakePictureScreen widget.
                          )),
                    );
                  },
                      textColor: Colors.white, child: Text("Register"), color: Colors.grey
                  ),
                ),
                SizedBox(width: 10),
                ButtonTheme(
                  minWidth: 150,
                  height: 50,
                  child:
                  Builder(
                    builder: (context) =>
                        RaisedButton(onPressed: () async {
                          unfocus();
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString('email', emailController.text);
                          bool ret = await RestService.login(
                              context, emailController.text,
                              passwordController.text);
                        },
                            textColor: Colors.white,
                            child: Text("Login"),
                            color: Colors.pink
                        ),
                  ),
                ),
              ]
          ),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('anonymous', true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(imagePath: ''),
                  ),
                );
              },
            child: Text("Continue as an anonymous user", style: TextStyle(
              color: Colors.black54,
              decoration: TextDecoration.underline
            ),),
          )
        ],
      )])),
    );
  }
}