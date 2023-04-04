import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:sip_ua/sip_ua.dart';
import '../../callscreen_loader.dart';
import '../../utils/settings.dart';
import 'widgets/action_button.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'incallManager.dart';


class CallScreenWidget extends StatefulWidget {
  CallScreenWidget(this._helper,this._call, {Key? key}) : super(key: key);

  final SIPUAHelper _helper;
  final Call? _call;

  @override
  _MyCallScreenWidget createState() => _MyCallScreenWidget();
}

class _MyCallScreenWidget extends State<CallScreenWidget>
    implements SipUaHelperListener {

  String? _contactName;
  bool _timerStarted = false;
  bool _toggledOnce = false;
  RTCVideoRenderer? _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer? _remoteRenderer = RTCVideoRenderer();
  double? _localVideoHeight;
  double? _localVideoWidth;
  EdgeInsetsGeometry? _localVideoMargin;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  bool _showNumPad = false;
  String _timeLabel = '';//00:00
  Timer? _timer;
  bool _audioMuted = false;
  bool _videoMuted = false;
  bool _speakerOn = false;
  bool _hold = false;
  String? _holdOriginator;
  CallStateEnum _state = CallStateEnum.NONE;
  SIPUAHelper? get helper => widget._helper;

  bool get voiceonly =>
      (_localStream == null || _localStream!.getVideoTracks().isEmpty) &&
          (_remoteStream == null || _remoteStream!.getVideoTracks().isEmpty);

  String? get remote_identity => call?.remote_identity;

  String? get direction => call?.direction;

  Call? get call => widget._call;


  @override
  void callStateChanged(Call call, CallState callState) {
    if (callState.state == CallStateEnum.HOLD ||
        callState.state == CallStateEnum.UNHOLD) {
      _hold = callState.state == CallStateEnum.HOLD;
      _holdOriginator = callState.originator;
      setState(() {});
      return;
    }

    if (callState.state == CallStateEnum.MUTED) {
      if (callState.audio!) _audioMuted = true;
      if (callState.video!) _videoMuted = true;
      setState(() {});
      return;
    }

    if (callState.state == CallStateEnum.UNMUTED) {
      if (callState.audio!) _audioMuted = false;
      if (callState.video!) _videoMuted = false;
      setState(() {});
      return;
    }

    if (callState.state != CallStateEnum.STREAM) {
      _state = callState.state;
    }

    switch (callState.state) {
      case CallStateEnum.STREAM:
        _handelStreams(callState);
        break;
      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        _backToDialPad();
        break;
      case CallStateEnum.UNMUTED:
      case CallStateEnum.MUTED:
      case CallStateEnum.CONNECTING:
      case CallStateEnum.PROGRESS:
      case CallStateEnum.ACCEPTED:
      case CallStateEnum.CONFIRMED:
      case CallStateEnum.HOLD:
      case CallStateEnum.UNHOLD:
      case CallStateEnum.NONE:

      case CallStateEnum.CALL_INITIATION:
      case CallStateEnum.REFER:
        break;
    }
  }

  @override
  deactivate() {
    super.deactivate();
    helper!.removeSipUaHelperListener(this);
    _disposeRenderers();
  }

  @override
  initState() {
    super.initState();
    getAllContacts();
    _initRenderers();
    helper!.addSipUaHelperListener(this);
  }

  @override
  void registrationStateChanged(RegistrationState state) {}

  @override
  void transportStateChanged(TransportState state) {}

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      Duration duration = Duration(seconds: timer.tick);
      if (mounted) {
        setState(() {
          _timeLabel = [duration.inMinutes, duration.inSeconds]
              .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
              .join(':');
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _initRenderers() async {
    if (_localRenderer != null) {
      await _localRenderer!.initialize();
    }
    if (_remoteRenderer != null) {
      await _remoteRenderer!.initialize();
    }
  }

  void _disposeRenderers() {
    if (_localRenderer != null) {
      _localRenderer!.dispose();
      _localRenderer = null;
    }
    if (_remoteRenderer != null) {
      _remoteRenderer!.dispose();
      _remoteRenderer = null;
    }
  }

  void _cleanUp() {
    if (_localStream == null) return;
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream!.dispose();
    _localStream = null;
  }

  void _backToDialPad() {
    _timer?.cancel();
    if (direction == 'INCOMING') {
      InCallService().stopRingTone();
    } else {
      InCallService().stopRingBack(true);
    }
    InCallService().resetInCall();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
    _cleanUp();
  }

  void _handelStreams(CallState event) async {
    MediaStream? stream = event.stream;
    if (event.originator == 'local') {
      if (_localRenderer != null) {
        _localRenderer!.srcObject = stream;
      }
      if (!kIsWeb && !WebRTC.platformIsDesktop) {
        stream?.getAudioTracks().first.enableSpeakerphone(false);
      }
      _localStream = stream;
    }
    if (event.originator == 'remote') {
      if (_remoteRenderer != null) {
        _remoteRenderer!.srcObject = stream;
      }
      _remoteStream = stream;
    }

    setState(() {
      _resizeLocalVideo();
    });
  }

  void _resizeLocalVideo() {
    _localVideoMargin = _remoteStream != null
        ? const EdgeInsets.only(top: 15, right: 15)
        : const EdgeInsets.all(0);
    _localVideoWidth = _remoteStream != null
        ? MediaQuery.of(context).size.width / 4
        : MediaQuery.of(context).size.width;
    _localVideoHeight = _remoteStream != null
        ? MediaQuery.of(context).size.height / 4
        : MediaQuery.of(context).size.height;
  }


  void _handleHangup() {
    InCallService().stopRingTone();
    call?.hangup();
    ProximityScreenLock.setActive(false);
    _timer?.cancel();
  }

  void _handleAccept() async {
    bool remoteHasVideo = call!.remote_has_audio;
    call!.answer(helper!.buildCallOptions(!remoteHasVideo));

    InCallService().stopRingTone();
    if (_timerStarted == false) {
      _startTimer();
      _timerStarted = true;
    }
  }

  void _switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void _muteAudio() {
    if (_audioMuted) {
      call!.unmute(true, false);
    } else {
      call!.mute(true, false);
    }
  }

  void _muteVideo() {
    if (_videoMuted) {
      call!.unmute(false, true);
    } else {
      call!.mute(false, true);
    }
  }

  void _handleHold() {
    if (_hold) {
      call!.unhold();
    } else {
      call!.hold();
    }
  }

  late String _transferTarget;
  void _handleTransfer() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter target to transfer.'),
          content: TextField(
            onChanged: (String text) {
              setState(() {
                _transferTarget = text;
              });
            },
            decoration: InputDecoration(
              hintText: 'URI or Username',
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                call!.refer(_transferTarget);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleDtmf(String tone) {
    call!.sendDTMF(tone);
  }

  void _handleKeyPad() {
    setState(() {
      _showNumPad = !_showNumPad;
    });
  }

  Future<void> _toggleSpeaker() async {
    print("_toggleSpeaker is called");
    setState(() {
      _speakerOn = !_speakerOn;
    });
    Helper.setSpeakerphoneOn(!_speakerOn);
    InCallService().proximity(!_speakerOn);
  }

  //#########################################################################################################################################

  String flattenPhoneNumber(String phoneStr) {
    phoneStr = phoneStr.toString().replaceFirst("00", "");
    phoneStr = phoneStr.toString().replaceFirst("+", "");
    var re = RegExp(r'\d{2}'); // replace two digits
    phoneStr = phoneStr.replaceFirst(re, '');
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'),(Match m) {
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

  String? _filterContacts(String? calledNum) {
    String searchTermFlatten = flattenPhoneNumber(calledNum ?? "");
    String? phnFlattened;
    String? numTest1;
    String? numTest2;
    String? result;

    if (contactsCallScreen.isNotEmpty) {
      for (var i = 0; i < contactsCallScreen.length; i++) {
        if (contactsCallScreen[i].phones.isNotEmpty) {
          if (contactsCallScreen[i].phones.elementAt(0).number.isNotEmpty) {
            numTest1 = contactsCallScreen[i].phones.elementAt(0).number;
            phnFlattened = flattenContactNumber(numTest1);
          } else if (contactsCallScreen[i].phones.length > 1) {
            numTest2 = contactsCallScreen[i].phones.elementAt(1).number;
            phnFlattened = flattenContactNumber(numTest2);
          }

          if (phnFlattened!.contains(searchTermFlatten)) {
            if(i!=0) {
              result = contactsCallScreen[i].displayName;
            }
            break;
          }
        }
      }
    }
    if (result == null) {
      return 'UNKNOWN';
    } else {
      return result;
    }
  }

//#################################################################################################################

  List<Widget> _buildNumPad() {
    var lables = [
      [
        {'1': ''},
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
        padding: const EdgeInsets.all(3),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row
                .map((label) => ActionButton(
              title: label.keys.first,
              subTitle: label.values.first,
              onPressed: () => _handleDtmf(label.keys.first),
              number: true,
            ))
                .toList())))
        .toList();
  }

  Widget _buildActionButtons() {
    var hangupBtn = ActionButton(
      title: "hangup",
      onPressed: () {
        _handleHangup();
      },
      icon: Icons.call_end,
      fillColor: Colors.red,
    );

    var hangupBtnInactive = ActionButton(
      title: "hangup",
      onPressed: () {},
      icon: Icons.call_end,
      fillColor: Colors.grey,
    );

    var basicActions = <Widget>[];
    var advanceActions = <Widget>[];

    switch (_state) {
      case CallStateEnum.NONE:
     _contactName = _filterContacts(remote_identity);
      if (direction == 'INCOMING') {
          InCallService().startRingTone(30);
        } else {
          InCallService().startRingBack();
        }
        continue ss;
      ss:
      case CallStateEnum.CONNECTING:
        _contactName = _filterContacts(remote_identity);
        if (direction == 'INCOMING') {
          basicActions.add(ActionButton(
            title: "Accept",
            fillColor: Colors.green,
            icon: Icons.phone,
            onPressed: () => _handleAccept(),
          ));
          basicActions.add(hangupBtn);
          ColorLoader();
        } else {
          basicActions.add(hangupBtn);
        }
        break;
      case CallStateEnum.ACCEPTED:
        _contactName = _filterContacts(remote_identity);
        break;
      case CallStateEnum.CONFIRMED:
        _contactName = _filterContacts(remote_identity);
        {
          advanceActions.add(ActionButton(
            title: _audioMuted ? 'unmute' : 'mute',
            icon: _audioMuted ? Icons.mic_off : Icons.mic,
            checked: _audioMuted,
            onPressed: () => _muteAudio(),
          ));

          if (voiceonly) {
            advanceActions.add(ActionButton(
              title: "keypad",
              icon: Icons.dialpad,
              onPressed: () => _handleKeyPad(),
            ));
          } else {
            advanceActions.add(ActionButton(
              title: "switch camera",
              icon: Icons.switch_video,
              onPressed: () => _switchCamera(),
            ));
          }

          if (voiceonly) {
            advanceActions.add(ActionButton(
              title: _speakerOn ? 'speaker off' : 'speaker on',
              icon: _speakerOn ? Icons.volume_off : Icons.volume_up,
              checked: _speakerOn,
              onPressed: () => _toggleSpeaker(),
            ));
          } else {
            advanceActions.add(ActionButton(
              title: _videoMuted ? "camera on" : 'camera off',
              icon: _videoMuted ? Icons.videocam : Icons.videocam_off,
              checked: _videoMuted,
              onPressed: () => _muteVideo(),
            ));
          }

          basicActions.add(ActionButton(
            title: _hold ? 'unhold' : 'hold',
            icon: _hold ? Icons.play_arrow : Icons.pause,
            checked: _hold,
            onPressed: () => _handleHold(),
          ));

          basicActions.add(hangupBtn);

          if (_showNumPad) {
            basicActions.add(ActionButton(
              title: "back",
              icon: Icons.keyboard_arrow_down,
              onPressed: () => _handleKeyPad(),
            ));
          } else {
            basicActions.add(ActionButton(
              title: "transfer",
              icon: Icons.phone_forwarded,
              onPressed: () => _handleTransfer(),
            ));
          }
        }
        // if (direction == 'INCOMING') {
        //   InCallService().stopRingTone();
        //   /*if (_toggledOnce == false) {
        //     setState(() {
        //       _speakerOn = true;
        //       _toggledOnce = true;
        //       _toggleSpeaker();
        //     });
        //   }*/
        // } else {
        //   InCallService().stopRingBack(false);
        //   if (_timerStarted == false) {
        //     _startTimer();
        //     _timerStarted = true;
        //   }
        // }
        // {
        //   advanceActions.add(ActionButton(
        //     title: _audioMuted ? 'unmute' : 'mute',
        //     icon: _audioMuted ? Icons.mic_off : Icons.mic,
        //     checked: _audioMuted,
        //     onPressed: () => _muteAudio(),
        //   ));
        //
        //   if (voiceonly) {
        //     advanceActions.add(ActionButton(
        //       title: "keypad",
        //       icon: Icons.dialpad,
        //       onPressed: () => _handleKeyPad(),
        //     ));
        //   }
        //   else {
        //     advanceActions.add(ActionButton(
        //       title: "switch camera",
        //       icon: Icons.switch_video,
        //       onPressed: () => _switchCamera(),
        //     ));
        //   }
        //
        //   advanceActions.add(ActionButton(
        //     title: _speakerOn ? 'speaker' : 'speaker',
        //     icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
        //     checked: _speakerOn,
        //     onPressed: () => _toggleSpeaker(),
        //   ));
        //
        //   basicActions.add(ActionButton(
        //     title: _hold ? 'unhold' : 'hold',
        //     icon: _hold ? Icons.play_arrow : Icons.pause,
        //     checked: _hold,
        //     onPressed: () => _handleHold(),
        //   ));
        //
        //   basicActions.add(hangupBtn);
        //
        //   if (_showNumPad) {
        //     basicActions.add(ActionButton(
        //       title: "back",
        //       icon: Icons.keyboard_arrow_down,
        //       onPressed: () => _handleKeyPad(),
        //     ));
        //   } else {
        //     basicActions.add( ActionButton(
        //       title: "transfer",
        //       icon: Icons.phone_forwarded,
        //       fillColor: Colors.grey,
        //       onPressed: () => _handleTransfer(),
        //     ));
        //   }
        // }
        break;
      case CallStateEnum.FAILED:
      case CallStateEnum.ENDED:
        basicActions.add(hangupBtnInactive);
        break;
      case CallStateEnum.PROGRESS:
        if (direction == 'INCOMING') {
          InCallService().stopRingTone();
          if (_toggledOnce == false) {
            setState(() {
              _speakerOn = true;
              _toggledOnce = true;
              _toggleSpeaker();
            });
          }
        } else {
          InCallService().stopRingBack(false);
        }

        _contactName = _filterContacts(remote_identity);

        advanceActions.add(ActionButton(
          title: _audioMuted ? 'unmute' : 'mute',
          icon: _audioMuted ? Icons.mic_off : Icons.mic,
          checked: _audioMuted,
          onPressed: () => _muteAudio(),
        ));
        if (voiceonly) {
          advanceActions.add(ActionButton(
            title: "keypad",
            icon: Icons.dialpad,
            onPressed: () => _handleKeyPad(),
          ));
        }
        else {
          advanceActions.add(ActionButton(
            title: "switch camera",
            icon: Icons.switch_video,
            onPressed: () => _switchCamera(),
          ));
        }

        advanceActions.add(ActionButton(
          title: _speakerOn ? 'speaker' : 'speaker',
          icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
          checked: _speakerOn,
          onPressed: () => _toggleSpeaker(),
        ));


        basicActions.add(ActionButton(
          title: _hold ? 'unhold' : 'hold',
          icon: _hold ? Icons.play_arrow : Icons.pause,
          checked: _hold,
          onPressed: () => _handleHold(),
        ));

        basicActions.add(hangupBtn);

        if (_showNumPad) {
          basicActions.add(ActionButton(
            title: "back",
            icon: Icons.keyboard_arrow_down,
            onPressed: () => _handleKeyPad(),
          ));
        } else {
          basicActions.add(const ActionButton(
            title: "transfer",
            icon: Icons.phone_forwarded,
            fillColor: Colors.grey,
          ));
        }
        break;
      default:
        print('Other state => $_state');
        break;
    }

    var actionWidgets = <Widget>[];

    if (_showNumPad) {
      actionWidgets.addAll(_buildNumPad());
    } else {
      if (advanceActions.isNotEmpty) {
        actionWidgets.add(Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: advanceActions)));
      }
    }

    actionWidgets.add(Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: basicActions)));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: actionWidgets);
  }

  Widget _buildContent() {
    var stackWidgets = <Widget>[];

    if (!voiceonly && _remoteStream != null) {
      stackWidgets.add(Center(
        child: RTCVideoView(_remoteRenderer!),
      ));
    }

    if (!voiceonly && _localStream != null) {
      stackWidgets.add(Container(
        alignment: Alignment.topRight,
        child: AnimatedContainer(
          height: _localVideoHeight,
          width: _localVideoWidth,
          alignment: Alignment.topRight,
          duration: const Duration(milliseconds: 300),
          margin: _localVideoMargin,
          child: RTCVideoView(_localRenderer!),
        ),
      ));
    }

    stackWidgets.addAll([
      SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: ColorLoader(),
        ),
      ),
      Positioned(
        top: voiceonly ? 48 : 6,
        left: 0,
        right: 0,
        child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          (voiceonly
                              ? (_contactName ?? 'VOICE CALL')
                              : 'VIDEO CALL') +
                              (_hold
                                  ? ' PAUSED BY ${_holdOriginator!.toUpperCase()}'
                                  : ''),
                          style:
                          const TextStyle(fontSize: 24, color: Colors.black54),
                        ))),
                Center(
                    child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          '00$remote_identity',
                          style:
                          const TextStyle(fontSize: 18, color: Colors.black54),
                        ))),
                Center(
                    child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(_timeLabel,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54)))),
              ],
            )),
      ),
    ]);

    return Stack(
      children: stackWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("direction ==> ${direction}");
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text("$direction")),
          flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[Colors.black, Colors.blue]))),
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          left: true,
          right: true,
          child: Container(
            child: _buildContent(),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 24.0),
            child: SizedBox(width: 320, child: _buildActionButtons())),
      ),
    );
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    //
  }

  @override
  void dispose() {
    _localStream?.dispose();
    super.dispose();
  }
  @override
  void onNewNotify(Notify ntf) {
    //
  }
}
