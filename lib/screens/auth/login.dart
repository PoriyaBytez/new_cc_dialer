import 'package:country_picker/country_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:rflutter_alert/rflutter_alert.dart';

import '../../utils/app_colors.dart';
import '../../utils/settings.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  var listener;

  bool visible = true;
  bool _autoValidateAuth = false;
  String? _cCode;
  String? _cName;
  String? flag;

  final _formKey = GlobalKey<FormState>();
  String? _number;
  Country? _residence;
  TextEditingController code=TextEditingController();
  TextEditingController name=TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    checkData();
    super.initState();
  }

  checkData() async {
    listener = await InternetConnectionChecker().hasConnection;
    {
      if (listener == true) {
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
                colors: brandColors3,
              ),
              child: const Text(
                "I GET IT",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ).show();
      }
    }

    // close listener after 30 seconds, so the program doesn't run forever
    await Future.delayed(const Duration(seconds: 30));
    // await listener.cancel();
  }

//#########################################################################################################################################################################
  String? validateMobile(String? value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(patttern);
    if (value!.isEmpty) {
      _autoValidateAuth = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5), content: Text('Mobile is Required')));
      return null;
    } else if (value.length < 5) {
      _autoValidateAuth = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content:
              Text('return "Mobile number must be more than 5 digits !"')));
      return null;
    } else if (value.length > 14) {
      _autoValidateAuth = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('Mobile number must not be greater than 14 digits !')));
      return null;
    } else if ((value.substring(0, 1) == '0') ||
        (value.substring(0, 2)) == '00') {
      _autoValidateAuth = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text(
              'Your mobile number must NOT start with "0" , "00" , "dial code" or "country code" !')));
      return null;
    } else if (!regExp.hasMatch(value)) {
      _autoValidateAuth = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('Mobile Number must be digits only !')));
      return null;
    }
    _autoValidateAuth = true;
    return null;
  }

  myDialog(BuildContext context, countryCode, cellNumber) {
    AlertDialog(
      icon: const Icon(Icons.info),
      title: const Text("CONFIRM MOBILE !"),
      // desc: "\"+$countryCode$cellNumber\" is where i want to recieve my PIN?",
      actions: [
        TextButton(
          child: const Text(
            "NO",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(true);
          },
        ),
        TextButton(
          child: const Text(
            "YES",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                '/OtpPage', (Route<dynamic> route) => false);
            //Navigator.pushNamedAndRemoveUntil(context, '/OtpPage', (Route<dynamic> route) => false);
          },
        )
      ],
    );
  }

//########################################################################################################################################################################

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: AppColor.mainbackground,
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.8,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: brandColors3,
                      ),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                          bottomRight: Radius.circular(100))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 150,
                        width: 300,
                        child: Image.asset(
                          'lib/assets/images/Group 35718.png',
                        ),
                      ),
                      InkWell(

                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: AppColor.black,
                                fontSize: 30,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 1.7,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 0),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Container(
                        height: 60,
                      ),
                      InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            // optional. Shows phone code before the country name.
                            onSelect: (Country country) {
                              setState(() {
                                _residence = country;
                                _cCode = country.phoneCode; //dialingCode
                                _cName = country.name;
                                flag = country.flagEmoji;
                              });
                            },
                          );
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width / 1.1,
                          height: 50,
                          // margin: const EdgeInsets.only(bottom: 35),
                          padding: const EdgeInsets.only(
                              top: 4, left: 16, right: 16, bottom: 4),
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              color: appcolor.textbackground,
                              boxShadow: [
                                BoxShadow(color: Colors.white, blurRadius: 4)
                              ]),
                          child: Center(
                            child: Text((_residence != null)
                                ? " $flag +$_cCode  $_cName"
                                : "Select Country",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 35),
                        padding: const EdgeInsets.only(
                            top: 4, left: 16, right: 16, bottom: 4),
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15)),
                            color: appcolor.textbackground,
                            boxShadow: [
                              BoxShadow(color: Colors.white, blurRadius: 4)
                            ]),
                        child: TextFormField(
                          validator: validateMobile,
                          keyboardType: TextInputType.number,
                          onSaved: (value) =>
                              _number = value!.trim(), // <= NEW
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: const Icon(
                                Icons.phone_iphone,
                                color: appcolor.black,
                                size: 28,
                              ),
                              hintText: 'eg.7794500997',
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade400)),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          // save the fields..
                          final form = _formKey.currentState;
                          form!.save();
                          // Validate will return true if is valid, or false if invalid.
                          if (form.validate() &
                              (_autoValidateAuth == true)) {
                            userCountryCode = _cCode;
                            userCountryName = _cName!;
                            userCellNumber = _number!;
                            otpAction = 'login';
                            myDialog(_scaffoldKey.currentContext!,
                                userCountryCode, userCellNumber);
                            Navigator.pushNamedAndRemoveUntil(context, '/OtpPage', (Route<dynamic> route) => false);
                          } else {
                            const SnackBar(content: Text("you Don't have account please create it" ),);
                          }
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width / 2,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: brandColors3,
                              ),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(15))),
                          child: Center(
                            child: Text('Login'.toUpperCase(),
                                style: TextStyle(
                                    color: AppColor.appbarwhite,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/SignUp');//OtpPage
                          },
                          child: RichText(
                            text: const TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: "Don't have an account?",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal)),
                                TextSpan(
                                    text: " Sign Up",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
  @override
  void dispose() {
    // listener.cancel();
    super.dispose();
  }
}
