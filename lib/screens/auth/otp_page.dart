import 'dart:async';
import 'dart:convert';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:requests/requests.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

import '../../utils/AuthService.dart';
import '../../utils/bottonNavBar.dart';
import '../../utils/settings.dart';
// import 'package:otp_text_field/otp_text_field.dart';

class OtpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OtpPageState();
  }
}

class _OtpPageState extends State<OtpPage> {
  // aaFor CircularProgressIndicator.
  bool visible = true;
  final _formKey = GlobalKey<FormState>();

  // Getting value from TextField widget.
  int _counter = 1;
  String _counterMsg = 'Attempt 1/5';
  String _mainVerificationMsg = 'Please Enter Verification Code';
  String btnText = 'Retrying in';
  String _displaylink = '';
  String? _displaylinkNav;
  bool _otpWasUsed = false;
  bool otpIsCorrect = false;

  bool _enableButton = false;
  TextEditingController t1 = TextEditingController();
  String? _otpCode;
  int _countDown = 120;
  CountdownTimerController? controller;
  int _otpTimeInMS = 1000 * otpStartMinutes * 60;

  // String? _appSignature;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? countdownTimer;
  Duration myDuration = Duration(seconds: 30);

  @override
  void initState() {
    _timerstart();
    _startCountDown();
    super.initState();
  }


//##################################################################################################################################

  void _timerstart(){
    if (_counter <= 5) {
      _apiChooser(otpAction);
      _countDown = 120;
      _counterMsg = 'Attempt $_counter/5';
    } else {
      _counterMsg = '';
      _mainVerificationMsg = """Please use the LAST code sent to your
          Email or Try again after 1 hour""";
    }
  }

   _startCountDown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_countDown > 0) {
        _countDown--;
      }else {
        if (_otpWasUsed == false) {
          if (!mounted) return;
          _counter++;
          _timerstart();
        }
      }
      setState(() {});
    });
  }

  _onOtpCallBack(String otpCode, bool isAutofill) {
    if (!mounted) return;
    if (!mounted) return;
    setState(() {
      FocusScope.of(context).unfocus();
      _otpCode = otpCode;
      if (otpCode.length == otpCodeLength && isAutofill) {
        _otpWasUsed = true;
        btnText = 'auto otp used';
        _verifyOtp(_otpCode);
      } else if (otpCode.length == otpCodeLength && !isAutofill) {
        _otpWasUsed = true;
        btnText = 'manual otp used';
        _verifyOtp(_otpCode);

      } else {
        _otpWasUsed = false;
        btnText = 'Retrying in: ';
      }
    });
  }

  //####################################################################################################################################
  _showSnack(dynamic message) {
    FocusScope.of(context).requestFocus(FocusNode());
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 5), content: Text(message)));
    });
  }

  //#################################################################################################################################
  _cacheSaveDetails(accountUsername, sipUsername, sipPassword, sipUrl, sipPort,
      sipCallerID, authAction) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('accountUsername', accountUsername);
    prefs.setString('sipUsername', sipUsername);
    prefs.setString('sipPassword', sipPassword);
    prefs.setString('sipUrl', sipUrl);
    prefs.setString('sipPort', sipPort);
    prefs.setString('sipCallerID', sipCallerID);
    prefs.setString('authAction', authAction);
  }

  //#################################################################################################################################

  myDialog(message, redirect) {
    Alert(
      context: _scaffoldKey.currentContext!,
      type: AlertType.warning,
      title: "OOPS !",
      desc: message,
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, redirect, (Route<dynamic> route) => false);
          },
          gradient: LinearGradient(
            colors: brandColors,
          ),
          child: const Text(
            "OKAY",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  //#################################################################################################################################

  _verifyOtp(dynamic _recievedCode) async {
    var otpURL =
        (otpAction == 'login') ? verifyLoginOtpURL : verifySignupOtpURL;
    print("otpurl ==== $otpURL");
    var result = await Requests.post(otpURL,
        headers: {"Content-Type": "application/json"},
        body: {
          "action": "verify",
          "token": appToken,
          "otp_code": _recievedCode,
        },
        bodyEncoding: RequestBodyEncoding.JSON,
        timeoutSeconds: 3000);
    if (result.success) {
      print('result == ${result.body}');
      if ((json.decode(result.content()).containsKey("payload"))) {
        setState(() {
          otpIsCorrect = true;
          String _accountUsername = (json.decode(result.content())['payload']
                  ['account_username'])
              .toString();
          if (_accountUsername != null) {
            accountUsername = _accountUsername.splitMapJoin(RegExp(r'\w+'),
                onMatch: (m) =>
                    '${m.group(0)}'.substring(0, 1).toUpperCase() +
                    '${m.group(0)}'.substring(1).toLowerCase(),
                onNonMatch: (n) => ' ');
          } else {
            accountUsername = 'Please Re-LogIN';
          }

          sipUsername = (json.decode(result.content())['payload']
                  ['sip_username'])
              .toString();
          sipPassword = (json.decode(result.content())['payload']
                  ['sip_password'])
              .toString();
          sipUrl = 'ipbx.noboxtelecoms.com';
          sipPort =
              (json.decode(result.content())['payload']['sip_port']).toString();

          sipCallerID =
              (json.decode(result.content())['payload']['CallerID']).toString();
          authAction = 'procced';
        });

        if (otpAction != 'login') {
          accountUsername = userFullname;
        }

        _cacheSaveDetails(
            accountUsername!.trim(),
            sipUsername!.trim(),
            sipPassword!.trim(),
            sipUrl!.trim(),
            sipPort!.trim(),
            sipCallerID!.trim(),
            authAction!.trim());

        await Provider.of<AuthService>(context,listen: false)
            .loginUser(authAction!);
        setState(() {
          Navigator.pushNamedAndRemoveUntil(
              context, '/root', (Route<dynamic> route) => false);
        });
      } else {
        _showSnack(
            'Verification OTP Code $_otpCode is Incorrect. Please enter another Code');
      }
    } else {
      _showSnack(
          'Could not connect to the server !!. Please check your Internet connection');
    }
  }

//#################################################################################################################################
  _signUpAPI(dynamic _name, dynamic _ccode, dynamic _cellNum, dynamic _eemail,
      dynamic _compName) async {
    var result = await Requests.post(signUpUrl,
        headers: {"Content-Type": "application/json"},
        body: {
          "action": "signup",
          "token": appToken,
          "app_version": appVersion,
          "full_name": _name,
          "country_code": _ccode,
          "phone_number": _cellNum,
          "email": _eemail
        },
        bodyEncoding: RequestBodyEncoding.JSON,
        timeoutSeconds: 3000);
    print('sinup result success==> ${result.body} ');

    if (result.success) {

      if ((json.decode(result.content()).containsKey("action"))) {
        var _routeAction = (json.decode(result.content())['action']).toString();
        if (_routeAction == 'LogIN') {
          var _message =
              " The Mobile Number or Email provided already exists, Please try Log-In instead";
          myDialog(_message, '/Login');
        }else{
          print('sinup result else==> ${result.body} ');

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return BottomNavBar();
          },));
        }
      }
    }
  }

//#################################################################################################################################

  _logInAPI(dynamic _ccode, dynamic _cellNum) async {
    var result = await Requests.post(logInUrl,
        headers: {"Content-Type": "application/json"},
        body: {
          "action": "login",
          "token": appToken,
          "app_version": appVersion,
          "country_code": _ccode,
          "phone_number": _cellNum
        },

        bodyEncoding: RequestBodyEncoding.JSON,
        timeoutSeconds: 3000);

    print("login url = ${result.body}");

    if (result.success) {
      if ((json.decode(result.content()).containsKey("action"))) {
        var _routeAction = (json.decode(result.content())['action']).toString();
        if (_routeAction == 'SignUp') {
          var _message =
              "The Mobile Number provided does not exists, Please create an Account";
          myDialog(_message, '/SignUp');
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return BottomNavBar();
          },));
        }
      }
    }
  }

//#################################################################################################################################
  _apiChooser(String? signorLog) async {
    (signorLog == 'login')
        ? _logInAPI(userCountryCode, userCellNumber)
        : _signUpAPI(userFullname, userCountryCode, userCellNumber, userEmail,
            companyDetailName);
    (signorLog == 'login')
        ? _displaylink = "Try Another Account"
        : _displaylink = "Try Another Number";
    (signorLog == 'login')
        ? _displaylinkNav = '/Login'
        : _displaylinkNav = '/SignUp';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('countryCode', userCountryCode!);
    prefs.setString('countryCellNumber', userCellNumber!);
  }

//########################################################################################################################################################################

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
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
                        child: Image.asset('lib/assets/images/Group 35718.png'),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Verification',
                          style: TextStyle(
                              color: appcolor.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w800),
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
                      Spacer(),
                      Container(
                        height: 60,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, right: 0),
                            child: Text(
                              _mainVerificationMsg.toString(),
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, right: 0),
                            child: Text(
                              _counterMsg.toString(),
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      TextFieldPin(
                        textController: t1,
                        codeLength: otpCodeLength,
                        defaultBoxSize: 48,
                        textStyle: const TextStyle(
                            fontSize: 16, color: appcolor.black),
                        autoFocus: true,
                        selectedDecoration: BoxDecoration(
                            // borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10)),
                        onChange: (code) {
                          Provider.of<AuthService>(context, listen: false);
                          setState(() {
                            t1.text = code;
                          });
                          _onOtpCallBack(code, false);
                        },
                      ),
                      const Spacer(),
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 1.2,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: brandColors3,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text('${btnText.toUpperCase()} : $_countDown',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, right: 32),
                    child: InkWell(
                      child: Text(
                        _displaylink,
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w800),
                      ),
                      onTap: () async {
                        if (!mounted) return;
                        setState(() {
                          visible = true;
                          _counter = 1;
                          _counterMsg = 'Attempt 1/5';
                          _mainVerificationMsg =
                              'Please Enter Verification Code';
                          btnText = 'Retrying in';
                          _otpWasUsed = false;
                          otpIsCorrect = false;
                          _enableButton = false;
                          _otpCode;
                          _otpTimeInMS = 1000 * otpStartMinutes * 60;
                        });
                        Navigator.pushNamed(
                            context, _displaylinkNav.toString());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    countdownTimer!.cancel();
  }
}
