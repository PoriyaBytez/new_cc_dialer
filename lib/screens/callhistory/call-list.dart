import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../utils/bottonNavBar.dart';
import '../../utils/settings.dart';


class UserList extends StatefulWidget {
  UserListPage createState() => UserListPage();
}

class UserListPage extends State<UserList> {
  List<Contact> contactData = [];
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  final Widget? navigationBar = navBarGlobalKey.currentWidget;

  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    getAllContacts();
  }

//#########################################################################################################################################
  String flattenPhoneNumber(String phoneStr) {
    phoneStr = phoneStr.toString().replaceFirst("00", "");
    phoneStr = phoneStr.toString().replaceFirst("+", "");
    var re = RegExp(r'\d{3}'); // replace two digits
    phoneStr = phoneStr.replaceFirst(re, '');
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

//######################################################################################################################################
  String flattenContactNumber(String phoneStr) {
    phoneStr = phoneStr.toString().replaceFirst(" ", "");
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

//######################################################################################################################################
  getAllContacts() async {
    contacts =
        (await FlutterContacts.getContacts(withPhoto: false,withProperties: true)).toList();

    //mount is slowing down things
    if (mounted) {
      if (!mounted) return;
      setState(() {
        contactData = contacts;
      });
    }
  }

//###########################################################################################################################################

  String _filterContacts(dynamic user) {
    String searchTerm = user['callednum'];
    String searchTermFlatten = flattenPhoneNumber(searchTerm);
    String? phnFlattened;
    bool numFound = false;
    var numTest2;
    var result;

    if (contactData.isNotEmpty) {
      for (var i = 0; i < contactData.length; i++) {
        if (contactData[i].phones.isNotEmpty) {
          if (contactData[i].phones.elementAt(0).number.isNotEmpty) {
            numTest2 = contactData[i].phones.elementAt(0).number;
            phnFlattened = flattenContactNumber(numTest2);
          } else if (contactData[i].phones.elementAt(1).number.isNotEmpty) {
            numTest2 = contactData[i].phones.elementAt(1).number;
            phnFlattened = flattenContactNumber(numTest2);
          }

          if (phnFlattened!.contains(searchTermFlatten)) {
            result = contactData[i].displayName;
            numFound = true;
            break;
          }
        }
      }
    }

    if (user['callednum'] == '' ||
        user['callednum'] == null ||
        user['callednum'] == 'No Calls Yet') {
      return 'No Calls Yet';
    }
    if (numFound) {
      return result;
    } else {
      return user['callednum'].toString().replaceFirst('', '00');
    }
  }

  //#################################################################################################################

  Future<List<dynamic>> fetchUsers() async {
    var conStatus = await InternetConnectionChecker().hasConnection;
    var _result;
    if (conStatus == true) {
      _result = await Requests.post(cdrURL,
          headers: {"Content-Type": 'text/plain'},
          body: {"username": "$sipUsername"},
          bodyEncoding: RequestBodyEncoding.JSON,
          timeoutSeconds: 3000,
          persistCookies: false);
    }
    var payload = json.decode(_result.body);
    return payload["payload"];
  }

//#################################################################################################################

  String _cost(dynamic user) {
    var val1 = double.parse(user['debit']);
    String val2 = val1.toString();
    return "\$ $val2";
  }

//#################################################################################################################

  String _callStartTime(dynamic user) {
    return user['callstart'].substring(10);
  }

//#################################################################################################################

  String _callStartDate(dynamic user) {
    var val1 = user['callstart'];
    var val2 = val1.substring(0, 10);

    String formatDate(String date) {
      var dateFormate = DateFormat("d MMMM yyyy").format(DateTime.parse(date));
      return dateFormate;
    }

    return formatDate(val2);
  }

//#################################################################################################################

  String _durationSeconds(dynamic user) {
    String _printDuration(Duration duration) {
      String twoDigits(int n) {
        if (n >= 10) return "$n";
        return "0$n";
      }

      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }

    final now = Duration(seconds: int.parse(user['billseconds']));
    String val2 = _printDuration(now);
    return val2;
  }

//#################################################################################################################

  Icon _callDirection(dynamic user) {
    Icon? _calldirection;

    if (user['call_direction'] == 'inbound' && user['billseconds'] == '0') {
      _calldirection = Icon(
        Icons.call_missed,
        color: Colors.red.shade900,
        size: 32.0,
        semanticLabel: 'Text to announce in accessibility modes',
      );
    } else if (user['call_direction'] == 'inbound') {
      _calldirection = Icon(
        Icons.call_received,
        color: Colors.blueAccent[800],
        size: 24.0,
        semanticLabel: 'Text to announce in accessibility modes',
      );
    } else if (user['call_direction'] == 'outbound') {
      _calldirection = const Icon(
        Icons.call_made,
        color: Colors.green,
        size: 24.0,
        semanticLabel: 'Text to announce in accessibility modes',
      );
    } else if (user['call_direction'] == 'No Calls Yet') {
      _calldirection = const Icon(
        Icons.autorenew,
        color: Colors.green,
        size: 32.0,
        semanticLabel: 'Text to announce in accessibility modes',
      );
    }
    return _calldirection!;
  }

// #################################################################################################################

  String _calledNumber(dynamic user) {
    return user['callednum'].toString();
  }

// #################################################################################################################
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: appcolor.dialmainbackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Call History',
            style: TextStyle(fontSize: 24, color: AppColor.appbarwhite)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: brandColors3),
          ),
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: FutureBuilder<List<dynamic>>(
          future: fetchUsers(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            if (!mounted) return;
                            var _dest1 = dest;
                            if (snapshot.data[index] == 'NoCallsYet') {
                              dest = _dest1;
                            }else{
                              dest = _calledNumber(snapshot.data[index])
                                  .replaceAll(' ', '')
                                  .replaceAll('+', '00')
                                  .replaceFirst('', '00')
                                  .toString();
                            }

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BottomNavBar(),
                                ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                                child: Column(children: [
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 35,
                                    width: 170,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: brandColors3,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: Text(
                                      _filterContacts(snapshot.data[index]) ??
                                          'No Data',
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.grey.shade300,
                                          child: _callDirection(
                                            snapshot.data[index],
                                          ),
                                        ),
                                        Text(
                                          _cost(snapshot.data[index]),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.green),
                                        ),
                                        Text(
                                          _callStartTime(snapshot.data[index]),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.green),
                                        ),
                                      ]),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _callStartDate(snapshot.data[index]),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          _durationSeconds(
                                              snapshot.data[index]),
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.blue),
                                        ),
                                      ])
                                ]),
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1,
                          color: Colors.blue,
                          thickness: 1,
                        ),
                      ],
                    );
                  });
            } else {
              return Center(
                  child: SizedBox(
                width: 200,
                height: 50,
                child: LiquidLinearProgressIndicator(
                  value: 0.65,
                  // Defaults to 0.5.
                  //grey.shade400,and ,white
                  valueColor: const AlwaysStoppedAnimation(Color(0xffdcdcdc)),
                  // Defaults to the current Theme's accentColor.
                  backgroundColor: Colors.white,
                  borderRadius: 15,
                  // Defaults to the current Theme's backgroundColor.
                  borderColor: Colors.black,
                  borderWidth: 1.0,
                  direction: Axis.horizontal,
                  // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                  center: const Text("Loading..."),
                ),
              ));
            }
          },
        ),
      ),
    );
  }
}
