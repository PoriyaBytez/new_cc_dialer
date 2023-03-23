import 'package:flutter/material.dart';
import 'dart:async';

import 'package:new_cc_dialer/utils/settings.dart';

class AuthService with ChangeNotifier {
  var currentUser;
  var testme;

  Future getUser() {
    return Future.value(sipUsername);
  }

  // wrappinhg the firebase calls
  Future logout() {
    sipUsername = null;
    notifyListeners();
    return Future.value(currentUser);
  }

  // wrapping the firebase calls
  Future createUser(
      {String? cName,
      String? cCode,
      String? number,
      String? fullname,
      String? email}) async {}

  // logs in the user if password matches
  Future loginUser(String action) {
    if (action == 'procced') {
      sipUsername = sipUsername;
      notifyListeners();
      return Future.value(sipUsername);
    } else {
      return Future.value(null);
    }
  }
}
