import 'package:flutter/material.dart';
import 'package:scanner_mobile/service.dart';

import 'login.dart';

class RegisterScreen extends StatefulWidget {

  @override
  RegisterScreenState createState() {
    return RegisterScreenState();
  }
}

class RegisterScreenState extends State<RegisterScreen>{
  final fullnameController = TextEditingController();
  final fullNameFocus = FocusNode();
  final usernameController= TextEditingController();
  final usernameFocus = FocusNode();
  final emailController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordController = TextEditingController();
  final passwordFocus = FocusNode();
  final confirmController = TextEditingController();
  final confirmFocus = FocusNode();

  @override
  void dispose() {
    fullnameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void unfocus() {
    setState(() {
      fullNameFocus.unfocus();
      usernameFocus.unfocus();
      passwordFocus.unfocus();
      confirmFocus.unfocus();
      emailFocus.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.amber,
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: Center(child:ListView(shrinkWrap: true, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('REGISTER', style: TextStyle(
              fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold
          )),
          //Image(image: AssetImage('assets/logo.png'), width: 180),
          SizedBox(height: 40),
          Container(
            padding: EdgeInsets.only(left: 30, right: 30),
            child:
            TextField(
              focusNode: fullNameFocus,
              controller: fullnameController,
              autofocus: false,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Full Name',
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
              focusNode: usernameFocus,
              controller: usernameController,
              autofocus: false,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'User Name',
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
              focusNode: passwordFocus,
              obscureText: true,
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
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 30, right: 30),
            child:
            TextField(
              focusNode: confirmFocus,
              obscureText: true,
              controller: confirmController,
              autofocus: false,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Confirm Password',
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
          SizedBox(height: 50),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonTheme(
                  minWidth: 150,
                  height: 50,
                  child: RaisedButton(onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(didSurvey: true,),
                      ),
                    );
                    unfocus();
                  },
                      textColor: Colors.white, child: Text("Login"), color: Colors.grey
                  ),
                ),
                SizedBox(width: 10),
                ButtonTheme(
                  minWidth: 150,
                  height: 50,
                  child: Builder(builder: (context) => RaisedButton(onPressed: () async {
                    unfocus();
                    bool ret = await RestService.register(context, fullnameController.text, usernameController.text, emailController.text, passwordController.text, confirmController.text);
                  },
                      textColor: Colors.white, child: Text("Register"), color: Colors.pink
                  ),
                  ),
                ),
              ]
          ),
        ],
      )])),
    );
  }
}