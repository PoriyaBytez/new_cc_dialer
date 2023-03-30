import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

import '../../utils/settings.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  // For CircularProgressIndicator.
  bool visible = true;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Getting value from TextField widget.
  bool _autoValidateAuth1 = false;
  bool _autoValidateAuth2 = false;
  bool _autoValidateAuth3 = false;
  Country? _residence;
  String _cCode = '1';
  String? _cName;
  String? flag;
  String? _number;
  String? _fullname;
  String? _email;
  bool proceed = false;

  @override
  void initState() {
    _getSignatureCode();
    super.initState();
  }

  _getSignatureCode() async {
    String? signature = await SmsVerification.getAppSignature();
    print(
        "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
    print("signature0 $signature");
    print(
        "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
  }

//#########################################################################################################################################################################
  String? validateMobile(String? value) {
    value = value!.trimLeft();
    value = value.trimRight();
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(patttern);
    if (value.length == 0) {
      _autoValidateAuth1 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5), content: Text('Mobile is Required')));
      return null;
    } else if (value.length < 5) {
      _autoValidateAuth1 = false;
      (const SnackBar(
          duration: Duration(seconds: 5),
          content:
              Text('return "Mobile number must be more than 5 digits !"')));
      return null;
    } else if (value.length > 14) {
      _autoValidateAuth1 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('Mobile number must not be greater than 14 digits !')));
      return null;
    } else if ((value.substring(0, 1) == '0') ||
        (value.substring(0, 2)) == '00') {
      _autoValidateAuth1 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text(
              'Your mobile number must NOT start with "0" , "00" , "dial code" or "country code" !')));
      return null;
    } else if (!regExp.hasMatch(value)) {
      _autoValidateAuth1 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('Mobile Number must contain digits only !')));
      return null;
    }
    _autoValidateAuth1 = true;
    return null;
  }

  //########################################################################################################################################################################
  String? validateEmail(String? value) {
    value = value!.trimLeft();
    value = value.trimRight();
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value.length == 0) {
      _autoValidateAuth2 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5), content: Text('Email is Required')));
      return null;
    } else if (!regExp.hasMatch(value)) {
      _autoValidateAuth2 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('Invalid Email Address')));
      return null;
    } else {
      _autoValidateAuth2 = true;
      return null;
    }
  }

  //#################################################################################################################4
  String? validateName(String? value) {
    value = value!.trimLeft();
    value = value.trimRight();
    value = value.replaceAll(RegExp(' +'), ' ');
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      _autoValidateAuth3 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('Your Full Name is Required')));
      return null;
    } else if (!regExp.hasMatch(value)) {
      _autoValidateAuth3 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('Name must be a-z and A-Z')));
      return null;
    } else if (value.length < 3) {
      _autoValidateAuth3 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('Name must be more than 2 characters')));
      return null;
    } else if (value.split(' ').length <= 1) {
      _autoValidateAuth3 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text(
              'Please add a SPACE and then type in your LAST NAME just after your First Name')));
      return null;
    } else if (value.split(' ')[0].length < 3) {
      _autoValidateAuth3 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('FIRST NAME must be more than 2 characters')));
      return null;
    } else if (value.split(' ')[1].length < 3) {
      _autoValidateAuth3 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content: Text('LAST NAME must be more than 2 character')));
      return null;
    } else if (value.split(' ').length > 2) {
      _autoValidateAuth3 = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 5),
          content:
              Text('Full Name Must contain First Name and Last Name ONLY.')));
      return null;
    } else {
      _autoValidateAuth3 = true;
      return null;
    }
  }

  //####################################################################################################################################
  myDialog(BuildContext context, countryCode, cellNumber) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "CONFIRM MOBILE !",
      desc: "\"+$countryCode$cellNumber\" is where i want to recieve my PIN?",
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(true);
          },
          gradient: LinearGradient(
            colors: brandColors,
          ),
          child: const Text(
            "NO",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                '/OtpPage', (Route<dynamic> route) => false);
            //Navigator.pushNamedAndRemoveUntil(context, '/OtpPage', (Route<dynamic> route) => false);
          },
          gradient: LinearGradient(
            colors: brandColors,
          ),
          child: const Text(
            "YES",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

//########################################################################################################################################################################

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: const Color(0xff09296d),
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.82,
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
                        // fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: InkWell(
                        onTap: () async {
                          final form = _formKey.currentState;
                          form!.save();
                          if (form.validate() &
                              (_autoValidateAuth1 == true) &
                              (_autoValidateAuth2 == true) &
                              (_autoValidateAuth3 == true)) {
                            userCountryCode = _cCode;
                            userCountryName = _cName;
                            userEmail = _email;
                            userFullname = _fullname;
                            userCellNumber = _number;
                            otpAction = 'signup';
                            await myDialog(_scaffoldKey.currentContext!,
                                userCountryCode, userCellNumber);
                          } else {}
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: appcolor.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 1.55,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(top: 26),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
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
                    Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: 50,
                      margin: const EdgeInsets.only(top: 25),
                      padding: const EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: appcolor.textbackground,
                          boxShadow: [
                            BoxShadow(color: Colors.white, blurRadius: 4)
                          ]),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: validateMobile,
                        onSaved: (value) => _number = value!.trim(), // <= NEW
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.phone_iphone,
                              color: appcolor.black,
                              size: 28,
                            ),
                            hintText: 'eg. 7794500997',
                            hintStyle: TextStyle(color: Colors.grey.shade400)),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: 50,
                      margin: const EdgeInsets.only(top: 25),
                      padding: const EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: appcolor.textbackground,
                          boxShadow: [
                            BoxShadow(color: Colors.white, blurRadius: 4)
                          ]),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        validator: validateName,
                        onSaved: (value) => _fullname = value!.trim(),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.black,
                            ),
                            hintText: 'Jane Doe',
                            hintStyle: TextStyle(color: Colors.grey.shade400)),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: 50,
                      margin: const EdgeInsets.only(top: 25),
                      padding: const EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: appcolor.textbackground,
                          boxShadow: [
                            BoxShadow(color: Colors.white, blurRadius: 4)
                          ]),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        //TextInputType.emailAddress
                        validator: validateEmail,
                        onSaved: (value) => _email = value!.trim(),
                        // <= NEW

                        decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.email,
                              size: 26,
                              color: Colors.brown,
                            ),
                            hintText: 'jonedoe@example.com',
                            hintStyle: TextStyle(color: Colors.grey.shade400)),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () async {
                        final form = _formKey.currentState;
                        form!.save();
                        if (form.validate() &
                            (_autoValidateAuth1 == true) &
                            (_autoValidateAuth2 == true) &
                            (_autoValidateAuth3 == true)) {
                          userCountryCode = _cCode;
                          userCountryName = _cName;
                          userEmail = _email;
                          userFullname = _fullname;
                          userCellNumber = _number;
                          otpAction = 'signup';

                          await myDialog(_scaffoldKey.currentContext!,
                              userCountryCode, userCellNumber);
                        } else {}
                      },
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.only(top: 25),
                        width: MediaQuery.of(context).size.width / 2,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: brandColors3,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15))),
                        child: Center(
                          child: Text('Sign Up'.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
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
                          Navigator.pushNamed(context, '/Login');
                        },
                        child: RichText(
                          text: const TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Already have an account?",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal)),
                              TextSpan(
                                  text: " Login",
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
      ),
    );
  }
}
