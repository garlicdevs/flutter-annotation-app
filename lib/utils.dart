import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:scanner_mobile/service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Utils {
  static Future<bool> isConnected(BuildContext context) async {
    String endpoint = "https://" + RestService.serverIP + "/account/signin";

    try {
      final headers = {'Content-Type': 'application/json', 'User-Agent': RestService.agent};
      final res = await http.get(endpoint, headers: headers).timeout(
          Duration(seconds: 5));
      debugPrint('Error code: ${res.statusCode}');
      if (res.statusCode == 200) {
        return true;
      }
    } on TimeoutException catch (e) {
      debugPrint('Error code: ${e.toString()}');
    } on SocketException catch (e) {
      debugPrint('Error code: ${e.toString()}');
    }

    return false;
  }

  static void setValueToSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstTimeOpenApp', false);
  }

  static void acceptTerms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('terms', false);
  }

  static void didSurvey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('didSurvey', true);
  }

  static Future<bool> getSurvey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('didSurvey');
  }

  static Future<bool> getTerms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('terms');
  }
}