import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../display.dart';
import '../service.dart';
import 'view_photo.dart';

class GalleryView extends StatefulWidget {
  final int crossAxisCount;

  const GalleryView(
      {Key key, this.crossAxisCount = 2});

  @override
  GalleryState createState() {
    return GalleryState();
  }
}

class GalleryState extends State<GalleryView> {

  int numPicsPerPage = 100;
  int startIndex = 655;
  String homeUrl = 'https://ifm-scanner.deakin.edu.au/project/test/';
  List<String> imageUrlList;
  List<dynamic> infoList;
  final headers = {'User-Agent': RestService.agent};

  GalleryState() {
    imageUrlList = <String>[];
    infoList = <dynamic>[];
  }

  Future<bool> fetchPost(String url) async {
    try {
      final headers = {'Content-Type': 'application/json', 'User-Agent': RestService.agent};
      debugPrint('Fetch data from ' + url);
      final res = await http.get(url, headers: headers).timeout(Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List<dynamic> obj = json.decode(res.body);
        if (obj.length > 0) {
          debugPrint(obj[0].toString());
          setState(() {
            imageUrlList.add(obj[0]['media_url']);
            infoList.add(obj[0]['info']);
          });
          return true;
        } else {
          debugPrint('No data');
        }
      }
    } on TimeoutException catch (e) {
      debugPrint(e.toString());
    } on SocketException catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<void> loadData(int ss, int ee) async {
    imageUrlList.clear();
    infoList.clear();
    for (int i = ss;i < ee; i++) {
      String url = homeUrl + i.toString() + '/results.json';
      debugPrint(url);
      bool ret = await fetchPost(url);
      if (!ret) {
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    debugPrint('Fetch results');

    loadData(startIndex, startIndex + numPicsPerPage);
  }

  static const MethodChannel _channel = const MethodChannel('gallery_view');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<String> getImagePath(String url) async {
    var rng = new Random();
    int randInt = rng.nextInt(10000);
    var currentTime = DateTime.now();
    Directory paths;
    if (Platform.isAndroid) {
      paths = await getExternalStorageDirectory();
    } else {
      paths = await getApplicationDocumentsDirectory();
    }
    List<String> ext = url.split('.');
    String imagePath = paths.path +
        '/' +
        '${randInt}_${currentTime.year}_${currentTime.month}_${currentTime.day}_${currentTime.hour}_${currentTime.minute}_${currentTime.second}_${currentTime.millisecond}.' +
        '${ext[ext.length - 1]}';
    try {
      debugPrint('Retrieve image from $url');
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        File file2 = new File(imagePath);
        file2.writeAsBytesSync(response.bodyBytes);
      } else {
        debugPrint('Error ' + response.statusCode.toString());
      }
    } on TimeoutException catch (e) {
      debugPrint(e.toString());
      return '';
    } on SocketException catch (e) {
      debugPrint(e.toString());
      return '';
    }
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
            itemCount: imageUrlList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                crossAxisSpacing: 6.0,
                mainAxisSpacing: 6.0),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () async {
                  final imagePath = await getImagePath(imageUrlList[index]);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) {
                            debugPrint('Open Display Picture ImagePath: $imagePath');
                            return DisplayPictureScreen(imagePath: imagePath, networkImage: true, dataInfo: infoList[index]);
                          })
                  );

                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (_) {
                  //           return ViewPhotos(
                  //             imageIndex: index,
                  //             imageList: imageUrlList,
                  //             heroTitle: "image$index",
                  //           );
                  //         },
                  //         fullscreenDialog: true));
                },
                child: Container(
                  child: Hero(
                      tag: "photo$index",
                      child: CachedNetworkImage(
                        httpHeaders: headers,
                        fit: BoxFit.cover,
                        imageUrl: imageUrlList[index],
                        placeholder: (context, url) => Container(
                            child: Center(child: CupertinoActivityIndicator())),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )),
                ),
              );
            }),
      ),
    );
  }
}
