
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';

class ContactPage extends StatefulWidget {

  ContactPage({Key key}):super(key:key);

  @override
  ContactPageState createState() {
    return ContactPageState();
  }
}

class ContactPageState extends State<ContactPage> {

  @override
  void initState() {
    super.initState();
  }

  final titleController = TextEditingController();
  final queriesController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    queriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(backgroundColor: Colors.orange, title: Text('Contact Us'), leading: IconButton(
        icon: Icon(Icons.arrow_back, size:20),
        color: Colors.white,
        onPressed: () async {
          Navigator.pop(context);},
        )
      ),
      body: Center(child:ListView(shrinkWrap: true, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/logo.png'), width: 180),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.only(left: 30, right: 30),
              child:
              TextField(
                controller: titleController,
                autofocus: false,
                style: TextStyle(fontSize: 15.0, color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Title',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
                  contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(left: 30, right: 30),
              child:
              TextField(
                controller: queriesController,
                keyboardType: TextInputType.multiline,
                maxLines: 12,
                autofocus: false,
                style: TextStyle(fontSize: 15.0, color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Queries',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
                  contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonTheme(
                    minWidth: 150,
                    height: 50,
                    child:
                    Builder(
                      builder: (context) =>
                          RaisedButton(onPressed: () async {
                            // final Email email = Email(
                            //   body: queriesController.text,
                            //   subject: titleController.text,
                            //   recipients: ['c.zorbas@deakin.edu.au', 'florentine.martino1@deakin.edu.au'],
                            //   cc: ['Kathryn.backholer@deakin.edu.au'],
                            //   isHTML: false,
                            // );
                            //
                            // await FlutterEmailSender.send(email);
                            final subject = titleController.text;
                            final body = queriesController.text;
                            final Uri params = Uri(
                              scheme: 'mailto',
                              path: 'c.zorbas@deakin.edu.au; florentine.martino1@deakin.edu.au',
                              query: 'subject=$subject &body=$body', //add subject and body here
                            );

                            var url = params.toString();
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                              textColor: Colors.white,
                              child: Text("Send"),
                              color: Colors.pink
                          ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ButtonTheme(
                    minWidth: 150,
                    height: 50,
                    child: RaisedButton(onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Contact Us'),
                          content: Text('1. Dr. Christina Zorbas (c.zorbas@deakin.edu.au  03 9246 8772)\n\n2. Dr. Florentine Martino (florentine.martino1@deakin.edu.au 03 5227 3413)\n\n3. A/Prof. Kathryn Backholer (Kathryn.backholer@deakin.edu.au 03 924 43836)'),
                        );
                      })
                    }, textColor: Colors.white, child: Text("Detailed Information"), color: Colors.grey
                    ),
                  ),
                ]
            ),
          ],
        )])),
    );
  }
}