import 'package:flutter/material.dart';
import 'package:sip_ua/sip_ua.dart';

TextEditingController? textController;
final SIPUAHelper helper = SIPUAHelper();

GlobalKey navBarGlobalKey = GlobalKey(debugLabel: 'bottomAppBar');


String myTarrif = '\$ --.--';
String myBalance = '\$ --.--';

// BRANDING

// List<Color> brandColors = [Color(0xff370514), Color(0xffEB1212)];
//List<Color> brandColors = [Colors.grey.shade300, Colors.grey.shade300];
// List<Color> brandColors = [Color(0xff2a52be),Color(0xff4169e1), Color(0xffa1caf1)];
// List<Color> brandColors1 = [Color(0xff2a52be),Color(0xff4169e1), Color(0xffa1caf1)];
// List<Color> brandColors1 = [Colors.blue, Colors.grey];
List<Color> brandColors3 = [
  Color(0xff1034a6),
  Color(0xff417dc1),
  Color(0xffdcdcdc)
];
List<Color> brandColors2 = [Colors.black, Color(0xffdcdcdc)];
// List<Color> brandColors1 = [Color(0xff555555), Color(0xffdcdcdc)];
List<Color> brandColors = [Colors.black, Colors.black];
List<Color> brandColors1 = [Colors.black, Colors.black];

// Permsission Vars

bool allowLoadContacts = false;
bool allowLoadDialer = true;
bool allowBluetooth = false;

//final pi_server_port = '4081';
//final wss_server_port = '4080';
//final ws_server _port = '4079';
const appToken = '3242424';
const appVersion = 'beta';
const timeoutValue = '9';
const reseller = 'CallContinent';
const parentCompany = 'Encode1 Telecoms';
const termsPolicyURL = 'https://callcontinent.com/terms.html';
const companyDetailName = '$reseller-of-$parentCompany';
const supportNumber = '+61 467 712 794';
const supportWhatsappNumber = '+61 467 712 794';
const supportEmail = 'support@callcontinent.com.au';
const contactUsSubject = 'I need your Help';
const contactUsBody = '';
const supportWebsiteURL = 'https:www.google.com';
const apiUrl = 'https://ipbx.noboxtelecoms.com';
const cdrURL = '$apiUrl/get_cdr.php';
const signUpUrl = '$apiUrl/signup.php';
const logInUrl = '$apiUrl/login.php';
const verifySignupOtpURL = '$apiUrl/verify.php';
const verifyLoginOtpURL = '$apiUrl/verify_login.php';
const balanceURL = '$apiUrl/get_balance.php';
const taffifURL = '$apiUrl/get_tarrif.php';
const paypalUrl = 'https://ipbx.noboxtelecoms.com/payments/paypal/index.php';

String? accountUsername;
String? sipUsername;
String? sipCallerID;
String? sipPassword;
String? sipPort;
String? sipUrl;
String? vedioPort;
String? vedioUrl;
String? authAction;
String? dest;
String? prefix;
int pageIndex = 1;
int? tess;

// changable varialbes
int otpCodeLength = 4;
const otpStartMinutes = 1;
int otpMinutesIncriment = 1;
String? number2Dial;
String? otpAction;
String? userCountryCode;
String? userCountryName;
String? userEmail;
String? userFullname;
String? userCellNumber;

class appcolor {
  static const Color mainbackground = Color(0xff100c08);
  static const Color black = Colors.black;
  static const Color textbackground = Color(0xffdcdcdc);
  static const Color dialmainbackground = Color(0xfff0f8ff);
}
