import 'dart:async';
import 'dart:convert';
import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:requests/requests.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/AuthService.dart';
import '../../utils/bottonNavBar.dart';
import '../../utils/settings.dart';
import 'package:flutter/services.dart';

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
  TextEditingController otpController = TextEditingController();
  String _otpCode = '';
  int _countDown = 120;
  int _otpTimeInMS = 1000 * otpStartMinutes * 60;
  final intRegex = RegExp(r'\d+', multiLine: true);
  bool keyBoardPadding = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? countdownTimer;
  String? otpAuto;

  @override
  void initState() {
    _timerstart();
    _startCountDown();
    // getSMSPermission();
    initSmsListener();
    super.initState();
  }

  Future<void> initSmsListener() async {

    String? commingSms;
     List otp = [];
    try {
      commingSms = await AltSmsAutofill().listenForSms;
      otp = commingSms!.split(" ");
    } on PlatformException {
      commingSms = 'Failed to get Sms.';
    }
    if (!mounted) return;

    setState(() {
      otpAction == 'login' ?
      otpController.text = otp[5]  : otpController.text = otp[8];
    });
  }
//##################################################################################################################################

  void _timerstart() {
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
      } else {
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
    FocusScope.of(context).unfocus();
    setState(() {
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

        await Provider.of<AuthService>(context, listen: false)
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
          "email": _eemail,
          "company_name": _compName
        },
        bodyEncoding: RequestBodyEncoding.JSON,
        timeoutSeconds: 3000);
    print("response==> ${result.body}");
    if (result.success) {
      if ((json.decode(result.content()).containsKey("action"))) {
        var _routeAction = (json.decode(result.content())['action']).toString();
        if (_routeAction == 'LogIN') {
          var _message =
              " The Mobile Number or Email provided already exists, Please try Log-In instead";
          myDialog(_message, '/Login');
        } else {
          print('sinup result else==> ${result.body} ');
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return BottomNavBar();
            },
          ));
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
          print("you are logged in");
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return BottomNavBar();
            },
          ));
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
            reverse: true,
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
                      PinCodeTextField(
                        autoFocus: true,
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        length: otpCodeLength,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          fieldOuterPadding: EdgeInsets.all(15),
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                        ),
                        cursorColor: Colors.black,
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        boxShadows: const [
                          BoxShadow(
                            offset: Offset(0, 1),
                            color: Colors.black12,
                            blurRadius: 10,
                          )
                        ],
                        onCompleted: (v) {
                          _onOtpCallBack(v, false);
                        },
                        beforeTextPaste: (text) {
                          debugPrint("Allowing to paste $text");
                          return true;
                        },
                        onChanged: (String value) {
                          setState(() {});
                        },
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _verifyOtp(otpController.text),
                        child: Container(
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
                            child: Text(
                                '${btnText.toUpperCase()} : $_countDown',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ),
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
    AltSmsAutofill().unregisterListener();
  }
}
