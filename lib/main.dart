import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scanner_mobile/terms.dart';
import 'package:scanner_mobile/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'error.dart';
import 'login.dart';


Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  //final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  //final firstCamera = cameras.first;

  //debugPrint(firstCamera.toString());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool value = prefs.getBool('terms') ?? true;

  debugPrint('terms: ${value}');

  bool connected = await Utils.isConnected(null);
  bool didSurvey = await Utils.getSurvey();

  debugPrint(connected.toString());

  runApp(
      MaterialApp(
        theme: ThemeData.dark().copyWith(primaryColor: Colors.amber),
        home: connected ? (value ? TermsScreen() : LoginScreen(didSurvey: didSurvey,)) : ErrorScreen(value),
        debugShowCheckedModeBanner: false,
      ),
  );
}