import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:new_cc_dialer/screens/Ts&Cs/Ts&Cs.dart';
import 'package:new_cc_dialer/screens/auth/login.dart';
import 'package:new_cc_dialer/screens/auth/otp_page.dart';
import 'package:new_cc_dialer/screens/auth/signup.dart';
import 'package:new_cc_dialer/screens/contacts/home/home_page.dart';
import 'package:new_cc_dialer/screens/dialpad/about.dart';
import 'package:new_cc_dialer/screens/dialpad/callscreen.dart';
import 'package:new_cc_dialer/screens/dialpad/dialpad.dart';
import 'package:new_cc_dialer/screens/dialpad/register.dart';
import 'package:new_cc_dialer/screens/payments/paypal/paypal.dart';
import 'package:new_cc_dialer/utils/AuthService.dart';
import 'package:new_cc_dialer/utils/bottonNavBar.dart';
import 'package:new_cc_dialer/utils/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool _procced = true;
  prefs.containsKey('accountUsername')
      ? accountUsername = prefs.getString('accountUsername')
      : _procced = false;
  prefs.containsKey('sipUsername')
      ? sipUsername = prefs.getString('sipUsername')
      : _procced = false;
  prefs.containsKey('sipPassword')
      ? sipPassword = prefs.getString('sipPassword')
      : _procced = false;
  prefs.containsKey('sipUrl')
      ? sipUrl = prefs.getString('sipUrl')
      : _procced = false;
  prefs.containsKey('sipPort')
      ? sipPort = prefs.getString('sipPort')
      : _procced = false;
  prefs.containsKey('sipCallerID')
      ? sipCallerID = prefs.getString('sipCallerID')
      : _procced = false;
  prefs.containsKey('authAction')
      ? authAction = prefs.getString('authAction')
      : _procced = false;

  if (!_procced) {
    sipUsername = null;
  }

  if (WebRTC.platformIsDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  runApp(
    ChangeNotifierProvider<AuthService>(
      child: MyMainApp(),
      create: (BuildContext context) {
        return AuthService();
      },
    ),
  );
}

typedef PageContentBuilder = Widget Function(
    [SIPUAHelper? helper, Object? arguments]);

class MyMainApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();
  Map<String, PageContentBuilder> routes ={
    '/root': ([SIPUAHelper? helper, Object? arguments]) => MyMainApp(),
    '/register': ([SIPUAHelper? helper, Object? arguments]) => RegisterWidget(helper!),
    '/callscreen': ([SIPUAHelper? helper, Object? arguments]) => CallScreenWidget(helper!,arguments as Call?),
    '/dialpad': ([SIPUAHelper? helper, Object? arguments]) => DialPadWidget(helper!),
    '/about': ([SIPUAHelper? helper, Object? arguments]) => AboutWidget(),
    '/TsCs': ([SIPUAHelper? helper, Object? arguments]) => TsCs(),
    '/paypal': ([SIPUAHelper? helper, Object? arguments]) => PayPal(),
    '/Login': ([SIPUAHelper? helper, Object? arguments]) =>  LoginPage(),
    '/SignUp': ([SIPUAHelper? helper, Object? arguments]) => SignUpPage(),
    '/OtpPage': ([SIPUAHelper? helper, Object? arguments]) => OtpPage()
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Molveni',
      debugShowCheckedModeBanner: false,
      // routes: routes,
      home:
      FutureBuilder<dynamic> (
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return
              snapshot.hasData
                ?
              BottomNavBar()
            : const LoginPage();
          } else {
            return Container(color: Colors.white);
          }
        },
      ),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final PageContentBuilder? pageContentBuilder = routes[name!];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) =>
                pageContentBuilder(helper, settings.arguments));
        return route;
      } else {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) => pageContentBuilder(helper));
        return route;
      }
    }
    return null;
  }
}
