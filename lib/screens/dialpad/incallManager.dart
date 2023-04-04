import 'dart:async';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:io';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

class InCallService {

  void startRingTone(int _timeout) {
    KeepScreenOn.turnOn(true);
    if (Platform.isAndroid) {
      KeepScreenOn.turnOn();
    }
    FlutterRingtonePlayer.playRingtone();
  }

  Future<void> stopRingTone()  async {
    FlutterRingtonePlayer.stop();
  }

  void stopRingBack(bool _busy) {

    if (_busy) {
      KeepScreenOn.turnOn(false);
      if (Platform.isAndroid) {
        KeepScreenOn.turnOff();
      }
    } else {
      FlutterRingtonePlayer.stop();
    }
  }

  void proximity(bool status){
      if (Platform.isAndroid) {
        KeepScreenOn.turnOn(status);
        ProximityScreenLock.setActive(status);
      }
  }

  void startRingBack() {
    KeepScreenOn.turnOn(true);
    if (Platform.isAndroid) {
      KeepScreenOn.turnOn();
    }
     // incallManager.startRingback();
    // FlutterRingtonePlayer.play(fromAsset: "lib/assets/images/phone_tone.mp3");
    // incallManager.start(
    // media: MediaType.AUDIO, auto: true, ringback: '_BUNDLE_');
  }


  void resetInCall() {
    KeepScreenOn.turnOn(false);
    if (Platform.isAndroid) {
      KeepScreenOn.turnOff();
      ProximityScreenLock.setActive(false);
    }
  }
}
