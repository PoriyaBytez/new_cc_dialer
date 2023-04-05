import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/AuthService.dart';
import '../utils/settings.dart';

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
      appBar: AppBar(automaticallyImplyLeading: false,
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
          const SizedBox(height: 20,),
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
          const Divider(height: 2, color: Colors.blue,),
          ListTile(
            leading: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
            title: const Text("Whatsapp Us", style: TextStyle(fontSize: 17)),
            onTap: () async {
              _preferences = await SharedPreferences.getInstance();
              String? countryCode = _preferences!.getString('countryCode');
              String? cellNumber = _preferences!.getString('countryCellNumber');

              if (Platform.isIOS) {
                var whatsAppUralIos =
                    "https://wa.me/$supportiOSWhatsappNumber?text=${Uri.encodeComponent("My Account Number is: $sipUsername. My Name is: $accountUsername. My Cell Number is: +$countryCode$cellNumber  . Find my message below :")}";
                launchUrlString(whatsAppUralIos,mode: LaunchMode.externalApplication,);
              } else {
                var whatsAppUrlAndroid =
                    "whatsapp://send?phone=$supportWhatsappNumber"
                    "&text=${Uri.encodeComponent("My Account Number is: $sipUsername. My Name is: $accountUsername. My Cell Number is: +$countryCode$cellNumber  . Find my message below :")}";
                launchUrlString(whatsAppUrlAndroid,mode: LaunchMode.externalApplication);
              }
            },
          ),
          const Divider(height: 2, color: Colors.blue,),
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
          const Divider(height: 2, color: Colors.blue,),
          ListTile(
            leading: const Icon(Icons.call, color: Colors.blue),
            title: const Text("Call Us", style: TextStyle(fontSize: 17)),
            onTap: () {
              _launchCaller(supportNumber);
            },
          ),
          const Divider(height: 2, color: Colors.blue,),
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.blue),
            title: const Text("Privacy Policy", style: TextStyle(fontSize: 17)),
            onTap: () {
              // BuildContext context;
              Navigator.pushNamed(context, '/TsCs'); //'/TsCs'
            },
          ),
          const Divider(height: 2, color: Colors.blue,),
          const Align(
            alignment: FractionalOffset.bottomLeft,
            child: ListTile(
              title: Text(
                "Version 4(1.0.0)",
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
                      leading:
                      const Icon(
                          FontAwesomeIcons.rightFromBracket, color: Colors.red),
                      title: const Text(
                          "Log Out", style: TextStyle(fontSize: 17)),
                      onTap: () {
                        showDialog(
                          //show confirm dialogue
                          //the return value will be from "Yes" or "No" options
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              actions: [
                                const Center(
                                    child: CircleAvatar(
                                        radius: 80,
                                        backgroundColor: Colors.transparent,
                                        child: Icon(
                                          size: 100,
                                          Icons.error_outline_outlined,
                                          color: Colors.orangeAccent,
                                        ))),
                                const Center(
                                    child: Text(
                                      "CONFIRMATION",
                                      style: TextStyle(fontSize: 22,
                                          fontWeight: FontWeight.w400),
                                    )),
                                const Center(
                                    child: Text(
                                      "REQUIRED !",
                                      style: TextStyle(fontSize: 22,
                                          fontWeight: FontWeight.w400),
                                    )),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
                                  child: Center(
                                    child: Text("Do you really want to close",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Center(
                                    child: Text("this application !",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: DialogButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        gradient: LinearGradient(
                                          colors: brandColors3,
                                        ),
                                        child: const Text(
                                          "NO",
                                          style: TextStyle(color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: DialogButton(
                                        onPressed: () async {
                                          _cacheClearDetails();
                                          await Provider.of<AuthService>(
                                              context, listen: false).logout();
                                          Navigator.of(context).pop(true);
                                          exit(0);
                                        },
                                        gradient: LinearGradient(
                                          colors: brandColors3,
                                        ),
                                        child: const Text(
                                          "YES",
                                          style: TextStyle(color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ),
                                    )
                                  ],
                                )
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
    await launchUrlString(url);
    ;
  } else {
    launch(supportWebsiteURL, forceWebView: true, forceSafariVC: false);
    throw 'Could not launch $url';
  }
}

_launchCaller(String number) async {
  String url = Platform.isIOS ? "tel://+$supportiOSWhatsappNumber" : "tel:$number";
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
