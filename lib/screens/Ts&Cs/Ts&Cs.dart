import 'package:flutter/material.dart';

// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/settings.dart';

//import 'package:easy_web_view/easy_web_view.dart';

class TsCs extends StatefulWidget {
  @override
  TsCsPage createState() => TsCsPage();
}

class TsCsPage extends State<TsCs> {
  Key key = UniqueKey();
  Key key2 = UniqueKey();
  int position = 1;
  WebViewController? controller;
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
      ..loadRequest(Uri.parse(termsPolicyURL));
  }

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
                  colors: <Color>[
                    Color(0xff1034a6),
                    Color(0xff417dc1),
                    Color(0xffdcdcdc)
                  ]),
            ),
          ),
        ),
        body: WebViewWidget(
          controller: controller!,
        ));
  }
}
