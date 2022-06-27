import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner_mobile/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

import 'login.dart';

class ChallengeScreen extends StatefulWidget {

  final content;
  ChallengeScreen(this.content);

  @override
  ChallengeScreenState createState() {
    return ChallengeScreenState();
  }
}

class ChallengeScreenState extends State<ChallengeScreen> {
  bool checkedValue = false;
  WebViewController _controller;

  _loadHtmlFromAssets() async {

    final tempDir = await getTemporaryDirectory();

    final htmlPath = join(tempDir.path, 'challenge.html');
    //final cssPath = join(tempDir.path, 'terms.css');
    //final jsPath = join(tempDir.path, 'terms.js');

    File(htmlPath).writeAsStringSync(widget.content);

    var uri = Uri(scheme: 'file', path: htmlPath);
    _controller.loadUrl(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    // setValueToSF();
    return Scaffold(
      backgroundColor: Colors.amber,
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: Stack(children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(),
          margin: EdgeInsets.only(left: 15, right: 15, top: 50, bottom: 20),
          padding: EdgeInsets.only(left: 15, right: 10, top: 10, bottom: 100),
          child: WebView(
            initialUrl: '',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _loadHtmlFromAssets();
            },
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 3,
                offset: Offset(1, 2), // changes position of shadow
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}