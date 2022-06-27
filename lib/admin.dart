import 'package:flutter/cupertino.dart';

import 'gallery/gallery.dart';

class AdminPage extends StatefulWidget {

  AdminPage({Key key}):super(key:key);

  @override
  AdminPageState createState() {
    return AdminPageState();
  }
}

class AdminPageState extends State<AdminPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GalleryView(),
    );
  }
}