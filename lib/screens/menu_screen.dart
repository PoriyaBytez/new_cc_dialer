import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/AuthService.dart';
import '../utils/settings1.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  SharedPreferences? _preferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appcolor.dialmainbackground,
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blue),
            title: const Text(
              "Share App with Friends",
              style: TextStyle(fontSize: 17),
            ),
            onTap: () {
              Share.share(
                  "Call cheap to Africa, Almost as if IT'S FREE. Download our free APP at: http://onelink.to/wg4zbg");
            },
          ),
          const Divider(
            height: 2,
            color: Colors.blue,
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
            title: const Text("Whatsapp Us", style: TextStyle(fontSize: 17)),
            onTap: () async {
              print("sipUsername ==> ${sipUsername}");
              _preferences = await SharedPreferences.getInstance();
              String? countryCode = _preferences!.getString('countryCode');
              String? cellNumber = _preferences!.getString('countryCellNumber');
              var whatsappUrl = "whatsapp://send?phone=$supportWhatsappNumber"
                  "&text=${Uri.encodeComponent("My Account Number is: $sipUsername. My Name is: $accountUsername. My Cell Number is: +$userCountryCode$userCellNumber. Find my message below :")}";
              launchUrlString(whatsappUrl);
            },
          ),
          const Divider(
            height: 2,
            color: Colors.blue,
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: const Text("Email Us", style: TextStyle(fontSize: 17)),
            onTap: () async {
              _preferences = await SharedPreferences.getInstance();
              String? countryCode = _preferences!.getString('countryCode');
              String? cellNumber = _preferences!.getString('countryCellNumber');
              _launchEmailer(supportEmail, contactUsSubject,
                  ("My Account Number is: $sipUsername. My Name is: $sipUsername. My Cell Number is: +$countryCode$cellNumber. Find my message below :"));
            },
          ),
          const Divider(
            height: 2,
            color: Colors.blue,
          ),
          ListTile(
            leading: const Icon(Icons.call, color: Colors.blue),
            title: const Text("Call Us", style: TextStyle(fontSize: 17)),
            onTap: () {
              _launchCaller(supportNumber);
            },
          ),
          const Divider(
            height: 2,
            color: Colors.blue,
          ),
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.blue),
            title: const Text("Privacy Policy", style: TextStyle(fontSize: 17)),
            onTap: () {
              // BuildContext context;
              Navigator.pushNamed(context, '/TsCs');
            },
          ),
          const Divider(
            height: 2,
            color: Colors.blue,
          ),
          const Align(
            alignment: FractionalOffset.bottomLeft,
            child: ListTile(
              title: Text(
                "Version 1.0",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              alignment: Alignment.bottomCenter,
              decoration: const BoxDecoration(color: Color(0xfff0f8ff)),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: ListTile(
                      leading: const Icon(FontAwesomeIcons.signOutAlt,
                          color: Colors.red),
                      title:
                          const Text("Log Out", style: TextStyle(fontSize: 17)),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Exit!"),
                              content: const Text(
                                  "Do you really want to close this application !"),
                              actions: <Widget>[
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 30,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: brandColors3,
                                          ),
                                        ),
                                        child: const Text(
                                          "No",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 35,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        _cacheClearDetails();
                                        // BuildContext context;
                                        await Provider.of<AuthService>(context,
                                                listen: false)
                                            .logout();
                                        SystemNavigator.pop();
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 30,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: brandColors3,
                                          ),
                                        ),
                                        child: const Text(
                                          "Yes",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

_launchEmailer(String email, String mailSubject, String mailBody) async {
  String url =
      Uri.encodeFull("mailto:$email?subject=$mailSubject&body=$mailBody");
  if (await launchUrlString(url)) {
    await launchUrlString(url);;
  } else {
    launch(supportWebsiteURL, forceWebView: true, forceSafariVC: false);
    throw 'Could not launch $url';
  }
}

_launchCaller(String number) async {
  String url = "tel:$number";
  if (await launchUrlString(url)) {
    await launchUrlString(url);
  } else {
    launch(supportWebsiteURL, forceWebView: true, forceSafariVC: false);
    throw 'Could not launch $url';
  }
}

_cacheClearDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('accountUsername');
  prefs.remove('sipUsername');
  prefs.remove('sipPassword');
  prefs.remove('sipPort');
  prefs.remove('sipUrl');
  prefs.remove('sipCallerID');
  prefs.remove('authAction');
  prefs.remove('ws_uri');
  prefs.remove('sip_uri');
  prefs.remove('display_name');
  prefs.remove('password');
  prefs.remove('auth_user');
}
