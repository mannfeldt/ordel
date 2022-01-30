import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:ordel/firebase_client.dart';
import 'package:ordel/local_storage.dart';

import 'models/user_model.dart';

class SessionProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  final FirebaseAnalyticsObserver _observer;
  String? _projectId;

  bool get isProd => _projectId == null || _projectId == "ordel-prod";

  User? get currentUser => _client.user;

  SessionProvider(
      {required FirebaseClient client,
      required LocalStorage localStorage,
      required FirebaseAnalyticsObserver observer})
      : _client = client,
        _localStorage = localStorage,
        _observer = observer;

  logOut() async {
    await auth.FirebaseAuth.instance.signOut();
  }

  initSession(String projectId) async {
    await _client.init();
    _localStorage.storeLastLoggedInVersion();

    _projectId = projectId;

    notifyListeners();
  }

  clearLocalStorage() async {
    _localStorage.clearLastLoggedInVersion();
  }
}
