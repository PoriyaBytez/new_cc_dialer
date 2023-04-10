import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_cc_dialer/utils/permissions_service.dart';
import 'package:new_cc_dialer/utils/settings.dart';

// import 'package:open_whatsapp/open_whatsapp.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:requests/requests.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/auth/access_required.dart';
import '../screens/callhistory/call-list.dart';
import '../screens/contacts/app_module.dart';
import '../screens/dialpad/dialpad.dart';
import '../screens/menu_screen.dart';
import '../screens/payments/paypal/paypal.dart';
import 'app_colors.dart';

class BottomNavBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BottomNavBarState();
  }
}

class _BottomNavBarState extends State<BottomNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var listener;

  final UserList _callCallList = UserList();
  final MenuScreen menuScreen = const MenuScreen();
  final ContactsModule _contacts = ContactsModule();
  final Access _contactsMissing = Access();
  final PayPal _paypal = PayPal();
  static final DialPadWidget _dialPadWidget = DialPadWidget(helper);
  int pageIndex = 1;

  @override
  void initState() {
    super.initState();
    askPermission();
  }

//############################################################################################################

  checkData() async {
    listener = await InternetConnectionChecker().hasConnection;
    {
      if (listener) {
      } else {
        Alert(
          context: context,
          type: AlertType.error,
          title: "NO DATA CONNECTION !",
          desc:
              "Please connect to Wi-Fi or turn on Mobile Data to use this APP",
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: brandColors3,
              ),
              child: const Text(
                "I GET IT",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            )
          ],
        ).show();
      }
    }
    ;
  }

  Future<bool> askPermission() async {
    FlutterContacts.config.includeNotesOnIos13AndAbove = false;
    Map<Permission, PermissionStatus> status = await [Permission.contacts,Permission.microphone].request();
    print("status ==> ${status}");
    if (status == true) {

      askPermission();
      setState(() {
        isCheck = false;
      });
      return false;
    } else {
      setState(() {
        isCheck = true;
      });
      getAllContacts();
      return true;
    }
  }

  bool isCheck = false;

//############################################################################################################
  checkContactPermission() async {
    PermissionService().hasPermission(Permission.contacts).then((value) async {
      if (value) {
        setState(() {
          allowLoadContacts = true;
        });
      } else {
        await _askContactPermissions().then((value) {
          // if (value) {
          //   if (!mounted) return;
          //   setState(() {
          //     allowLoadContacts = true;
          //   });
          // } else {
          //   if (!mounted) return;
          //   setState(() {
          //     allowLoadContacts = false;
          //   });
          // }
        });
      }
    });
  }

//############################################################################################################
  Future<bool> _askContactPermissions() async {
    Future<bool> val =
        PermissionService().requestPermissionContacts(onPermissionDenied: () {
      // Alert(
      //   context: context,
      //   type: AlertType.warning,
      //   title: "ACCESS DENIED !",
      //   desc:
      //       "To CALL from your contacts, you need to ALLOW the app to read and sync your contacts in the phone settings ! Restart the application afterwards",
      //   buttons: [
      //     DialogButton(
      //       onPressed: () {
      //         openAppSettings();
      //       },
      //       gradient: LinearGradient(
      //         colors: [Colors.grey.shade300, Colors.grey.shade300],
      //       ),
      //       child: const Text(
      //         "COOL",
      //         style: TextStyle(color: Colors.black, fontSize: 20),
      //       ),
      //     )
      //   ],
      // ).show();
    });
    return Future.value(val);
  }

   myDialog(context) {
    return  showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              actions: [
                Center(
                    child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          size: 100,
                          Icons.error_outline_outlined,
                          color: Colors.orangeAccent,
                        ))),
                Center(
                    child: Text(
                  "CONFIRMATION",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                )),
                Center(
                    child: Text(
                  "REQUIRED !",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Text("Do you really want to close this application !",
                      style: TextStyle(fontSize: 16)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: DialogButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        gradient: LinearGradient(
                          colors: brandColors3,
                        ),
                        child: const Text(
                          "NO",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                    Expanded(
                      child: DialogButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          exit(0);
                        },
                        gradient: LinearGradient(
                          colors: brandColors3,
                        ),
                        child: const Text(
                          "YES",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    )
                  ],
                )
              ],
            );
          },
        ); //if showDialouge had returned null, then return false
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      isCheck ? menuScreen : _contactsMissing,
      allowLoadDialer ? _dialPadWidget : _contactsMissing,
      isCheck ? _contacts : _contactsMissing,
      isCheck ? _callCallList : _contactsMissing,
      isCheck ? _paypal : _contactsMissing,
    ];

    return WillPopScope(
        onWillPop: () => myDialog(context),
        child: Scaffold(
          // appBar: AppBar(title: Text("Text"),leading: InkWell(
          //     onTap: (){
          //       myDialog();
          //     },child: Icon(Icons.arrow_back)),),
          backgroundColor: appcolor.dialmainbackground,
          key: _scaffoldKey,
          body: _children[pageIndex], //_children(pageIndex),
          bottomNavigationBar: SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bottomItem(
                      pageIndex != 0 ? 55.0 : 110.0,
                      pageIndex == 0
                          ? AppColor.bottomsheet
                          : const Color(0xffdcdcdc),
                      pageIndex == 0 ? 'Menu' : "",
                      Icons.menu, () {
                    setState(() {
                      pageIndex = 0;
                      _scaffoldKey.currentState!.openDrawer();
                    });
                  }),
                  bottomItem(
                      pageIndex != 1 ? 55.0 : 110.0,
                      pageIndex == 1
                          ? AppColor.bottomsheet
                          : const Color(0xffdcdcdc),
                      pageIndex == 1 ? 'Dialpad' : "",
                      Icons.dialpad, () {
                    setState(() {
                      pageIndex = 1;
                    });
                  }),
                  bottomItem(
                      pageIndex != 2 ? 55.0 : 115.0,
                      pageIndex == 2
                          ? AppColor.bottomsheet
                          : const Color(0xffdcdcdc),
                      pageIndex == 2 ? 'Contacts' : "",
                      Icons.account_circle, () {
                    setState(() {
                      pageIndex = 2;
                    });
                  }),
                  bottomItem(
                      pageIndex != 3 ? 55.0 : 110.0,
                      pageIndex == 3
                          ? AppColor.bottomsheet
                          : const Color(0xffdcdcdc),
                      pageIndex == 3 ? 'History' : "",
                      Icons.history, () {
                    setState(() {
                      pageIndex = 3;
                    });
                  }),
                  bottomItem(
                      pageIndex != 4 ? 55.0 : 110.0,
                      pageIndex == 4
                          ? AppColor.bottomsheet
                          : const Color(0xffdcdcdc),
                      pageIndex == 4 ? 'Top-Up' : "",
                      Icons.monetization_on, () {
                    setState(() {
                      pageIndex = 4;
                    });
                  }),
                ],
              ),
            ),
          ),
        ));
  }

  bottomItem(dynamic _width, Color color, String name, IconData icon,
      void Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        width: _width,
        height: 40,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: brandColors3,
            ),
            // color: color,
            borderRadius: const BorderRadius.all(Radius.circular(17))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
              const SizedBox(
                width: 3,
              ),
              Expanded(
                  child: Text(
                name,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.clip,
                maxLines: 1,
              ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // listener.cancel();
    super.dispose();
  }
}
