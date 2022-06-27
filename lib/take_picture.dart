import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audio_cache.dart';
import 'display.dart';


// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
    with SingleTickerProviderStateMixin {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  int index = 0;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            debugPrint(animation.toString() + " size:" + child.toStringShort());
            final angle = Tween(begin: 0 / 360, end: 180/360);
            final tween = TweenSequence([
              TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
              TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
            ]);
            return RotationTransition(
              turns: angle.animate(animation),
              alignment: Alignment.center,
              child: ScaleTransition(
                  scale: tween.animate(animation),
                  child: child
              ),
            );
          },
          child: FloatingActionButton(
            key: UniqueKey(),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.pink,
            onPressed: () async {
              debugPrint('Hello');
              setState(() {
                index = 1;
              });

              var rng = new Random();
              int randInt = rng.nextInt(10000);
              var currentTime = DateTime.now();

              AudioCache cache = new AudioCache();
              await cache.play("cam_shutter.mp3");

              // Take the Picture in a try / catch block. If anything goes wrong,
              // catch the error.
              try {
                // Ensure that the camera is initialized.
                await _initializeControllerFuture;

                // Construct the path where the image should be saved using the
                // pattern package.
                final path = join(
                  // Store the picture in the temp directory.
                  // Find the temp directory using the `path_provider` plugin.
                  (await getTemporaryDirectory()).path,
                  '${randInt}_${currentTime.year}_${currentTime.month}_${currentTime.day}_${currentTime.hour}_${currentTime.minute}_${currentTime.second}_${currentTime.millisecond}.png',
                );

                // Attempt to take a picture and log where it's been saved.
                await _controller.takePicture(path);

                // If the picture was taken, display it on a new screen.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(imagePath: path, firstCamera: widget.camera,),
                  ),
                );
              } catch (e) {
                // If an error occurs, log the error to the console.
                print(e);
              }
            },
            child: Icon(Icons.camera),
          )
      ),
    );
  }
}