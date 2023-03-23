import 'package:flutter/material.dart';

class AboutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
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
