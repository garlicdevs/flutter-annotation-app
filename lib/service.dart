import 'dart:collection';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:scanner_mobile/challenge.dart';
import 'package:scanner_mobile/rectangle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'canvas.dart';
import 'display.dart';
import 'login.dart';

class RestService {
  static final String serverIP = "ifm-scanner.deakin.edu.au";//vmware "192.168.1.104"; //Digital Ocean 134.122.70.15:5000
  static final String server = "https://" + serverIP + "/api";
  static final String serverLookup = "https://" + serverIP;
  static final String apiKey = '50c6c9af-c3a9-43ae-8bc5-14bc7215d5fe';//"c06f7ca6-a16d-4ee3-bd26-51b1aad914f1";//"c06f7ca6-a16d-4ee3-bd26-51b1aad914f1";
  static final String agent = 'PostmanRuntime/7.26.5';

  static void showSnackbar(BuildContext context, String msg) {
    final snackBar = SnackBar(
      content: Text(msg,
      style: TextStyle(color: Colors.white),),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.black87,
    );

    // Find the Scaffold in the widget tree and use
    // it to show a SnackBar.
    Scaffold.of(context).showSnackBar(snackBar);
  }

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 50,
            height: 120,
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.orange,
              borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                new CircularProgressIndicator(backgroundColor: Colors.red,),
                new Text("Please wait.."),
              ],
            )
          ),
        );
      },
    );
  }

  static void showConfirmDialog(BuildContext context, String msg, bool pop, VoidCallback cb, {title: 'ERROR'}) {
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
                  new Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: new Text(msg,textAlign: TextAlign.center),
                  ),
                  new Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                    new RaisedButton(color: Colors.grey, child: Text("Cancel"),onPressed: () {
                      Navigator.pop(context);
                      if (pop) {
                        Navigator.pop(context);
                      }
                    }),
                    new RaisedButton(color: Colors.pink, child: Text("Ok"),onPressed: () {
                      Navigator.pop(context);
                      if (pop) {
                        Navigator.pop(context);
                      }
                      cb.call();
                    }),
                  ])
                ],
              )
          ),
        );
      },
    );
  }

  static void showMsgDialog(BuildContext context, String msg, bool pop, {title: 'ERROR'}) {
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
                  new Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child:
                    new Text(msg),
                  ),
                  new RaisedButton(color: Colors.pink, child: Text("Ok"),onPressed: () {
                    Navigator.pop(context);
                    if (pop) {
                      Navigator.pop(context);
                    }
                  })
                ],
              )
          ),
        );
      },
    );
  }

  static void showMsgDialogOpenSurvey(BuildContext context, String msg, bool pop, {title: 'ERROR'}) {
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
                  new Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child:
                    new Text(msg),
                  ),
                  new RaisedButton(color: Colors.pink, child: Text("Ok"),onPressed: () {
                    Navigator.pop(context);
                    if (pop) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(didSurvey: true,),
                        ),
                      );
                    }
                  })
                ],
              )
          ),
        );
      },
    );
  }

  static void showMsgDialogMainScreen(BuildContext context, String msg, bool pop, {title: 'ERROR'}) {
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
                  new Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child:
                    new Text(msg),
                  ),
                  new RaisedButton(color: Colors.pink, child: Text("Ok"),onPressed: () {
                    Navigator.pop(context);
                    if(Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    if (pop) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPictureScreen(imagePath: ''),
                        ),
                      );
                    }
                  })
                ],
              )
          ),
        );
      },
    );
  }

  static Future<void> getCategories(State state, List<String> litems) async {

    int pid = -1;
    String endpoint = server +
        "/project?api_key=$apiKey";

    try {
      final headers = {'Content-Type': 'application/json', 'User-Agent': agent};
      final res = await http.get(endpoint, headers: headers).timeout(Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List<dynamic> obj = json.decode(res.body);

        if (obj.length > 0) {
          debugPrint(obj[0]["id"].toString());
          pid = obj[0]["id"];
        }
      }
    } on TimeoutException catch (e) {
      return;
    } on SocketException catch (e) {
      return;
    }

    endpoint = server + "/project/" + pid.toString() + "/newtask";
    var response;
    try {
      final headers = {'Content-Type': 'application/json', 'User-Agent': agent};
      response = await http.get(endpoint, headers: headers).timeout(Duration(seconds: 5));
    } on TimeoutException catch (e) {
      return;
    }
    if (response.statusCode == 200) {
      final Map<String, dynamic> obj = json.decode(response.body);
      debugPrint(response.body);
      if (obj.length > 0) {
        List<dynamic> cats = obj["info"]["category"];
        litems.clear();
        state.setState(() {
          for (String str in cats) {
            debugPrint(str);
            litems.add(str);
          }
        });
      }
    }
  }

  static Future<HttpClientResponse> apiRequest(String url, Map jsonMap, String csrf, String cookie) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.headers.set('X-CSRFToken', csrf);
    request.headers.set('Cookie', cookie);
    request.headers.set('User-Agent', agent);
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    httpClient.close();
    return response;
  }

  static Future<bool> getUserInfo() async {

    String endpoint = "https://" + serverIP + "/account/profile";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cookie = prefs.getString('cookie');
      debugPrint(cookie);
      final headers = {'Content-Type': 'application/json', 'Cookie': cookie, 'User-Agent': agent};
      final res = await http.get(endpoint, headers: headers).timeout(
          Duration(seconds: 5));
      debugPrint('Error code: ${res.statusCode}');
      if (res.statusCode == 200) {
        final Map<String, dynamic> obj = json.decode(res.body);
        debugPrint(obj.toString());

        // Navigator.pop(context);
        //
        // showMsgDialog(context, csrf);
        if (obj.containsKey('user')) {
          prefs.setString('email', obj['user']['email_addr']);
          prefs.setString('fullname', obj['user']['fullname']);
          prefs.setString('name', obj['user']['name']);
          prefs.setString('api', obj['user']['api_key']);
          prefs.setInt('answers', obj['user']['n_answers']);
          prefs.setBool('admin', obj['user']['admin']);
        }
      } else {
        debugPrint(res.body);
        return false;
      }
    } on TimeoutException catch (e) {
      return false;
    } on SocketException catch (e) {
      return false;
    }

    return true;
  }

  static Future<bool> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    showLoading(context);

    String endpoint = "https://" + serverIP + "/account/signout";
    String csrf = '';
    String cookie = '';
    try {
      final headers = {'Content-Type': 'application/json', 'User-Agent': agent};
      final res = await http.get(endpoint, headers: headers).timeout(
          Duration(seconds: 5));
      debugPrint('Error code: ${res.statusCode}');
      if (res.statusCode == 200) {
        final Map<String, dynamic> obj = json.decode(res.body);
        debugPrint(obj.toString());

        //
        // showMsgDialog(context, csrf);
        prefs.setString('password', "");

      } else {
        Navigator.pop(context);
        debugPrint(res.body);
        showMsgDialog(context, "Error", false);
        return false;
      }
    } on TimeoutException catch (e) {
      showSnackbar(context, 'Timeout: Could not connect to server !');
      Navigator.pop(context);
      return false;
    } on SocketException catch (e) {
      showSnackbar(context, 'Socket Error: Could not connect to server !');
      Navigator.pop(context);
      return false;
    }

    Navigator.pop(context);
    return true;
  }

  static Future<bool> login(BuildContext context, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showLoading(context);

    String endpoint = "https://" + serverIP + "/account/signin";
    String csrf = '';
    String cookie = '';
    try {
      final headers = {'Content-Type': 'application/json', 'User-Agent': agent};
      final res = await http.get(endpoint, headers: headers).timeout(
          Duration(seconds: 5));
      debugPrint('Error code: ${res.statusCode}');
      if (res.statusCode == 200) {
        final Map<String, dynamic> obj = json.decode(res.body);
        debugPrint(obj.toString());

        csrf = obj['form']['csrf'];
        debugPrint(csrf);

        final Map<String, dynamic> resHeaders = res.headers;
        debugPrint(resHeaders.toString());
        cookie = resHeaders['set-cookie'];
        debugPrint(cookie);

        // Navigator.pop(context);
        //
        // showMsgDialog(context, csrf);

      } else {
        Navigator.pop(context);
        debugPrint(res.body);
        showMsgDialog(context, "Error", false);
        return false;
      }
    } on TimeoutException catch (e) {
      showSnackbar(context, 'Timeout: Could not connect to server !');
      Navigator.pop(context);
      return false;
    } on SocketException catch (e) {
      showSnackbar(context, 'Socket Error: Could not connect to server !');
      Navigator.pop(context);
      return false;
    }

    if (cookie != '' && csrf != '') {
      Map<String, String> info = new Map();
      info['email'] = email.trim();
      info['password'] = password;

      final infoStr = jsonEncode(info);
      print(infoStr);
      try {
        final res = await apiRequest(endpoint, info, csrf, cookie);
        if (res.statusCode == 200) {
          String reply = await res.transform(utf8.decoder).join();
          Map<String, dynamic> r = json.decode(reply);
          debugPrint(r.toString());
          if (r.containsKey('flash') && r.containsKey('form')) {
            debugPrint(r['flash']);
            Navigator.pop(context);
            showMsgDialog(context, r['flash'], false);
            return false;
          } else {
            Navigator.pop(context);

            debugPrint('New cookie');
            //debugPrint(res.headers.value('set-cookie'));
            res.headers.forEach((name, values) {
              debugPrint(name);
              debugPrint('${values}');
              if (name == 'set-cookie') {
                String val = '${values}';
                debugPrint(val.substring(1, val.length-1));
                prefs.setString('cookie', val.substring(1, val.length-1));
              }
            });

            showMsgDialogMainScreen(context, r['flash'], true, title: 'INFORMATION');
            prefs.setString('email', email);
            prefs.setString('password', password);
            prefs.setBool('anonymous', false);
            return true;
          }
        } else {
          showSnackbar(context, 'Could not connect to server !');
          Navigator.pop(context);
          return false;
        }
      } on TimeoutException catch (e) {
        showSnackbar(context, 'Could not connect to server !');
        Navigator.pop(context);
        return false;
      } on SocketException catch (e) {
        showSnackbar(context, 'Could not connect to server !');
        Navigator.pop(context);
        return false;
      }
    }

    Navigator.pop(context);
    return true;
  }

  static Future<void> checkChallenge(String content, BuildContext context, String endpoint) async {
    if (content.contains("<!DOCTYPE html>")) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChallengeScreen(content),
        ),
      );
    }
  }

  static Future<bool> register(BuildContext context, String fullname, String username, String email, String password, String confirm) async {
    showLoading(context);

    String endpoint = "https://" + serverIP + "/account/register";
    String csrf = '';
    String cookie = '';
    try {
      final headers = {'Content-Type': 'application/json', 'User-Agent': agent};
      final res = await http.get(endpoint, headers: headers).timeout(
          Duration(seconds: 5));
      debugPrint('Error code: ${res.statusCode}');
      if (res.statusCode == 200) {
        debugPrint(res.body);

        //await checkChallenge(res.body, context, endpoint);

        final Map<String, dynamic> obj = json.decode(res.body);
        debugPrint(obj.toString());

        csrf = obj['form']['csrf'];
        debugPrint(csrf);

        final Map<String, dynamic> resHeaders = res.headers;
        debugPrint(resHeaders.toString());
        cookie = resHeaders['set-cookie'];
        debugPrint(cookie);

        // Navigator.pop(context);
        //
        // showMsgDialog(context, csrf);

      } else {
        Navigator.pop(context);
        debugPrint(res.body);
        showMsgDialog(context, "Error", false);
        return false;
      }
    } on TimeoutException catch (e) {
      showSnackbar(context, 'Timeout: Could not connect to server !');
      Navigator.pop(context);
      return false;
    } on SocketException catch (e) {
      showSnackbar(context, 'Socket Error: Could not connect to server !');
      Navigator.pop(context);
      return false;
    }

    if (cookie != '' && csrf != '') {
      Map<String, String> info = new Map();
      info['fullname'] = fullname;
      info['name'] = username;
      info['email_addr'] = email;
      info['password'] = password;
      info['confirm'] = confirm;

      final infoStr = jsonEncode(info);
      print(infoStr);
      try {
        final res = await apiRequest(endpoint, info, csrf, cookie);
        if (res.statusCode == 200) {
          String reply = await res.transform(utf8.decoder).join();
          Map<String, dynamic> r = json.decode(reply);
          debugPrint(r.toString());
          if (r.containsKey('flash') && r.containsKey('form')) {
            debugPrint(r['flash']);
            Navigator.pop(context);
            String firstError = '';
            for (String k in r['form']['errors'].keys) {
              firstError = k;
              break;
            }
            if (firstError != '') {
              showMsgDialog(context, r['flash'] + '\n' + r['form']['errors'][firstError].toString(), false);
              return false;
            }
          } else {
            Navigator.pop(context);
            showMsgDialogOpenSurvey(context, r['flash'], true, title: 'INFORMATION');
            return true;
          }
        } else {
          showSnackbar(context, 'Could not connect to server !');
          Navigator.pop(context);
          return false;
        }
      } on TimeoutException catch (e) {
        showSnackbar(context, 'Could not connect to server !');
        Navigator.pop(context);
        return false;
      } on SocketException catch (e) {
        showSnackbar(context, 'Could not connect to server !');
        Navigator.pop(context);
        return false;
      }
    }
    return true;
  }

  static Future<bool> requestNewTask(BuildContext context, String file, String comment, CustomSize size, HashMap<Rect, String> rects, CustomPainterDraggableState state, Position position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    showLoading(context);

    debugPrint(comment);

    int pid = -1;
    String endpoint = server + "/project?api_key=$apiKey";

    try {
      //final headers = {'Content-Type': 'application/json', 'User-Agent': agent};
      final res = await http.get(endpoint).timeout(Duration(seconds: 5));
      if (res.statusCode == 200) {
        debugPrint(res.body);
        final List<dynamic> obj = json.decode(res.body);
        debugPrint(obj.toString());
        // debugPrint(obj[0]["id"].toString());
        if (obj.length > 0) {
          pid = obj[obj.length-1]["id"];
        }
      }
    } on TimeoutException catch (e) {
      showSnackbar(context, 'Could not connect to server !');
      Navigator.pop(context);
      return false;
    } on SocketException catch (e) {
      showSnackbar(context, 'Could not connect to server !');
      Navigator.pop(context);
      return false;
    } on FormatException catch (e) {
      showSnackbar(context, 'Unknown error (FormatException) !');
      Navigator.pop(context);
      return false;
    }

    if (pid < 0) {
      showSnackbar(context, 'Could not find any project !');
      Navigator.pop(context);
      return false;
    }

    bool anonymous = prefs.getBool('anonymous');
    String userKey = prefs.getString('api');
    if (anonymous) {
      endpoint = server + "/project/" + pid.toString() + "/newtask";
    } else {
      endpoint = server + "/project/" + pid.toString() + "/newtask?api_key=$userKey";
    }
    var response;
    try {
      //final headers = {'Content-Type': 'application/json', 'User-Agent': agent};
      response = await http.get(endpoint).timeout(Duration(seconds: 5));
    } on TimeoutException catch (e) {
      showSnackbar(context, 'Could not connect to server !');
      Navigator.pop(context);
      return false;
    }
    if (response.statusCode == 200) {
      final Map<String, dynamic> obj = json.decode(response.body);
      debugPrint(response.body);
      debugPrint("Image: " + file);
      debugPrint("Comment: " + comment);
      if (obj.length > 0) {
        final int tid = obj["id"];
        debugPrint("Project ID:" + pid.toString() + "; Task ID:" + tid.toString());
        String url;
        if (anonymous) {
          url = server + "/taskrun";
        } else {
          url = server + "/taskrun?api_key=$userKey";
        }
        var postUri = Uri.parse(url);
        var request = new http.MultipartRequest("POST", postUri);

        request.headers[HttpHeaders.contentTypeHeader] = "multipart/form-data";
        //request.headers[HttpHeaders.userAgentHeader] = agent;
        request.fields["project_id"] = pid.toString();
        request.fields["task_id"] = tid.toString();
        HashMap<String, String> info = new HashMap();
        info['comment'] = comment;
        info['canvasWidth'] = size.canvasWidth.toString();
        info['canvasHeight'] = size.canvasHeight.toString();
        info['imageWidth'] = size.imageWidth.toString();
        info['imageHeight'] = size.imageHeight.toString();
        info['latitude'] = position.latitude.toString();
        info['longitude'] = position.longitude.toString();
        String str = "";
        for (Rect rect in rects.keys) {
          str += '${rect.left},${rect.top},${rect.width},${rect.height},${rects[rect]};';
        }
        info['annotation'] = str;
        request.fields["info"] = json.encode(info);
        request.files.add(await http.MultipartFile.fromPath(
            'file', file,
            contentType: MediaType('image', 'png')));

        debugPrint(request.fields["info"]);

        request.send().then((response) {
          debugPrint(response.statusCode.toString());
          debugPrint(response.reasonPhrase);

          response.stream.transform(utf8.decoder).listen((value) {
            debugPrint(value);
          });

          if (response.statusCode == 200) {
            debugPrint("Uploaded!");

            int b = prefs.getInt('answers');
            if (b == null || b == 0) {
              b = 1;
            } else{
              b += 1;
            }
            prefs.setInt('answers', b);

            //showSnackbar(context, 'Sent successfully !');
            Navigator.pop(context);
            // Future.delayed(const Duration(seconds: 2), () {
            //   Navigator.pop(context);
            // });
            //Navigator.pop(context);
            showMsgDialog(context, 'Photo sent successfully', false, title: "Information");
            Future.delayed(const Duration(seconds: 1), () {
              state.clear();
              state.setState(() {
              });
              state.widget.displayPictureScreenState.imagePath = '';
              state.widget.displayPictureScreenState.setState((){});
            });
            return true;
          } else if (response.statusCode == 403) {
            debugPrint("Retry!");
            Navigator.pop(context);
            return requestNewTask(context, file, comment, size, rects, state, position);
          }
          else {
            showSnackbar(context, 'Failed to send image to server !');
            Navigator.pop(context);
            return false;
          }
        });
      } else {
        showSnackbar(context, 'Could not find any task !');
        Navigator.pop(context);
        return false;
      }
    } else {
      showSnackbar(context, 'Could not find any task !');
      Navigator.pop(context);
      return false;
    }
  }
}