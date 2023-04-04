import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../utils/bottonNavBar.dart';
import '../../utils/settings.dart';

class Access extends StatefulWidget {
  static String tag = 'about-page';

  @override
  AccessPage createState() => AccessPage();
}

class AccessPage extends State<Access> {
  bool visible = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  myDialog() {
    Alert(
      context: _scaffoldKey.currentContext!,
      type: AlertType.warning,
      title: "OOPS !, CONTACTS Permission Required",
      desc:
          "To use Contacts, Enable Contact Permissions in your Device Settings and RESTART the APP ! DO YOU WANT TO GO TO SETTINGS ?",
      buttons: [
        DialogButton(
          onPressed: () {
            openAppSettings();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavBar(),
                ));
          },
          gradient: LinearGradient(
            colors: brandColors3,
          ),
          child: const Text(
            "YES",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(true);
          },
          gradient: LinearGradient(
            colors: brandColors3,
          ),
          child: const Text(
            "NO",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Access Required'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: brandColors3,
            ),
          ),
        ),
      ),
      body: SafeArea(
          top: false,
          bottom: true,
          left: true,
          right: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3.5,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: brandColors,
                      ),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(90))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Spacer(),
                      Align(
                        alignment: Alignment.center,
                        child: Hero(
                            tag: 'hero',
                            child: SizedBox(
                              height: 150,
                              width: 300,
                              child: Image.asset('lib/assets/images/logo.png'),
                            )),
                      ),
                      const Spacer(),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 3, right: 32),
                          child: Text(
                            '',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 40,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10, right: 0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                        child: InkWell(
                          onTap: () async {
                            myDialog();
                          },
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width / 1.2,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: brandColors,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50))),
                            child: const Center(
                              child: Text(
                                  "Tap Here to Grant CONTACT PERMISIONS",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
