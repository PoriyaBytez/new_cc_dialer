import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:requests/requests.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';
import 'widgets/action_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../utils/settings.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DialPadWidget extends StatefulWidget {
  final SIPUAHelper _helper;

  const DialPadWidget(this._helper, {Key? key}) : super(key: key);

  @override
  _MyDialPadWidget createState() => _MyDialPadWidget();
}

class _MyDialPadWidget extends State<DialPadWidget>
    implements SipUaHelperListener {
  String? testBal;
  String? _lastDialed;
  String? receivedMsg;
  final TextEditingController _password = TextEditingController();
  final TextEditingController _wsUri = TextEditingController();
  final TextEditingController _sipUri = TextEditingController();
  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _authorizationUser = TextEditingController();

  final Map<String, String> _wsExtraHeaders = {
    // 'Origin': 'https://$sipUrl',
    // 'Host': '62.171.132.25:443' //'$sipUrl:$sipPort'
  };
  SharedPreferences? _preferences;
  late RegistrationState _registerState;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  SIPUAHelper? get helper => widget._helper;
  TextEditingController textController = TextEditingController();

  @override
  initState() {
    super.initState();
    _loadSettings();
    receivedMsg = "";
    _bindEventListeners();
    _getBalance();
    _getTarrif();
    _registerState = helper!.registerState;
    helper!.addSipUaHelperListener(this);
  }

  Future<void> _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    dest = dest ?? _preferences!.getString('dest') ?? '';

    textController = TextEditingController(text: dest);
    textController.text = dest!;
    if (sipUrl != null &&
        sipUrl!.isNotEmpty &&
        sipPort != null &&
        sipPort!.isNotEmpty &&
        sipUsername != null &&
        sipUsername!.isNotEmpty &&
        sipCallerID != null &&
        sipCallerID!.isNotEmpty &&
        sipPassword != null &&
        sipPassword!.isNotEmpty) {
      _wsUri.text = 'wss://$sipUrl/ws';
      _sipUri.text = '$sipUsername@$sipUrl';
      print('_sipUri ==> ${_sipUri.text}');
      _displayName.text = '$sipCallerID';
      _password.text = '$sipPassword';
      _authorizationUser.text = sipUsername!;
    } else {
      _wsUri.text = _preferences!.getString('ws_uri')!;
      _sipUri.text = _preferences!.getString('sip_uri')!;
      _displayName.text = _preferences!.getString('display_name')!;
      _password.text = _preferences!.getString('password')!;
      _authorizationUser.text = _preferences!.getString('auth_user')!;
    }
    setState(() {});
    if (_registerState.state!.index.toString() == "0") {
      _handleSave(context);
    }
  }

  void _saveSettings() {
    _preferences!.setString('ws_uri', _wsUri.text);
    _preferences!.setString('sip_uri', _sipUri.text);
    _preferences!.setString('display_name', _displayName.text);
    _preferences!.setString('password', _password.text);
    _preferences!.setString('auth_user', _authorizationUser.text);
    _preferences!.setString('dest', dest!);
  }

  _bindEventListeners() {
    helper!.addSipUaHelperListener(this);
  }

  void _handleSave(BuildContext context) {
    if (_wsUri.text == '') {
      _alert(context, "WebSocket URL");
    } else if (_sipUri.text == '') {
      _alert(context, "SIP URI");
    }
    UaSettings settings = UaSettings();

    settings.webSocketSettings.userAgent = 'Dart/2.8 (dart:io) for OpenSIPS.';
    settings.webSocketUrl = _wsUri.text;
    settings.uri = _sipUri.text;
    settings.authorizationUser = _authorizationUser.text;
    settings.password = _password.text;
    settings.displayName = _displayName.text;
    settings.userAgent = 'Dart SIP Client v1.0.0';
    settings.dtmfMode = DtmfMode.RFC2833;
    settings.register;

    helper!.start(settings);
  }

  Future<Widget?> _handleCall(BuildContext context,
      [bool voiceonly = false]) async {
    if (testBal == '0.00') {
      Alert(
        context: context,
        type: AlertType.error,
        title: "No Credit!",
        desc: "To make a call, Please Top-Up your account",
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
    } else {
      if (dest == null || dest!.isEmpty) {
        if (mounted) {
          setState(() {
            textController.text = _lastDialed.toString();
            dest = _lastDialed.toString();
          });
        }
      }
      final mediaConstraints = <String, dynamic>{'audio': true, 'video': true};

      MediaStream mediaStream;

      if (kIsWeb && !voiceonly) {
        mediaStream =
            await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
        mediaConstraints['video'] = false;
        MediaStream userStream =
            await navigator.mediaDevices.getUserMedia(mediaConstraints);
        mediaStream.addTrack(userStream.getAudioTracks()[0], addToNative: true);
      }

      dest = textController.text; //replaceFirst('00', '')
      _lastDialed = textController.text;
      _preferences!.setString('dest', dest!);
      helper!.call(dest!.replaceFirst('00', ''),
          voiceonly: voiceonly); //voiceonly
      ProximityScreenLock.setActive(true);
      return null;
    }
    return null;
  }

  _handleBackSpace([bool deleteAll = false]) {
    FocusScope.of(context).unfocus();
    var text = textController.text;
    if (text.isNotEmpty) {
      setState(() {
        text = deleteAll ? '' : text.substring(0, text.length - 1);
        textController.text = text;
      });
    }
  }

  void _handleNum(String number) {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      textController.text += number;
      _getTarrif();
      _getBalance();
    });
  }

  void _alert(BuildContext context, String alertFieldName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$alertFieldName is empty'),
          content: Text('Please enter $alertFieldName!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                _handleSave(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//#################################################################################################################################
  void _showSnack(String message) {
    FocusScope.of(context).requestFocus(FocusNode());
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 5), content: Text(message)));
    });
  }

//#################################################################################################################################
  void _getBalance() async {
    var result = await Requests.post(balanceURL,
        headers: {"Content-Type": "application/json"},
        body: {"username": sipUsername},
        bodyEncoding: RequestBodyEncoding.JSON,
        timeoutSeconds: 3000);
    if (result.success) {
      if ((json.decode(result.content()).containsKey("payload")) != null) {
        if (!mounted) return;
        setState(() {
          var _value = (json.decode(result.content())['payload'].toString());

          if (_value == 'null' || _value.isEmpty) {
            _value = '0.00 USD';
          }

          myBalance = '\$ ${_value.substring(0, _value.length - 4)}';
          testBal = _value.substring(0, _value.length - 4).trim();
        });
      } else {
        _showSnack(
            'Cloud not get your account balance.Your Account nummber may not exist');
      }
    } else {
      _showSnack(
          'Could not connect to the server !!. Please check your Internet connection');
    }
  }

  void _getTarrif() async {
    var result = await Requests.post(taffifURL,
        headers: {"Content-Type": "application/json"},
        body: {
          "username": sipUsername,
          "prefix": textController.text
              .replaceFirst('00', '')
              .replaceAll(' ', '')
              .replaceAll('+', '')
              .replaceFirst(RegExp(r'00'), '')
              .toString()
        },
        bodyEncoding: RequestBodyEncoding.JSON,
        timeoutSeconds: 1800);
    if (result.success) {
      if ((json.decode(result.content()).containsKey("payload")) != null) {
        if (!mounted) return;
        setState(() {
          var _value = (json.decode(result.content())['payload'].toString());
          if (_value == 'null') {
            _value = '-.--';
          }
          myTarrif = '\$ $_value/min';
          if (_value.contains(' ')) {
            myTarrif = '\$ ${_value.substring(0, _value.length - 3)}/min';
          }
        });
      }
    } else {
      _showSnack(
          'Could not connect to the server !!. Please check your Internet connection');
    }
  }

//#################################################################################################################################

  List<Widget> _buildNumPad() {
    var lables = [
      [
        {'1': '   '},
        {'2': 'abc'},
        {'3': 'def'}
      ],
      [
        {'4': 'ghi'},
        {'5': 'jkl'},
        {'6': 'mno'}
      ],
      [
        {'7': 'pqrs'},
        {'8': 'tuv'},
        {'9': 'wxyz'}
      ],
      [
        {'*': ''},
        {'0': '+'},
        {'#': ''}
      ],
    ];

    return lables
        .map((row) => Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row
                    .map((label) => ActionButton(
                          title: label.keys.first,
                          subTitle: label.values.first,
                          onPressed: () => _handleNum(label.keys.first),
                          number: true,
                        ))
                    .toList())))
        .toList();
  }

  // bool cancelBoole = false;

  List<Widget> _buildDialPad() {
    _getTarrif();
    return [
      SizedBox(
          width: 400,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 350,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.singleLineFormatter,
                    ],
                    enableInteractiveSelection: true,
                    showCursor: true,
                    readOnly: true,
                    autofocus: false,
                    cursorColor: Colors.red[900],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 34, color: Colors.black54),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Number"
                    ),
                    onChanged: (value) {},
                    controller: textController,
                  ),
                ),
              ])),
      const SizedBox(
        height: 50,
      ),
      SizedBox(
          width: 400,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildNumPad())),
      const SizedBox(
        height: 20,
      ),
      SizedBox(
          width: 305,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 3,
                child: ActionButton(
                    icon: Icons.call,
                    fillColor: Colors.green.shade400,
                    onPressed: () =>_handleCall(context, true),
                   ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: InkWell(
                      onLongPress: () {
                        _handleBackSpace(true);
                      },
                      onTap: () {
                        _handleBackSpace();
                      },
                      child: const Icon(
                        Icons.backspace_rounded,
                        size: 36,
                        color: Color(0xff778899),
                      ),
                    )),
              ),
            ],
          ))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      left: true,
      right: true,
      child: Scaffold(
          backgroundColor: appcolor.dialmainbackground,
          key: _scaffoldKey,
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                          child: Text(
                            myTarrif,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xff2a52be),
                            ), //,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 5.0, 10.0, 5.0),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "lib/assets/images/img_1.png",
                                    height: 24,
                                    width: 24,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    myBalance,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 15, color: Color(0xff2a52be)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15.0,
                          ),
                          Column(children: [
                            Image.asset(
                              _registerState.state!.index.toString() != '2'
                                  ? "lib/assets/images/img_2.png"
                                  : "lib/assets/images/img_3.png",
                              height: 33,
                              width: 33,
                            ),
                            Text(
                                _registerState.state!.index.toString() != '2'
                                    ? "Connecting..."
                                    : 'Connected',
                                style: const TextStyle(fontSize: 10)),
                          ]),
                        ],
                      ),
                    ]),
                const Spacer(),
                const Spacer(),
                Column(
                  children: _buildDialPad(),
                ),
                const Spacer(),
              ])),
    );
  }

  @override
  void callStateChanged(Call call, CallState state) {
    if (state.state == CallStateEnum.CALL_INITIATION) {
      Navigator.pushNamed(context, '/callscreen', arguments: call);
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    //Save the incoming message to DB
    // String? msgBody = msg.request.body as String?;
    // setState(() {
    //   receivedMsg = msgBody;
    // });
  }

  @override
  void onNewNotify(Notify ntf) {}

  @override
  void registrationStateChanged(RegistrationState state) {
    setState(() {
      _registerState = state;
    });
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  deactivate() {
    super.deactivate();
    // textController.text;
    helper!.removeSipUaHelperListener(this);
    _saveSettings();
  }
}
