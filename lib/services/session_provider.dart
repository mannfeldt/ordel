import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:ordel/models/language_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/services/firebase_client.dart';
import 'package:ordel/services/local_storage.dart';

class SessionProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  final FirebaseAnalyticsObserver _observer;
  String? _projectId;
  String? _languageCode;

  String? get languageCode => _languageCode;

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

  void setLanguage(Language? language) {
    if (language != null) {
      _languageCode = language.code;
      _localStorage.storeLanguage(_languageCode!);

      notifyListeners();
    }
  }

  initSession(String projectId, String? language) async {
    await _client.init();
    _localStorage.storeLastLoggedInVersion();

    _projectId = projectId;
    _languageCode = language;

    notifyListeners();
  }

  clearLocalStorage() async {
    _localStorage.clearLastLoggedInVersion();
  }
}
