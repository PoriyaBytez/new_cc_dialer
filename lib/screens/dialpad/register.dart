import 'package:flutter/material.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/settings.dart';

class RegisterWidget extends StatefulWidget {
  final SIPUAHelper _helper;

  RegisterWidget(this._helper, {Key? key}) : super(key: key);

  @override
  _MyRegisterWidget createState() => _MyRegisterWidget();
}

class _MyRegisterWidget extends State<RegisterWidget>
    implements SipUaHelperListener {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _wsUri = TextEditingController();
  final TextEditingController _sipUri = TextEditingController();
  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _authorizationUser = TextEditingController();
  Map<String, String> _wsExtraHeaders = {
    // 'Origin': 'https://$sipUrl',
    // 'Host': '$sipUrl:$sipPort'
  };
  SharedPreferences? _preferences;
  RegistrationState? _registerState;

  SIPUAHelper? get helper => widget._helper;

  @override
  void initState() {
    super.initState();
    _registerState = helper!.registerState;
    helper!.addSipUaHelperListener(this);
    _loadSettings();
  }

  @override
  deactivate() {
    super.deactivate();
    helper!.removeSipUaHelperListener(this);
    _saveSettings();
  }

  void _loadSettings() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _wsUri.text =
          _preferences!.getString('ws_uri') ?? 'ws://62.171.132.25:4079';
      _sipUri.text =
          _preferences!.getString('sip_uri') ?? '3406182044@62.171.132.25';
      _displayName.text =
          _preferences!.getString('display_name') ?? '3406182044';
      _password.text = _preferences!.getString('password') ?? 'S^x8CK&w';
      _authorizationUser.text =
          _preferences!.getString('auth_user') ?? '3406182044';
    });
  }

  void _saveSettings() {
    _preferences!.setString('ws_uri', _wsUri.text);
    _preferences!.setString('sip_uri', _sipUri.text);
    _preferences!.setString('display_name', _displayName.text);
    _preferences!.setString('password', _password.text);
    _preferences!.setString('auth_user', _authorizationUser.text);
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSave(BuildContext context) {
    if (_wsUri.text == "") {
      _alert(context, "WebSocket URL");
    } else if (_sipUri.text == "") {
      _alert(context, "SIP URI");
    }

    UaSettings settings = UaSettings();

    settings.webSocketUrl = _wsUri.text;
    settings.uri = _sipUri.text;
    settings.authorizationUser = _authorizationUser.text;
    settings.password = _password.text;
    settings.displayName = _displayName.text;
    settings.webSocketSettings.extraHeaders = _wsExtraHeaders;
    settings.webSocketSettings.allowBadCertificate = true;
    settings.dtmfMode = DtmfMode.RFC2833;

    helper!.start(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("SIP Account"),
        ),
        body: Align(
            alignment: const Alignment(0, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 18.0),
                        child: Center(
                            child: Text(
                          'Register Status: ${EnumHelper.getName(_registerState!.state)}',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black54),
                        )),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(48.0, 18.0, 48.0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('WebSocket:'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                        child: TextFormField(
                          controller: _wsUri,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('SIP URI:'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                        child: TextFormField(
                          controller: _sipUri,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Authorization User:'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                        child: TextFormField(
                          controller: _authorizationUser,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10.0),
                            border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                            hintText: _authorizationUser.text.isEmpty
                                ? '[Empty]'
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Password:'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                        child: TextFormField(
                          controller: _password,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10.0),
                            border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                            hintText: _password.text.isEmpty ? '[Empty]' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(46.0, 18.0, 48.0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Display Name:'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48.0, 0.0, 48.0, 0),
                        child: TextFormField(
                          controller: _displayName,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 18.0, 0.0, 0.0),
                      child: SizedBox(
                        height: 48.0,
                        width: 160.0,
                        child: MaterialButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () => _handleSave(context),
                          child: const Text(
                            'Register',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ))
                ])));
  }

  @override
  void transportStateChanged(TransportState state) {}

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void registrationStateChanged(RegistrationState state) {
    print("state == $_registerState");
    setState(() {
      _registerState = state;
    });
  }

  @override
  void onNewNotify(Notify ntf) {}

  @override
  void callStateChanged(Call call, CallState state) {}
}
