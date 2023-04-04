import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../utils/settings.dart';
//import 'package:url_launcher/url_launcher.dart';



class PayPal extends StatefulWidget {
  static String tag = 'about-page';

  @override
  PayPalPage createState() => PayPalPage();
}

class PayPalPage extends State<PayPal> {
  String src = paypalUrl + '?acc=';

  WebViewController? controller;

  static Key key = UniqueKey();
  static Key key2 = UniqueKey();
  int position = 1;
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
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paypalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: appcolor.dialmainbackground,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Top Up',style: TextStyle(fontSize: 24,color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: brandColors3,
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                  size: 30.0,
                ),
                onPressed: () {
                  // if (webView != null) {
                  //   webView!.reload();
                  // }
                }),
          )
        ],
      ),
      body:  WebViewWidget(
        // initialUrl: 'https://flutter.io',
        // javascriptMode: JavascriptMode.unrestricted,
        controller: controller!,
      )
      // body: SafeArea(
      //   top: false,
      //   bottom: true,
      //   left: true,
      //   right: true,
      //   child: IndexedStack(
      //     index: position,
      //     children: <Widget>[
      //       // InAppWebView(
      //       //   initialUrlRequest: URLRequest(url: Uri.parse(src)),
      //       //   key: key,
      //       //   initialOptions: InAppWebViewGroupOptions(
      //       //       crossPlatform: InAppWebViewOptions(
      //       //       )),
      //       //   onWebViewCreated: (InAppWebViewController controller) {
      //       //     webView = controller;
      //       //   },
      //       //   onLoadStart: (InAppWebViewController controller, url) {
      //       //     setState(() {
      //       //       position = 1;
      //       //     });
      //       //   },
      //       //   onLoadStop:
      //       //       (InAppWebViewController controller, url) async {
      //       //     setState(() {
      //       //       this.url = src;
      //       //       position = 0;
      //       //     });
      //       //   },
      //       //   onProgressChanged:
      //       //       (InAppWebViewController controller, int progress) {
      //       //     setState(() {
      //       //       progress = (progress / 100) as int;
      //       //     });
      //       //   },
      //       // ),
      //       Container(
      //           key: key2,
      //           child: Center(
      //               child: SizedBox(
      //             width: 200,
      //             height: 50,
      //             child: LiquidLinearProgressIndicator(
      //               value: 0.65,
      //               // Defaults to 0.5.
      //               valueColor: AlwaysStoppedAnimation(Color(0xffdcdcdc)),
      //               // Defaults to the current Theme's accentColor.
      //               backgroundColor:  Colors.white,borderRadius: 15,
      //               // Defaults to the current Theme's backgroundColor.
      //               borderColor: Colors.black,
      //               borderWidth: 1.0,
      //               direction: Axis.horizontal,
      //               // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
      //               center: Text("Loading..."),
      //             ),
      //           ))),
      //     ],
      //   ),
      // ),
    );
  }
}
