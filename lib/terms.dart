import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner_mobile/register.dart';
import 'package:scanner_mobile/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

import 'login.dart';

class TermsScreen extends StatefulWidget {

  @override
  TermsScreenState createState() {
    return TermsScreenState();
  }
}

class TermsScreenState extends State<TermsScreen> {
  bool checkedValue = false;
  WebViewController _controller;

  bool didSurvey = false;

  @override
  void initState() {
    initialise();

    super.initState();
  }

  void initialise() async {
    // Load from assets
    didSurvey = await Utils.getSurvey();
  }

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('assets/terms.html');
    ByteData logoData = await rootBundle.load("assets/logo.svg");
    ByteData logoCData = await rootBundle.load("assets/cancer.png");
    List<int> logoBytes = logoData.buffer.asUint8List(logoData.offsetInBytes, logoData.lengthInBytes);
    List<int> logoCBytes = logoCData.buffer.asUint8List(logoCData.offsetInBytes, logoCData.lengthInBytes);

    ByteData bgData = await rootBundle.load("assets/background2.jpg");
    List<int> bgBytes = bgData.buffer.asUint8List(bgData.offsetInBytes, bgData.lengthInBytes);

    //String cssText = await rootBundle.loadString('assets/terms.css');
    //String jsText = await rootBundle.loadString('assets/terms.js');

    final tempDir = await getTemporaryDirectory();

    final htmlPath = join(tempDir.path, 'terms.html');
    final logoPath = join(tempDir.path, 'logo.svg');
    final bgPath = join(tempDir.path, 'background2.jpg');
    final logoCPath = join(tempDir.path, 'cancer.png');

    File(logoPath).writeAsBytesSync(logoBytes);
    File(bgPath).writeAsBytesSync(bgBytes);
    File(logoCPath).writeAsBytesSync(logoCBytes);

    File(htmlPath).writeAsStringSync(""" 
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
    <title>Terms and Conditions of SCANNER</title>

    <meta name="viewport" content="width=device-width">
    <meta name="robots" content="noindex, follow">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css" integrity="sha384-HSMxcRTRxnN+Bdg0JdbxYKrThecOKuH5zCYotlSAcp1+c8xmyTe9GYg1l9a69psu" crossorigin="anonymous"/>
    <style>
      body {
        font-size: 16px;
      }
      </style>
</head>
${fileText}
    """);
    //File(cssPath).writeAsStringSync(cssText);
    //File(jsPath).writeAsStringSync(jsText);

    var uri = Uri(scheme: 'file', path: htmlPath);
    _controller.loadUrl(uri.toString());
  }

  static void showConfirmDialog(BuildContext context, String msg, String link) {
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
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                              RegisterScreen(),
                          ));
                        }
                    ),
                  ),
                  new Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        new RaisedButton(color: Colors.pink, child: Text("Do it later"),onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                              RegisterScreen(),
                          ));
                        }),
                        // new RaisedButton(color: Colors.pink, child: Text("Ok"),onPressed: () {
                        //   Navigator.pop(context);
                        //   if (pop) {
                        //     Navigator.pop(context);
                        //   }
                        //   cb.call();
                        // }),
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
          padding: EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 100),
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
        Container(child:
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(child:
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.pink),
            child:
            Checkbox(
              value: checkedValue,
              onChanged: (bool value) {
                setState(() {
                  checkedValue = value;
                });
              },
              checkColor: Colors.pink,
              activeColor: Colors.pink,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          ),
          Expanded(
              child: Text(
                "I agree to the SCANNER Terms and Conditions",
                maxLines: 1,
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13
                ),
              )
          ),
        ]),
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(bottom: 70, left: 20),
        ),
        Container(child:
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Builder(builder: (context) =>
                RaisedButton(onPressed: () {
                  if (checkedValue) {
                    // Utils.setValueToSF();
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) =>
                    //       LoginScreen(
                    //         // Pass the appropriate camera to the TakePictureScreen widget.
                    //       )),
                    // );
                    Utils.acceptTerms();
                    // if (didSurvey != null && didSurvey) {
                    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                    //       RegisterScreen(),
                    //   ));
                    // } else {
                    //   showConfirmDialog(context, 'The next part of this study will involve completing a 5-minute survey. Please click the link below to complete the survey and then return to this app to start capturing images!',
                    //       'https://researchsurveys.deakin.edu.au/jfe/form/SV_b2UAgl3rvZJTQz4');
                    // }
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                          RegisterScreen(),
                    ));
                  }
                  else {
                    final snackBar = SnackBar(
                      content: Text("Please accept the consent statement first",
                        style: TextStyle(color: Colors.white),),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.black87,
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                  }
                }, textColor: Colors.white, child: Text("Proceed"), color: Colors.pink)
              ,),
          ],
        ),
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.all(30),
        )],
      ),
    );
  }
}