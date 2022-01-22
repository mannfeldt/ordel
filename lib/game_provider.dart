import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

import 'package:ordel/firebase_client.dart';
import 'package:ordel/local_storage.dart';

class GameProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  final FirebaseAnalyticsObserver _observer;

  GameProvider(
      {required FirebaseClient client,
      required LocalStorage localStorage,
      required FirebaseAnalyticsObserver observer})
      : _client = client,
        _localStorage = localStorage,
        _observer = observer;

  initSession() async {
    _localStorage.storeLastLoggedInVersion();
    notifyListeners();
  }

  apiTest() async {}

  clearLocalStorage() async {
    _localStorage.clearLastLoggedInVersion();
  }
}
