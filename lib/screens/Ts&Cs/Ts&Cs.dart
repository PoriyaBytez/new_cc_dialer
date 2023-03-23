import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

import '../../utils/settings.dart';

//import 'package:easy_web_view/easy_web_view.dart';

class TsCs extends StatefulWidget {
  @override
  TsCsPage createState() => TsCsPage();
}

class TsCsPage extends State<TsCs> {
  String src = termsPolicyURL;
  Key key = UniqueKey();
  Key key2 = UniqueKey();
  int position = 1;
  // InAppWebViewController? webView;
  String url = "";
  double progress = 0;

  doneLoading(String A) {
    setState(() {
      position = 0;
    });
  }

  startLoading(String A) {
    setState(() {
      position = 1;
    });
  }

  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text('Privacy Policy', style: TextStyle(color: appcolor.black)),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xff1034a6), Color(0xff417dc1),Color(0xffdcdcdc)]),
            ),
          ),

          // gradient: LinearGradient(
          //   begin: Alignment.centerLeft,
          //   end: Alignment.centerRight,
          //   colors: brandColors3,
          // ),
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          left: true,
          right: true,
          child: IndexedStack(
            index: position,
            children: <Widget>[
              // InAppWebView(
              //   initialUrlRequest:URLRequest(url: Uri.parse(src)),
              //   key: key,
              //   // initialHeaders: {},
              //   initialOptions: InAppWebViewGroupOptions(
              //       crossPlatform: InAppWebViewOptions(
              //     // debuggingEnabled: true,
              //   )),
              //   onWebViewCreated: (InAppWebViewController controller) {
              //     webView = controller;
              //   },
              //   onLoadStart: (controller, url) {
              //     setState(() {
              //       position = 1;
              //     });
              //   },
              //   onLoadStop:
              //       (controller, url) async {
              //     setState(() {
              //       this.url = src;
              //       position = 0;
              //     });
              //   },
              //   onProgressChanged:
              //       (InAppWebViewController controller, int progress) {
              //     setState(() {
              //       this.progress = progress / 100;
              //     });
              //   },
              // ),
              Container(
                  key: key2,
                  color: Colors.white,
                  child: Center(
                      child: SizedBox(
                    width: 200,
                    height: 50,
                    child: LiquidLinearProgressIndicator(
                      value: 0.65,
                      // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(Color(0xffdcdcdc)),
                      // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors.white,borderRadius: 15,
                      // Defaults to the current Theme's backgroundColor.
                      borderColor: Colors.black,
                      borderWidth: 1.0,
                      direction: Axis.horizontal,
                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: Text("Loading..."),
                    ),
                  ))),
            ],
          ),
        ));
  }
}
