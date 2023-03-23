import 'package:flutter/material.dart';

import '../../main.dart';
import '../../utils/settings.dart';
import '../Ts&Cs/Ts&Cs.dart';
import '../auth/login.dart';
import '../auth/otp_page.dart';
import '../auth/signup.dart';
import '../dialpad/about.dart';
import '../dialpad/callscreen.dart';
import '../dialpad/dialpad.dart';
import '../dialpad/register.dart';
import '../payments/paypal/paypal.dart';
import './home/home_module.dart';
import 'home/home_page.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final routes = <String, WidgetBuilder>{
      HomePage.tag: (context) => MyMainApp(),
      '/register': (context) => RegisterWidget(helper),
      '/callscreen': (context) => CallScreenWidget(helper),
      '/dialpad': (context) => DialPadWidget(helper),
      '/about': (context) => AboutWidget(),
      '/TsCs': (context) => TsCs(),
      '/paypal': (context) => PayPal(),
      '/Login': (context) => const LoginPage(),
      '/SignUp': (context) => SignUpPage(),
      '/OtpPage': (context) => OtpPage(),
    };
    return MaterialApp(
      title: 'Flutter Slidy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomeModule(),
      routes: routes,
    );
  }
}
