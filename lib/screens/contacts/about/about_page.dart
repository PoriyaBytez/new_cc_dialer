import 'package:flutter/material.dart';

//import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  static String tag = 'about-page';
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('About Us'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Colors.black, Colors.black]),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        left: true,
        right: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
            Center(
              child: Text(
                'NexDialer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(child: Text('NexDialer', style: TextStyle(fontSize: 16))),
            SizedBox(height: 20),
            Center(
              child: Text('Call Continent Mobile APP by:'),
            ),
            Center(
              child: Text(
                "NoBox Telecoms",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
       
          ],
        ),
      ),
    );
  }
}
