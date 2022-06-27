import 'dart:collection';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scanner_mobile/search.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:scanner_mobile/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'canvas.dart';
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';


class CustomPainterDraggable extends StatefulWidget {
  final imagePath;
  List<bool> isSelected;
  CustomPainterDraggableState state;
  final myController;
  final CustomSize canvas;
  final HashMap<Rect, String> rects;
  final focusNode;
  final displayPictureScreenState;
  bool isDone;
  final newImage;
  final admin;
  final adminDataInfo;

  String getComment() {
    return state.getComment();
  }

  CustomPainterDraggable({Key key, @required this.imagePath, @required this.isSelected, @required this.myController, @required this.canvas, @required this.rects, @required this.focusNode, this.displayPictureScreenState, this.isDone, this.newImage, this.admin: false, this.adminDataInfo}):super(key:key);

  @override
  CustomPainterDraggableState createState() => state = CustomPainterDraggableState(imagePath: this.imagePath, isSelected: this.isSelected, myController: this.myController, canvas: this.canvas, mapItems: this.rects);
}

class Tag {
  final String group;
  final List<String> items;

  Tag(this.group, this.items);
}

class Attr {
  final String name;
  final String input_type;
  final bool mutable;
  final List<String> values;

  Attr(this.name, this.input_type, this.mutable, this.values);

  Map toJson() => {
    'name': name,
    'input_type': input_type,
    'mutable': mutable,
    'values': values
  };
}

class Tag2 {
  final String name;
  final List<Attr> attributes;

  Tag2(this.name, this.attributes);

  Map toJson() => {
    'name': name,
    'attributes': attributes
  };
}

class ListModel {
  List<String> timings;

  ListModel({
    this.timings,
  });

  ListModel copyWith({
    List<String> timings,
  }) =>
      ListModel(
        timings: timings ?? this.timings,
      );

  factory ListModel.fromRawJson(String str) => ListModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ListModel.fromJson(Map<String, dynamic> json) => ListModel(
    timings: json["timings"] == null ? null : json["timings"],
  );

  Map<String, dynamic> toJson() => {
    "timings": timings == null ? null : timings,
  };
}

class KeyboardVisibilityBuilder extends StatefulWidget {
  final Widget child;
  final Widget Function(
      BuildContext context,
      Widget child,
      bool isKeyboardVisible,
      ) builder;

  const KeyboardVisibilityBuilder({
    Key key,
    this.child,
    @required this.builder,
  }) : super(key: key);

  @override
  _KeyboardVisibilityBuilderState createState() => _KeyboardVisibilityBuilderState();
}

class _KeyboardVisibilityBuilderState extends State<KeyboardVisibilityBuilder>
    with WidgetsBindingObserver {
  var _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    widget.child,
    _isKeyboardVisible,
  );
}

class CustomPainterDraggableState extends State<CustomPainterDraggable> {
  var xPos = 0.0;
  var yPos = 0.0;
  var width = 0.0;
  var height = 0.0;
  var cropWidth = 0.0;
  var cropHeight = 0.0;
  var cropX = 0.0;
  var cropY = 0.0;
  bool _dragging = false;
  bool _dragging2 = false;
  bool _isPinch = false;
  var imagePath;
  ui.Image image;
  bool isImageloaded = false;
  List<bool> isSelected;
  static const RECTANGLE_TOOL = 0;
  static const ERASER_TOOL = 1;
  List<Rect> rects = [];
  int selectedRect = -1;
  List<String> litems = ["no category"];
  //List<String> litems2 = ["confectionery", "junk food"];
  String currentTagItem = "";
  String currentTagItem2 = "";
  double tagHeight = 50;
  double tagHeight2 = 45;
  HashMap<Rect, String> mapItems;
  final myController;
  CustomSize canvas;
  FocusNode focusNode;
  int previousState = 0;
  final _scrollController = ScrollController();
  NumberBox searchHeight = NumberBox();
  double screenHeight;
  Timer scheduler;
  BuildContext currentContext;
  bool isKeyVisible = false;
  List<String> recentTags = <String>[];
  List<Tag> tags;
  SharedPreferences prefs;
  GlobalKey searchKey = GlobalObjectKey("searchKey");
  GlobalKey sendKey = GlobalObjectKey("sendKey");
  GlobalKey commentKey = GlobalObjectKey("commentKey");
  double fx = 0.0;
  double fy = 0.0;
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  double orgWidth = 0;
  double orgHeight = 0;
  bool verticalSelected = true;

  void initState() {
    super.initState();
    searchHeight.value = tagHeight;
    tags = <Tag>[];

    Tag tag = new Tag('Recent Tags', []);
    tags.add(tag);

    tag = new Tag('Fast Food', ['fries', 'burger', 'pizza', 'fried chicken', 'wraps and sandwiches', 'other unhealthy fast-food (high fat salt or sugar)', 'healthier fast-food']);
    tags.add(tag);

    tag = new Tag('Alcohol Products', ['beer', 'wine', 'champagne', 'cocktail', 'spirit', 'ready-to-drink (mix in can or bottle)', 'other alcoholic product']);
    tags.add(tag);

    tag = new Tag('Alcohol Branding', ['beer brand', 'wine/champagne brand', 'spirit brand', 'other alcohol brand']);
    tags.add(tag);

    tag = new Tag('Gambling/Gaming', ['gambling']);
    tags.add(tag);

    tag = new Tag('Advertisement', ['online advertisement', 'roadside advertisement', 'transport advertising', 'retail/lifestyle/other outdoor advertising',
      'sponsorship', 'tv advertisement', 'print advertisement', 'advertisement other']);
    tags.add(tag);

    tag = new Tag('Artificially Sweetened Beverage', ['soft drink (artificially sweetened)', 'sports drinks or flavoured water (artificially sweetened)']);
    tags.add(tag);

    tag = new Tag('Baby and Toddler Formula', ['baby and toddler formula']);
    tags.add(tag);

    tag = new Tag('Branding', ['confectionery brand', 'sweet snack brand', 'savoury snack brand', 'sweetened drink brand', 'breakfast cereal brand', 'dairy brand',
      'condiment brand', 'baby formula brand', 'QSR brand', 'retailer brand', 'local restaurant/cafe', 'delivery service', 'other brand (includes brands with diverse product range)']);
    tags.add(tag);

    tag = new Tag('Breads and Grains', ['breads', 'rice', 'pasta', 'plain noodles', 'plain biscuits']);
    tags.add(tag);

    tag = new Tag('Condiments and Cullinary Ingredients (High Salt Fat or Sugar)', ['spreads (with added salt and/or sugar)', 'butter and other animal fat', 'vegetable oils', 'sauces (with added sugar, high fat)']);
    tags.add(tag);

    tag = new Tag('Condiments and Cullinary Ingredients (Low Salt Fat or Sugar)', ['sauces (high fat salt sugar)', 'spreads (no added salt and/or sugar)', 'sauces (low fat salt sugar)']);
    tags.add(tag);

    tag = new Tag('Confectionary', ['chocolate', 'candy']);
    tags.add(tag);

    tag = new Tag('Flavoured Milk', ['flavoured milk']);
    tags.add(tag);

    tag = new Tag('Fried Instant Rice and Noodle', ['fried instant rice or noodles']);
    tags.add(tag);

    tag = new Tag('Fruit and Vegetables', ['fruit', 'vegetables']);
    tags.add(tag);

    tag = new Tag('Full Fat Dairy', ['plain milk (full-fat)', 'yoghurt (full-fat and/or high sugar)', 'cheese (high-fat)', 'milk alternative (full-fat)']);
    tags.add(tag);

    tag = new Tag('Iced Deserts/Snacks', ['ice cream', 'other iced desserts']);
    tags.add(tag);

    tag = new Tag('Low Fat Dairy', ['plain milk (low-fat)', 'yoghurts (low-fat and/or low-sugar)', 'cheese (low-fat)', 'milk alternative (low-fat)']);
    tags.add(tag);

    tag = new Tag('Processed Meats and Alternatives', ['processed meats and alternatives']);
    tags.add(tag);

    tag = new Tag('Retail Packaged Meals', ['retail packaged meals (high fat salt or sugar)', 'retail packaged meals (low fat, salt or sugar)', 'pre-packaged soups']);
    tags.add(tag);

    tag = new Tag('Savoury Snack Foods', ['chips extruded snacks and popcorn', 'high fat savoury biscuits', 'salted or sugar-coated nuts', 'nuts (unsalted)', 'other fried snacks']);
    tags.add(tag);

    tag = new Tag('Sugar Sweetened Beverage', ['soft drink (sugar sweetened)', 'sports drinks or flavoured water (sugar sweetened)', 'fruit juice (<98% fruit)', 'powdered drinks']);
    tags.add(tag);

    tag = new Tag('Sweet Snack Foods', ['cakes muffins and sweet biscuits', 'sweet pies and pastries', 'sweet rice', 'jelly', 'tinned fruit in syrup', 'muesli or breakfast bars', 'dried fruit']);
    tags.add(tag);

    tag = new Tag('Unhealthy Breakfast Cereals', ['unhealthy breakfast cereals']);
    tags.add(tag);

    tag = new Tag('Unsweetened Drink', ['bottled water', 'tea/coffee', 'fruit juice (>99% fruit)']);
    tags.add(tag);

    List<Tag2> listOfTags = <Tag2>[];
    for (Tag tag in tags) {
      if (tag.group != 'Recent Tags') {
        for (String name in tag.items) {
          List<Attr> attrs = <Attr>[];
          Attr attr = new Attr('Category', 'text', false, [tag.group]);
          attrs.add(attr);
          Tag2 t = new Tag2(name, attrs);
          listOfTags.add(t);
        }
      }
    }

    // var encoder = new JsonEncoder.withIndent("  ");
    // String str = encoder.convert(listOfTags);
    // debugPrint('SPECIAL: + \n$str');

    // const oneSec = const Duration(milliseconds:1000);
    // scheduler = new Timer.periodic(oneSec, (Timer t) {
    //   debugPrint('Check keyboard: ${searchHeight.value} ${MediaQuery.of(currentContext).viewInsets.vertical}');
    //   if (searchHeight.value > tagHeight) {
    //     if (MediaQuery.of(currentContext).viewInsets.vertical <= 1) {
    //       // searchHeight.value = tagHeight;
    //       // setState(() {
    //       // });
    //     }
    //   }
    // });

    init();
  }

  String getComment() {
    return myController.text;
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer =  Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Future <Null> init() async {
    debugPrint("Loading " + widget.displayPictureScreenState.imagePath + ';' + imagePath);
    if ( (imagePath !=  widget.displayPictureScreenState.imagePath) || widget.admin) {
      imagePath = widget.displayPictureScreenState.imagePath;
      //imagePath = widget.displayPictureScreenState.imagePath;
//    File(imagePath).readAsBytesSync();
//    final ByteData data = await rootBundle.load(imagePath);
      if (imagePath != '') {
        debugPrint("Loading Image: $imagePath");
        image = await loadImage(File(imagePath).readAsBytesSync());
        await RestService.getCategories(this, litems);

        prefs = await SharedPreferences.getInstance();
        bool help = prefs.getBool('prefs_help');
        debugPrint('Help $help');
        //if (help == false)
        {
          prefs.setBool('prefs_help', false);
          //widget.displayPictureScreenState.showHelp(widget.displayPictureScreenState.addTagKey, 'Let start annotate the photo by\nclicking on the + icon\nand drawing on the photo', () {});
          widget.displayPictureScreenState.showHelp(widget.displayPictureScreenState.cropKey, 'Step 2: Press here to crop image', () {
            widget.displayPictureScreenState.showHelp(widget.displayPictureScreenState.editKey, 'Step 3: Press here to edit the image\nand remove sensitive information', () {
              widget.displayPictureScreenState.showHelp(widget.displayPictureScreenState.addTagKey, 'Step 4: Press + to drag a rectangle\naround an item (e.g. burger)', () {

              });
            });
          });
        }
      }
    }
  }

  CustomPainterDraggableState({@required this.imagePath, @required this.isSelected, @required this.myController, @required this.canvas, @required this.mapItems, @required this.focusNode});

  /// Is the point (x, y) inside the rect?
  bool _insideRect(double x, double y, Rect rect) {
    width = 20;
    debugPrint("(x,y)=" + x.toString() + "," + y.toString());
    debugPrint("[rect]=" + rect.top.toString() + "," + rect.bottom.toString() + "," + rect.left.toString() + "," + rect.right.toString());
    if (y <= rect.top + width && y >= rect.top - width && x >= rect.left && x <= rect.right) return true;
    if (y <= rect.bottom + width && y >= rect.bottom - width && x >= rect.left && x <= rect.right) return true;
    if (x <= rect.left + width && x >= rect.left - width && y >= rect.top && y <= rect.bottom) return true;
    if (x <= rect.right + width && x >= rect.right - width && y >= rect.top && y <= rect.bottom) return true;
    return false;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    // myController.dispose();
    //scheduler.cancel();
    super.dispose();
  }

  String setString(String oldList, String item, int index, int length) {
    String ret = '';
    if (oldList == null || oldList == '') {
      for(int i = 0;i < length-1;i++) {
        if (i == index) {
          ret += '$item;';
        } else {
          ret += ';';
        }
      }
      if(index == length-1) {
        ret += item;
      }
    } else {
      // List<String> its = oldList.split(';');
      // its[oldList.length] = item;
      // for(int i = 0;i < its.length;i++) {
      //   ret += its[i];
      //   //if (i != its.length-1) {
      //     ret += ';';
      //   //}
      // }
      ret = oldList + item + ';';
    }
    return ret;
  }

  Future<List<Tag>> search(String search) async {
    await Future.delayed(Duration(milliseconds: 100));
    List<Tag> searchTag = <Tag>[];
    for(int i = 0;i < tags.length;i++) {
      List<String> items = tags[i].items;
      Tag newTag = null;
      List<String> newStrs = <String>[];
      for(String str in items) {
        String searchLowerCase = search.toLowerCase();
        String targetLowerCase = str.toLowerCase();
        if (targetLowerCase.contains(searchLowerCase)) {
          newStrs.add(str);
        }
      }
      if(newStrs.length > 0) {
        newTag = new Tag(tags[i].group, newStrs);
      }
      if(newTag != null) {
        searchTag.add(newTag);
      }
    }
    return searchTag;
  }

  void updateHeight() {
    debugPrint('Text just tapped');
    searchbar.value = 1;
    setState(() {
      searchHeight.value = screenHeight;
    });
  }

  void clear() {
    this.isImageloaded = false;
    this.imagePath = '';
    rects.clear();
    width = height = 0.0;
    selectedRect = rects.length - 1;
    xPos = yPos = 0;
    mapItems.clear();
    widget.displayPictureScreenState.firstTime = true;
    myController.clear();
    setState(() {

    });
  }

  Future<bool> createNewTask(BuildContext context, String file, String comment, CustomSize canvasSize, HashMap<Rect, String> rects) async {
    Position curPos = widget.displayPictureScreenState.currentPos;
    return await RestService.requestNewTask(context, file, comment, canvasSize, rects, this, curPos);
  }

  NumberBox searchbar = new NumberBox();

  int recentItem = 0;

  Rect mapRect(
      double ax, double ay, double aw, double ah, //annotation
      double currentCanvasWidth, double currentCanvasHeight, //current canvas
      double targetImageWidth, double targetImageHeight, //Target image size
      double targetCanvasWidth, double targetCanvasHeight) { //Target canvas
    // Recalculate image width and height in target canvas
    double ratioImage = targetImageHeight/targetImageWidth;
    double ratioCanvas = targetCanvasHeight/targetCanvasWidth;
    double tih, tiw, sx, sy;
    if (ratioImage >= ratioCanvas) {
      // Fill height, use top-left origin
      tih = targetCanvasHeight;
      tiw = (targetCanvasHeight/targetImageHeight) * targetImageWidth;
      sx = (targetCanvasWidth - tiw)/2;
      sy = 0;
    } else {
      // Fill width, use top-left origin
      tiw = targetCanvasWidth;
      tih = (targetCanvasWidth/targetImageWidth) * targetImageHeight;
      sx = 0;
      sy = (targetCanvasHeight - tih)/2;
    }

    // Calculate relative position in target image
    double rx = (ax - sx)/tiw;
    double ry = (ay - sy)/tih;
    double rw = aw/tiw;
    double rh = ah/tih;

    //Fill target image in the current canvas
    ratioCanvas = currentCanvasHeight/currentCanvasWidth;
    if (ratioImage >= ratioCanvas) {
      // Fill height, use top-left origin
      tih = currentCanvasHeight;
      tiw = (currentCanvasHeight/targetImageHeight) * targetImageWidth;
      sx = (currentCanvasWidth - tiw)/2;
      sy = 0;
    } else {
      // Fill width, use top-left origin
      tiw = currentCanvasWidth;
      tih = (currentCanvasWidth/targetImageWidth) * targetImageHeight;
      sx = 0;
      sy = (currentCanvasHeight - tih)/2;
    }

    // Map to new origin
    double mx = rx * tiw + sx;
    double my = ry * tih + sy;
    double mw = rw * tiw;
    double mh = rh * tih;

    Rect mapRect = Rect.fromLTWH(mx, my, mw, mh);
    return mapRect;
  }

  void parseAnnotations(String annotStr, double imageWidth, double imageHeight, double canvasWidth, double canvasHeight) {
    List<String> strs = annotStr.split(";;");
    for (int i = 0;i < strs.length;i++) {
      String str = strs[i];
      debugPrint('Split annotation' + strs.toString());
      if (str.trim() != '') {
        List<String> annots = str.split(",");
        double x = double.parse(annots[0]);
        double y = double.parse(annots[1]);
        double w = double.parse(annots[2]);
        double h = double.parse(annots[3]);
        String a = annots[4];
        debugPrint(
            'Before parsing: $x, $y, $w, $h, ' + canvas.canvasWidth.toString() +
                ', ' + canvas.canvasHeight.toString() +
                ', $imageWidth, $imageHeight, $canvasWidth, $canvasHeight');
        Rect r = mapRect(
            x,
            y,
            w,
            h,
            canvas.canvasWidth,
            canvas.canvasHeight,
            imageWidth,
            imageHeight,
            canvasWidth,
            canvasHeight);
        debugPrint(
            'After parsing: ' + r.top.toString() + ', ' + r.left.toString() +
                ', ' + r.width.toString() + ', ' + r.height.toString());
        debugPrint('Annotation: ' + a);
        rects.add(r);
        mapItems[r] = a;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If this is a new image, we erase previous information
    if (widget.newImage.value > 0.5) {
      debugPrint('newImage ' + widget.newImage.value.toString());
      if (widget.admin && widget.adminDataInfo != null) {
        myController.text = widget.adminDataInfo['comment'];
        width = height = 0.0;
        xPos = yPos = 0;

        rects.clear();
        mapItems.clear();
        selectedRect = rects.length - 1;

        parseAnnotations(
            widget.adminDataInfo['annotation'],
            double.parse(widget.adminDataInfo['imageWidth']),
            double.parse(widget.adminDataInfo['imageHeight']),
            double.parse(widget.adminDataInfo['canvasWidth']),
            double.parse(widget.adminDataInfo['canvasHeight']));

      } else {
        rects.clear();
        width = height = 0.0;
        selectedRect = rects.length - 1;
        xPos = yPos = 0;
        mapItems.clear();
        myController.clear();
      }
      widget.newImage.value = 0.0;
    }
    debugPrint('Select changed' + previousState.toString());
    debugPrint(isSelected.toString());
    screenHeight = MediaQuery.of(context).size.height;
    currentContext = context;
    init();
    Future.delayed(Duration(seconds: 5), () {
      if (prefs != null) {
        List<String> rT = prefs.getStringList('recentTags');
        if (rT != null) {
          tags[0] = new Tag('Recent Tags', rT);
        }
      }
    });
    // if (previousState == CROP_TOOL && isSelected[CROP_TOOL] == false) {
    //   cropWidth = width;
    //   cropHeight = height;
    //   cropX = xPos;
    //   cropY = yPos;
    //   width = height = 0.0;
    //   xPos = yPos = 0;
    // }
    if (widget.isDone) {// && isSelected[CROP_TOOL] == false) {
      widget.isDone = false;
      if (width > 5 && height > 5) {
        rects.add(Rect.fromLTWH(xPos, yPos, width, height));
        width = height = 0.0;
        selectedRect = rects.length - 1;
        xPos = yPos = 0;
      }
    }
    if (isSelected[RECTANGLE_TOOL]) previousState = RECTANGLE_TOOL;
    //if (isSelected[CROP_TOOL]) previousState = CROP_TOOL;
    if (isSelected[ERASER_TOOL]) {
      previousState = ERASER_TOOL;
      width = height = 0.0;
    }
    if (rects.length > 0) {
      this.widget.displayPictureScreenState.isEditing = true;
    } else {
      this.widget.displayPictureScreenState.isEditing = false;
    }
    if (searchbar.value == 2) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (searchHeight.value > tagHeight) {
          searchHeight.value = tagHeight;
          //searchbar.value = 1;
          setState(() {});
          searchbar.value = 0;
        }
      });
    }
    if (isImageloaded) {
      return Stack(
        children: <Widget>[

          // Container(
          //     margin: EdgeInsets.only(left: 0, top: tagHeight2, right: 0, bottom: 1),
          //     height: tagHeight2,
          //     width: double.infinity,
          //
          //     child: CupertinoScrollbar(
          //         controller: _scrollController,
          //         isAlwaysShown: true,
          //         thickness: 0.5,
          //         child:new ListView.builder (
          //             controller: _scrollController,
          //         scrollDirection: Axis.horizontal,
          //         itemCount: litems.length,
          //         itemBuilder: (BuildContext ctxt, int index) {
          //           return Container(
          //             decoration: BoxDecoration(
          //               color: Colors.pink,
          //               borderRadius: BorderRadius.only(
          //                   topLeft: Radius.circular(3),
          //                   topRight: Radius.circular(3),
          //                   bottomLeft: Radius.circular(3),
          //                   bottomRight: Radius.circular(3)
          //               ),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: Colors.grey.withOpacity(0.2),
          //                   spreadRadius: 1,
          //                   blurRadius: 1,
          //                   offset: Offset(0, 1), // changes position of shadow
          //                 ),
          //               ],
          //             ),
          //             margin: EdgeInsets.only(left: 10, top: 6, right: 10, bottom: 10),
          //             padding: EdgeInsets.only(left: 5, right: 10),
          //             child: new GestureDetector(
          //               onTap: () {
          //                 debugPrint(litems[index]);
          //                 setState(() {
          //                   currentTagItem = litems[index];
          //                   if (selectedRect != -1) {
          //                     Rect selectedR = rects.elementAt(selectedRect);
          //                     mapItems[selectedR] = setString(mapItems[selectedR], litems[index], 0, 2);
          //                   }
          //                 });
          //               },
          //               child: Container(child:
          //               Row(children: <Widget>[
          //                 Icon(Icons.animation, size: 12),
          //                 Text(' ' + litems[index],
          //                   textAlign: TextAlign.center,
          //                   style: TextStyle(fontSize: 13),
          //                 ),
          //               ]),
          //                 alignment: Alignment.center,
          //               ),
          //             ),
          //           );
          //         }
          //     )
          //     )
          // ),
          KeyboardVisibilityBuilder(
              builder: (context, child, isKeyboardVisible) {
                if (isKeyboardVisible) {
                  // build layout for visible keyboard
                  debugPrint('Keyboard visible $isKeyVisible');
                  if (isKeyVisible == false) {
                    isKeyVisible = true;
                    searchbar.value = 0;
                  }
                } else {
                  debugPrint('Keyboard invisible $isKeyVisible');
                  if (isKeyVisible) {
                    isKeyVisible = false;
                    if (searchbar.value == 2) {
                      Future.delayed(Duration(milliseconds: 200), () {
                        if (searchHeight.value > tagHeight) {
                          searchHeight.value = tagHeight;
                          //searchbar.value = 1;
                          setState(() {});
                        }
                      });
                    }
                  }
                }
                return Container();
              },
            child: Container(),
            ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 50, right: 0, bottom: 0),
            child: GestureDetector(
              onTapDown: (details) {
                setState(() {
                  double x = details.localPosition.dx;
                  double y = details.localPosition.dy;
                  selectedRect = -1;
                  for (Rect rect in rects) {
                    if (_insideRect(x, y, rect)) {
                      selectedRect += 1;
                      debugPrint("insideRect: " + selectedRect.toString());
                      break;
                    }
                    selectedRect += 1;
                  }
                  if (isSelected[ERASER_TOOL]) {
                    rects.removeAt(selectedRect);
                  }
                });
              },
              onScaleStart: (details) {
                debugPrint(details.localFocalPoint.dx.toString() + ":" + details.localFocalPoint.dy.toString());
                debugPrint(details.focalPoint.dx.toString() + ":" + details.focalPoint.dy.toString());
                xPos = details.localFocalPoint.dx;
                yPos = details.localFocalPoint.dy;
                fx = details.localFocalPoint.dx;
                fy = details.localFocalPoint.dy;
                width = height = 0.0;
                _baseScaleFactor = _scaleFactor;
                if (isSelected[RECTANGLE_TOOL]) {// || isSelected[CROP_TOOL]) {
                  _dragging = true;
                }
                if (isSelected[0] == false && isSelected[1] == false) {
                  _dragging2 = true;
                  if(selectedRect != -1) {
                    orgWidth = rects[selectedRect].width;
                    orgHeight = rects[selectedRect].height;
                  }
                }
              },
              onScaleEnd: (details) {
                _dragging = false;
                _dragging2 = false;
                bool help = prefs.getBool('prefs_help');
                debugPrint('Help $help');
                //if (help == false)
                {
                  widget.displayPictureScreenState.showHelp(
                      widget.displayPictureScreenState.doneTagKey,
                      'Step 5: Press ✔ once you have drawn the rectangle.\nIt will now turn pink', () {
                    widget.displayPictureScreenState.showHelp(
                        searchKey,
                        'Step 6: Using the search function ‘find a tag’\nand select the relevant option', () {
                      widget.displayPictureScreenState.showHelp(
                          searchKey,
                          'Step 7: Repeat steps 4-7 to tag additional items', () {
                      });
                    });
                  });
                }
              },
              onScaleUpdate: (details) {
                if (_dragging) {
                  setState(() {
                    width += details.localFocalPoint.dx - fx;
                    height += details.localFocalPoint.dy - fy;
                  });
                }
                if (_dragging2) {
                  setState(() {
                    if (selectedRect != -1) {
                      rects[selectedRect] = rects[selectedRect].shift(Offset(details.localFocalPoint.dx - fx, details.localFocalPoint.dy - fy));
                    }
                  });
                }
                fx = details.localFocalPoint.dx;
                fy = details.localFocalPoint.dy;
                if(isSelected[0] == false && isSelected[1] == false) {
                  if (details.scale == 1.0) {
                    return;
                  }
                  _scaleFactor = (_baseScaleFactor * details.scale).clamp(0, 3);
                  debugPrint('Scale = ${_scaleFactor} ${details.scale}');
                  if(verticalSelected) {
                    rects[selectedRect] = Rect.fromLTWH(
                        rects[selectedRect].left, rects[selectedRect].top,
                        orgWidth, orgHeight * details.scale);
                  } else {
                    rects[selectedRect] = Rect.fromLTWH(
                        rects[selectedRect].left, rects[selectedRect].top,
                        orgWidth * details.scale, orgHeight);
                  }
                }
              },
              child: Container(
                color: Colors.white,
                child: CustomPaint(
                  painter: RectanglePainter(
                      Rect.fromLTWH(xPos, yPos, width, height), this.image, this.rects, this.selectedRect, this.mapItems, this.canvas, this.isSelected, Rect.fromLTWH(cropX, cropY, cropWidth, cropHeight)),
                  child: Container(),
                ),
              ),
            ),
          ),
          Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(left: 10, top: 60, right: 10, bottom: 0),
              child: Column(children:[
                GestureDetector(
                  onTapDown: (details) {
                    if (verticalSelected == false) {
                      setState(() { verticalSelected = true;});
                    }
                  },
                    child:
                    SizedBox(
                      height: 25,
                      width: 25,
                      child: Image.asset(
                        'assets/vertical_icon_selected.png',
                        height: 25,
                        color: verticalSelected ? Color(0xD0FF9800) : Color(0x70FF9800),
                      ),
                    )),
                SizedBox(
                    height: 10,
                    width: 15,
                ),
                GestureDetector(
                  onTapDown: (details) {
                    if (verticalSelected == true) {
                      setState(() { verticalSelected = false;});
                    }
                  },
                  child:
                  SizedBox(
                    height: 25,
                    width: 25,
                    child: Image.asset(
                      'assets/horizontal_icon_selected.png',
                      height: 25,
                      color: verticalSelected ? Color(0x70FF9800) : Color(0xD0FF9800),
                    ),
                  )
                ),
                SizedBox(
                  height: 10,
                  width: 15,
                ),
                widget.admin?
                GestureDetector(
                    onTapDown: (details) {
                      if (widget.adminDataInfo.containsKey('latitude') && widget.adminDataInfo.containsKey('longitude')) {
                        MapsLauncher.launchCoordinates(double.parse(widget.adminDataInfo['latitude']), double.parse(widget.adminDataInfo['longitude']));
                      } else {
                        // set up the button
                        Widget okButton = FlatButton(
                          child: Text("OK"),
                          onPressed: () { },
                        );
                        // set up the AlertDialog
                        AlertDialog alert = AlertDialog(
                          title: Text("Warning"),
                          content: Text("Location not found !"),
                          actions: [
                            okButton,
                          ],
                        );
                        // show the dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      }
                    },
                    child:
                    SizedBox(
                      height: 25,
                      width: 25,
                      child: Image.asset(
                        'assets/location.png',
                        height: 25,
                        color: Color(0xD0FF9800),
                      ),
                    )
                ):SizedBox(height: 10, width: 15),
              ]
              )
          ),
          Container(
            alignment: Alignment.bottomLeft,
            margin: EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 0),
            child: TextField(
              key: commentKey,
              focusNode: focusNode,
              autofocus: false,
              controller: myController,
              style: TextStyle(fontSize: 15.0, color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0x50FF9800),
                  hintText: 'Comment',
                  contentPadding: const EdgeInsets.only(left: 20.0, bottom: 8.0, top: 8.0),
                  focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                  borderRadius: BorderRadius.circular(25),
                  ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: EdgeInsets.only(bottom: 16, left: 10, right: 20, top: 0),
            child: Builder(
              builder: (context) =>
                  FloatingActionButton(
                    child: Icon(widget.admin? Icons.approval:Icons.send, key: sendKey),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    onPressed: () async {
                      debugPrint('MapItem: $mapItems');
                      debugPrint('Rects: $rects');
                      if (rects.length == 0 || rects.length != mapItems.length) {
                        RestService.showConfirmDialog(context, "Photo has no tags. Do you want to continue?", false, () async {
                          bool ret = await createNewTask(
                              context, this.imagePath, myController.text, canvas,
                              mapItems);
                          FocusScope.of(context).unfocus();
                        }, title: "Information");
                      } else {
                        bool ret = await createNewTask(
                            context, this.imagePath, myController.text, canvas,
                            mapItems);
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            color: Colors.black87,
            height: searchHeight.value,
            width: double.infinity,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SearchBar<Tag>(
                  keya: searchKey,
                  textStyle: TextStyle(color: Colors.white),
                  hintText: "Find a tag",
                  onSearch: search,
                  callback: updateHeight,
                  cancel: searchbar,
                  onItemFound: (Tag tag, int index) {
                    // return ListTile(
                    //   title: Text(tag.subGroup),
                    //   subtitle: Text(tag.group),
                    // );
                    debugPrint('Item found ' + tag.group + ' items: ' + tag.items.toString());
                    // if(tag.group == 'Item : hga 0') {
                    //                     //   return Container(child: Text(tag.group, style: TextStyle(color:Colors.pink),), height: 200,);
                    //                     // } else {
                    //                     //   return Text(tag.group);
                    //                     // }
                    return
                    new Column(children: [Text(tag.group, style: TextStyle(fontSize: 12),), Container(
                        height: 62,
                        margin: EdgeInsets.only(bottom: 10, top: 10),
                        child: StaggeredGridView.countBuilder(
                          scrollDirection: Axis.horizontal,
                          crossAxisCount: 2,
                          itemCount: tag.items.length,
                          itemBuilder: (BuildContext context, int index) => new Container(
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  topRight: Radius.circular(3),
                                  bottomLeft: Radius.circular(3),
                                  bottomRight: Radius.circular(3)
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(left: 3, top: 3, right: 3, bottom: 3),
                            padding: EdgeInsets.only(left: 3, right: 3),
                            child: new GestureDetector(
                              onTap: () {
                                debugPrint(tag.items[index]);
                                setState(() {
                                  searchHeight.value = tagHeight;
                                  searchbar.value = 3;
                                  currentTagItem = tag.items[index];
                                  if(!recentTags.contains(currentTagItem)) {
                                    if (recentTags.length < 6) {
                                      recentTags.add(tag.items[index]);
                                    } else {
                                      recentTags[0] = tag.items[index];
                                    }
                                    recentItem = (recentItem + 1) % 6;
                                  }
                                  tags[0] = new Tag('Recent Tags', recentTags);
                                  prefs.setStringList('recentTags', recentTags);
                                  if (selectedRect != -1) {
                                    Rect selectedR = rects.elementAt(selectedRect);
                                    mapItems[selectedR] = setString(mapItems[selectedR], tag.items[index], 0, 2);
                                  }

                                });
                                FocusScope.of(context).unfocus();

                                Future.delayed(Duration(seconds: 1), () {
                                  widget.displayPictureScreenState.showHelp(
                                      commentKey,
                                      'Step 8: Add comment or thoughts on the image\n(e.g. location, type of advert such as billboard,\nor social media platform)\n\nStep 9: Press this button -> to send the\ntagged image to our database', () {}
                                  , isTop: true);

                                  if(prefs != null) {
                                    prefs.setBool('showHelp', true);
                                  }
                                });
                              },
                              child: Container(
                                child: Row(children: <Widget>[
                                  Icon(Icons.animation, size: 12),
                                  Text(' ' + tag.items[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ]),
                                alignment: Alignment.center,
                              ),
                            )
                          ),
                          staggeredTileBuilder: (int index) {
                            int n;
                            if (tag.items[index].length < 10) {
                              n = tag.items[index].length * 10 ~/ 35 + 1;
                            } else if(tag.items[index].length < 15) {
                              n = tag.items[index].length * 10 ~/ 37 + 1;
                            } else if(tag.items[index].length < 20) {
                              n = tag.items[index].length * 10 ~/ 40 + 1;
                            } else if(tag.items[index].length < 25) {
                              n = tag.items[index].length * 10 ~/ 45 + 1;
                            } else if(tag.items[index].length < 30) {
                              n = tag.items[index].length * 10 ~/ 50 + 1;
                            } else if(tag.items[index].length < 35) {
                              n = tag.items[index].length * 10 ~/ 55 + 1;
                            } else if(tag.items[index].length < 40) {
                              n = tag.items[index].length * 10 ~/ 58 + 1;
                            } else {
                              n = tag.items[index].length * 10 ~/ 60 + 1;
                            }
                            return new StaggeredTile.count(1, n);
                          },
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                    ))]);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(child:
        new GestureDetector(
            onTap: () {
              debugPrint('Center clicked !');
              //widget.displayPictureScreenState.getimageditor();
            },
            child: Icon(Icons.photo, size: 120, color: Colors.grey,))
        );
    }
  }
}

class RectanglePainter extends CustomPainter {

  RectanglePainter(this.rect, this.image, this.rects, this.selectedRect, this.mapItems, this.canvas, this.isSelected, this.cropRect);
  final Rect rect;
  final ui.Image image;
  List<Rect> rects;
  final selectedRect;
  final HashMap<Rect, String> mapItems;
  CustomSize canvas;
  List<bool> isSelected;
  final Rect cropRect;

  final Paint painter = new Paint()
    ..color = Colors.amber[400]
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;

  final Paint selectedPainter = new Paint()
    ..color = Colors.pink[400]
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;

  final Paint bgPainter = new Paint()
    ..color = Color(0xff050505)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas.canvasWidth = size.width;
    this.canvas.canvasHeight = size.height;
    this.canvas.imageWidth = image.width;
    this.canvas.imageHeight = image.height;

    canvas.drawRect(Offset(0, 0) & Size(this.canvas.canvasWidth, this.canvas.canvasHeight), bgPainter);

    //Rect rect = new Rect.fromLTWH(0, 0, 0, 0)
    double canvasRatio = this.canvas.canvasHeight/this.canvas.canvasWidth;
    double imageRatio = image.height/image.width;
    if (imageRatio > canvasRatio) {
      double scale = this.canvas.canvasHeight/image.height;
      double imageWidth = image.width * scale;
      double left = (this.canvas.canvasWidth - imageWidth)/2;
      double top = 0.0;
      canvas.drawImageRect(image, new Rect.fromLTWH(0, 0, image.width * 1.0, image.height * 1.0), new Rect.fromLTWH(left, top, imageWidth, this.canvas.canvasHeight), Paint());
    } else if (imageRatio < canvasRatio) {
      double scale = this.canvas.canvasWidth/image.width;
      double imageHeight = image.height * scale;
      double left = 0.0;
      double top = (this.canvas.canvasHeight - imageHeight)/2;
      canvas.drawImageRect(image, new Rect.fromLTWH(0, 0, image.width * 1.0, image.height * 1.0), new Rect.fromLTWH(left, top, this.canvas.canvasWidth, imageHeight), Paint());
    } else {
      canvas.drawImageRect(image, new Rect.fromLTWH(0, 0, image.width * 1.0, image.height * 1.0), new Rect.fromLTWH(0, 0, this.canvas.canvasWidth, this.canvas.canvasHeight), Paint());
    }


    // canvas.drawAtlas(
    //     this.image,
    //     [
    //       /* Identity transform */
    //       RSTransform.fromComponents(
    //           rotation: 0.0,
    //           scale: 3.0,
    //           anchorX: 0.0,
    //           anchorY: 0.0,
    //           translateX: 0.0,
    //           translateY: 0.0)
    //     ],
    //     [
    //       /* A 5x5 source rectangle within the image at position (10, 10) */
    //       Rect.fromLTWH(0.0, 0.0, 105.0, 105.0)
    //     ],
    //     [/* No need for colors */],
    //     BlendMode.src,
    //     null /* No need for cullRect */,
    //     Paint());
    debugPrint('Canvas: drawImage(): ${image.width} ${image.height}; Canvas size: ${size.width} ${size.height} ${size.aspectRatio}');

    if(rect.width > 0 && rect.height > 0) {
      canvas.drawRect(rect, painter);
    }

    int index = 0;
    for (Rect rect in rects) {
      if (index == selectedRect) {
        canvas.drawRect(rect, selectedPainter);
      } else {
        canvas.drawRect(rect, painter);
      }
      if (mapItems.containsKey(rect)) {
        String tag = ' #' + mapItems[rect];
        debugPrint(tag);
        TextSpan span = new TextSpan(style: new TextStyle(color: Colors.white, fontSize: 10), text: tag);
        TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, new Offset(rect.left, rect.top));
      }
      index += 1;
    }

    /*
    final recorder = new ui.PictureRecorder();
final canvas = new Canvas(
    recorder,
    new Rect.fromPoints(
        new Offset(0.0, 0.0), new Offset(200.0, 200.0)));

final stroke = new Paint()
  ..color = Colors.grey
  ..style = PaintingStyle.stroke;

canvas.drawRect(
    new Rect.fromLTWH(0.0, 0.0, 200.0, 200.0), stroke);

final paint = new Paint()
  ..color = color
  ..style = PaintingStyle.fill;

canvas.drawCircle(
    new Offset(
      widget.rd.nextDouble() * 200.0,
      widget.rd.nextDouble() * 200.0,
    ),
    20.0,
    paint);

final picture = recorder.endRecording();
final img = picture.toImage(200, 200);
final pngBytes = await img.toByteData(format: new ui.EncodingFormat.png());

     */
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}