import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner_mobile/contact.dart';
import 'package:scanner_mobile/rectangle.dart';
import 'package:scanner_mobile/search.dart';
import 'package:scanner_mobile/service.dart';
import 'admin.dart';
import 'canvas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editor.dart';
import 'login.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show Platform;
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:mime/mime.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';


var width = 300;
var height = 300;


// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final firstCamera;
  final networkImage;
  final dataInfo;

  const DisplayPictureScreen({Key key, this.imagePath, this.firstCamera, this.networkImage: false, this.dataInfo}) : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => DisplayPictureScreenState(imagePath, firstCamera);
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  var imagePath;
  List<bool> isSelected = [false, false];
  bool isDone = false;
  final firstCamera;
  DisplayPictureScreenState(String image, this.firstCamera) {
    this.imagePath = image;
  }
  final myController = TextEditingController();
  CustomSize canvas = new CustomSize();
  HashMap<Rect, String> rects = new HashMap();
  FocusNode focusNode = new FocusNode();
  SharedPreferences prefs;
  String _image;
  Position currentPos;

  File _imageFile;
  bool openbottomsheet = false;
  bool firstTime = true;
  bool isEditing = false;
  NumberBox newImage = null;
  bool isAdmin = false;
  bool showAdminPage = false;

  GlobalKey addTagKey = GlobalObjectKey("addTag");
  GlobalKey doneTagKey = GlobalObjectKey("doneTag");
  GlobalKey removeTagKey = GlobalObjectKey("removeTag");
  GlobalKey removeTagCancelKey = GlobalObjectKey("removeCancelTag");
  GlobalKey openCameraKey = GlobalObjectKey("openCameraKey");
  GlobalKey exitDashboardKey = GlobalObjectKey("exitDashboardKey");
  GlobalKey loadKey = GlobalObjectKey("loadKey");
  GlobalKey cropKey = GlobalObjectKey("cropKey");
  GlobalKey editKey = GlobalObjectKey("editKey");

  @override
  void initState() {
    super.initState();

    newImage = new NumberBox();
    newImage.value = 0.0;
    this.isAdmin = false;

    init().then((result) {
      print("result: $result");
      setState(() {});
    });

    if (widget.networkImage) {
      initNetworkImage();
    }

    _determinePosition();
  }

  Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();
    await RestService.getUserInfo();
    isAdmin = prefs.getBool('admin');
    debugPrint('isAdmin?' + isAdmin.toString());
    if (isAdmin == null) {
      isAdmin = false;
    }
    setState(() {

    });
    return true;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void saveImage(fromCamera) async {
    debugPrint('saveImage');
    Position currentPos = await _determinePosition();
    debugPrint('Current Pos: $currentPos');
    this.currentPos = currentPos;

    var rng = new Random();
    int randInt = rng.nextInt(10000);
    var currentTime = DateTime.now();

    Directory paths;
    if (Platform.isAndroid) {
      paths = await getExternalStorageDirectory();
    } else {
      paths = await getApplicationDocumentsDirectory();
    }

    String mimeStr = lookupMimeType(_imageFile.path);
    print('file type ${mimeStr}');

    String ext = '.jpeg';
    if (mimeStr == 'image/png') {
      ext = '.png';
    }
    String imagePath_ = paths.path +
        '/' +
        '${randInt}_${currentTime.year}_${currentTime.month}_${currentTime.day}_${currentTime.hour}_${currentTime.minute}_${currentTime.second}_${currentTime.millisecond}' +
        '${ext}';
    _imageFile.copy(imagePath_);

    _image = imagePath_;
    imagePath = imagePath_;
    debugPrint('SaveImage $imagePath_');
    newImage.value = 1.0;
    setState(() {
    });
  }

  void initNetworkImage() async {
    Position currentPos = await _determinePosition();
    debugPrint('Current Pos: $currentPos $showAdminPage');
    this.currentPos = currentPos;

    _image = imagePath;

    newImage.value = 1.0;
    setState(() {
    });
  }

  void bottomsheets() async {
    openbottomsheet = true;
    setState(() {});
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return new Container(
          decoration: BoxDecoration(color: Colors.orange, boxShadow: [
            BoxShadow(blurRadius: 10.9, color: Colors.grey[400])
          ]),
          height: 170,
          child: new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: new Text("Select Image Options"),
              ),
              Divider(
                height: 1,
              ),
              new Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.photo_library),
                                  onPressed: () async {
                                    var image = await ImagePicker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
                                    var decodedImage =
                                    await decodeImageFromList(
                                        image.readAsBytesSync());

                                    setState(() {
                                      height = decodedImage.height;
                                      width = decodedImage.width;
                                      _imageFile = image;
                                    });

                                    await saveImage(false);

                                    //setState(() => _controller.clear());
                                    Navigator.pop(context);
                                  }),
                              SizedBox(width: 10),
                              Text("Open Gallery")
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () async {
                                  var image = await ImagePicker.pickImage(
                                      source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
                                  var decodedImage = await decodeImageFromList(
                                      image.readAsBytesSync());

                                  setState(() {
                                    height = decodedImage.height;
                                    width = decodedImage.width;
                                    _imageFile = image;
                                  });

                                  await saveImage(true);

                                  //setState(() => _controller.clear());
                                  Navigator.pop(context);
                                }),
                            SizedBox(width: 10),
                            Text("Open Camera")
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    openbottomsheet = false;
    setState(() {});
  }

  Future<void> getimageditor()  {
    final geteditimage = Navigator.push(context, MaterialPageRoute(
        builder: (context){
          return ImageEditorPro(
            appBarColor: Colors.amber,
            bottomBarColor: Colors.amber,
              imageFile: _imageFile,
            imageWidth: width,
            imageHeight: height
          );
        }
    )).then((geteditimage) {
      if(geteditimage != null){
        _image =  geteditimage;
        imagePath = _image;
        debugPrint('Image path: $imagePath');
        setState(() {
        });
      }
    }).catchError((er){print(er);});
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imagePath,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            statusBarColor: Colors.orange,
            toolbarTitle: 'Resize Photo',
            toolbarColor: Colors.orange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            activeControlsWidgetColor: Colors.pink
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Resize Photo',
        ));
    if (croppedFile != null) {
      File imageFile = croppedFile;

      var rng = new Random();
      int randInt = rng.nextInt(10000);
      var currentTime = DateTime.now();
      Directory paths;
      if (Platform.isAndroid) {
        paths = await getExternalStorageDirectory();
      } else {
        paths = await getApplicationDocumentsDirectory();
      }
      String imagePath = paths.path +
          '/' +
          '${randInt}_${currentTime.year}_${currentTime.month}_${currentTime.day}_${currentTime.hour}_${currentTime.minute}_${currentTime.second}_${currentTime.millisecond}' +
          '.jpeg';
      imageFile.copy(imagePath);

      setState(() {
        _imageFile = imageFile;
        _image = imagePath;
        this.imagePath = imagePath;
      });
    }
  }

  void showHelp(dynamic key, String msg, VoidCallback callback, {isTop: false, du: null}) {
    if (prefs != null) {
      bool a = prefs.getBool('showHelp');
      debugPrint('showHelp $a');
      if (a == null || a == false) {
        CoachMark coachMarkFAB = CoachMark();
        RenderBox target = key.currentContext.findRenderObject();

        // you can change the shape of the mark
        Rect markRect = target.localToGlobal(Offset.zero) & target.size;
        //markRect = Rect.fromCircle(center: markRect.center, radius: markRect.longestSide * 0.6);

        coachMarkFAB.show(
          targetContext: key.currentContext,
          markRect: markRect,
          markShape: BoxShape.rectangle,
          children: [
            Center(child:
            ButtonTheme(
              minWidth: 150,
              height: 50,
              child:
              Builder(
                builder: (context) =>
                    RaisedButton(onPressed: () async {
                    },
                        textColor: Colors.white,
                        child: Text("Ok"),
                        color: Colors.pink
                    ),
              ),
            )),
            isTop ? Positioned(
              top: markRect.top - 110,
              left: 10,
              child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.normal,
                  color: Colors.amber,
                ),
              ),
            ):
            Positioned(
              top: markRect.bottom + 15,
              right: 10.0,
              child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.normal,
                  color: Colors.amber,
                ),
              ),
            )
          ],
          duration: du,
          onClose: () =>
              Timer(Duration(seconds: 1), () {
                debugPrint('Help close');
                callback.call();
              }),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(firstTime) {
      firstTime = false;
      // Future.delayed(Duration(milliseconds: 500), () {
      //   bottomsheets();
      // });
      Future.delayed(Duration(milliseconds: 100), () {
        bool help = prefs.getBool('prefs_help');
        debugPrint('Help $help');
        //if (help == false)
        {
          showHelp(loadKey, 'Step 1: Press here to upload a photo', () {
            showHelp(openCameraKey, 'Or press here to capture a photo', () {});
          }, du: null);
        }
      });
    }
    var s = Scaffold(
      //resizeToAvoidBottomPadding: false,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: prefs != null? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              // ListView contains a group of widgets that scroll inside the drawer
              child: ListView(
                children: <Widget>[
                  new Container(
                    decoration: BoxDecoration(color: Colors.orange),
                    padding: EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 20),
                    child:
                    Row(children: [
                      ClipOval(
                        child: Container(
                          height: 100,
                          width: 100,
                          color: Colors.white,
                          child: Image.asset(
                            'assets/profile.jpg',
                            width: 120.0,
                            height: 100.0,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 20),
                          child:
                          Column(children: [
                            Text('G\'day', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                            Text(prefs.getBool('anonymous') ? 'Anonymous': prefs.getString('fullname'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],)
                      ),
                    ],
                    ),
                  ),
                  prefs.getBool('anonymous') ? SizedBox(height:1) :
                  Container(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Row(children: [
                      Icon(Icons.assignment_ind, color: Colors.pink,),
                      Text('  Your Scores: ${prefs.getInt('answers')}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),]
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Row(children: [
                      Icon(Icons.assessment, color: Colors.pink,),
                      GestureDetector(
                        onTap: () {
                          debugPrint('Go to leaderboard');
                          launch('https://ifm-scanner.deakin.edu.au/leaderboard/');
                        },
                        child: Text('  Leaderboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      )
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Row(children: [
                      Icon(Icons.help, color: Colors.pink,),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              ContactPage(),
                          ));
                        },
                        child: Text('  Contact Us', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      )
                    ]),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Row(children: [
                      Icon(Icons.help, color: Colors.pink,),
                      GestureDetector(
                        onTap: () {
                          launch('https://researchsurveys.deakin.edu.au/jfe/form/SV_4PzHfaI1XzsabY2');
                        },
                        child: Text('  Post Survey', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      )
                    ]),
                  ),
                  isAdmin?
                  Container(
                    padding: EdgeInsets.only(left: 20, top: 20),
                    child: Row(children: [
                      Icon(Icons.admin_panel_settings, color: Colors.pink,),
                      GestureDetector(
                        onTap: () {
                          debugPrint('Admin Page');
                          // Go to admin page
                          Navigator.pop(context);
                          setState(() {
                            showAdminPage = true;
                          });
                        },
                        child: Text('  Admin Page', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      )
                    ]),
                  ): Container(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 20),
              child:
              Align(
                alignment: FractionalOffset.bottomCenter,
                child:
                ButtonTheme(
                  height: 50,
                  minWidth: 220,
                  child:
                  RaisedButton(
                    color: Colors.pink,
                    child: Text(prefs.getBool('anonymous') ? 'Sign In' : 'Sign Out'),
                    onPressed: () async {
                      // Update the state of the app.
                      // ...
                      final isAno = prefs.getBool('anonymous');
                      if(!isAno) {
                        final ret = await RestService.logout(context);
                        if (ret) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  LoginScreen(),
                              )
                          );
                        }
                      } else {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                LoginScreen(),
                            )
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ) : Text('Loading'),
      ),
      appBar: showAdminPage? AppBar(
          title: Text("Dashboard"),
          elevation: 0,
          backgroundColor: Colors.orange,
          leading:
            IconButton(
              icon: Icon(Icons.arrow_back, size:20, key: exitDashboardKey),
              color: Colors.white,
              onPressed: () async {
                setState(() {
                  showAdminPage = false;
                });
              },
            ),
          ): ((this.imagePath != null && imagePath != '') ? AppBar(
        title: Text(""),
        elevation: 0,
        backgroundColor: Colors.orange,
        leading: (widget.networkImage!=null && showAdminPage) ? IconButton(
          icon: Icon(Icons.arrow_back, size:20),
          color: Colors.white,
          onPressed: () async {
            Navigator.pop(context);
          },
        ): null,
        actions: <Widget>[
          widget.networkImage == null?
          IconButton(
            icon: Icon(Icons.camera_alt, size: 20),
            color: Colors.white,
            onPressed: () async {
              //bottomsheets();
              //await getimageditor();
              var image = await ImagePicker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
              var decodedImage =
              await decodeImageFromList(
                  image.readAsBytesSync());

              setState(() {
                height = decodedImage.height;
                width = decodedImage.width;
                _imageFile = image;
              });

              await saveImage(true);
            },
          ):new Container(),
          widget.networkImage == null?
          IconButton(
            icon: Icon(Icons.photo, size: 20),
            color: Colors.white,
            onPressed: () async {
              //bottomsheets();
              //await getimageditor();
              var image = await ImagePicker.pickImage(
                  source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
              var decodedImage = await decodeImageFromList(
                  image.readAsBytesSync());

              setState(() {
                height = decodedImage.height;
                width = decodedImage.width;
                _imageFile = image;
              });

              await saveImage(false);
            },
          ):new Container(),
          Builder(builder: (context) =>
          IconButton(
            icon: Icon(Icons.edit, size: 20, key:editKey),
            color: Colors.white,
            onPressed: () async {
              //bottomsheets();
              if (imagePath != null && imagePath != '') {
                if (isEditing || isSelected[0]) {
                  RestService.showSnackbar(context, "Cannot edit the photo while tagging !");
                } else {
                  await getimageditor();
                }
              } else {
                RestService.showSnackbar(context, "Please load a photo first !");
              }
            },
          )),
          Builder(builder: (context) =>
          IconButton(
            icon: Icon(Icons.crop, size: 20, key:cropKey),
            color: Colors.white,
            onPressed: () async {
              debugPrint('Cropping $imagePath');
              if (imagePath != null && imagePath != '') {
                if (isEditing || isSelected[0]) {
                  RestService.showSnackbar(context, "Cannot resize the photo while tagging !");
                } else {
                  await _cropImage();
                }
              } else {
                RestService.showSnackbar(context, "Please load a photo first !");
              }
            },
          )),
          Container(
            width: 1,
            margin: EdgeInsets.only(top:12, bottom:12, left: 2, right: 2),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.white70, width: 1.0),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right:0.0),
            child: ToggleButtons(
              children: <Widget>[
                Icon(Icons.add_box, key: addTagKey, size: 20.0),
                Icon(Icons.remove_circle, key: removeTagKey,size: 20.0),
                //Icon(Icons.crop, size: 25.0)
              ],
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelected[buttonIndex] = true;
                      isDone = false;
                    } else {
                      isSelected[buttonIndex] = false;
                    }
                  }
                });
              },
              isSelected: isSelected,
              selectedColor: Colors.pink,
              renderBorder: false,
            ),
          ),
          isSelected[0]?
          IconButton(
            icon: Icon(Icons.done, key: doneTagKey, size:20),
            color: Colors.white,
            onPressed: () async {
              debugPrint('Cropping $imagePath');
              isDone = true;
              isSelected[0] = false;
              setState(() {
              });
            },
          ) : isSelected[1]?
          IconButton(
            icon: Icon(Icons.clear, key: removeTagCancelKey, size: 20),
            color: Colors.white,
            onPressed: () async {
              debugPrint('Cropping $imagePath');
              isSelected[1] = false;
              setState(() {
              });
            },
          ): new Container()
        ],
      ): AppBar(
          title: Text(""),
          elevation: 0,
          backgroundColor: Colors.orange,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera_alt, size:20, key: openCameraKey),
              color: Colors.white,
              onPressed: () async {
                //bottomsheets();
                //await getimageditor();
                var image = await ImagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
                var decodedImage =
                await decodeImageFromList(
                    image.readAsBytesSync());

                setState(() {
                  height = decodedImage.height;
                  width = decodedImage.width;
                  _imageFile = image;
                });

                await saveImage(true);
              },
            ),
            IconButton(
              icon: Icon(Icons.photo, size: 20, key: loadKey),
              color: Colors.white,
              onPressed: () async {
                //bottomsheets();
                //await getimageditor();
                var image = await ImagePicker.pickImage(
                    source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
                var decodedImage = await decodeImageFromList(
                    image.readAsBytesSync());

                setState(() {
                  height = decodedImage.height;
                  width = decodedImage.width;
                  _imageFile = image;
                });

                await saveImage(false);
              },
            ),
          ])),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body:
          showAdminPage? AdminPage():
        CustomPainterDraggable(imagePath: this.imagePath, isSelected: this.isSelected, myController: this.myController,
            canvas: this.canvas, rects: this.rects, focusNode: focusNode, displayPictureScreenState: this, isDone: isDone,
            newImage: newImage, admin: widget.networkImage, adminDataInfo: widget.dataInfo),
//          ),
//        ],
//        crossAxisAlignment: CrossAxisAlignment.stretch,
//     ),
      //floatingActionButton:

      //Image.file(File(imagePath)),
    );
    return s;
  }
}