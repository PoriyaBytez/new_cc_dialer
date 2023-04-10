import 'dart:io';
import 'dart:async';
import 'package:flutter_contacts/contact.dart';
import 'package:new_cc_dialer/utils/bottonNavBar.dart';
// import 'package:open_whatsapp/open_whatsapp.dart';
import 'package:appcheck/appcheck.dart';
import '../../../utils/settings.dart';
import '../home/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_module.dart';
import '../shared/repository/contact_repository.dart';

class ViewPage extends StatefulWidget {
  static String tag = 'view-page';



  ViewPage(this.contact);

  Contact contact;

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  static String defaultMessage = "No Information";

  bool existWhatsapp = false;
  Map? contact;
  HomeBloc blocHome = HomeBloc();
  ContactRepository? contactRepository;

  String? get name => widget.contact.displayName;

  @override
  void initState() {
    blocHome = HomeModule.to.getBloc<HomeBloc>();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appcolor.dialmainbackground,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight / .99),
        child: StreamBuilder(
          stream: blocHome.favoriteOut,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return AppBar(
                elevation: 0,
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
              );
            }
          },
        ),
      ),
      body: SafeArea(
          top: false,
          bottom: true,
          left: true,
          right: true,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(100),
                        bottomLeft: Radius.circular(100)),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: brandColors3,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * .94,
                  height: MediaQuery.of(context).size.height * 0.40,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 160,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              name!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.contact.phones.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                                onTap: () {
                                  if (!mounted) return;
                                  String? phonenumber = widget
                                      .contact.phones[index].number
                                      .toString();
                                  dest = phonenumber
                                      .replaceAll(' ', '')
                                      .replaceAll('+', '00');

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BottomNavBar(),
                                      ));
                                },
                                title: Text(
                                    widget.contact.phones[index].number ??
                                        defaultMessage),
                                subtitle: const Text(
                                  "Phone Number",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black54),
                                ),
                                leading: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.phone,
                                    color: Colors.blue,
                                  ),
                                )),
                          );
                        },
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.contact.emails.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                                title: Text(
                                    widget.contact.emails[index].address ??
                                        defaultMessage),
                                subtitle: const Text(
                                  "E-mail",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black54),
                                ),
                                leading: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.email,
                                    color: Colors.brown,
                                  ),
                                )),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

// void whatsAppOpen(phoneNumber, message) async {
//   await FlutterOpenWhatsapp.sendSingleMessage(phoneNumber, message);
// }
}
