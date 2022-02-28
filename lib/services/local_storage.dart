import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/utils/constants.dart';
import 'package:ordel/models/user_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedValue<T> {
  Timestamp timestamp;
  T value;

  CachedValue(this.timestamp, this.value);
}

mixin T {}

class LocalStorage {
  List<DateTime> _callsTimeStamps = [];

  User? _activeUser;
  String? _languageCode;
  List<SingleplayerGameRound> _anonGames = [];

  User? get activeUser => _activeUser;
  String? get languageCode => _languageCode;
  List<SingleplayerGameRound>? get anonGames => _anonGames;

  bool get isPossibleInfiniteLoop {
    _callsTimeStamps.add(DateTime.now());
    _callsTimeStamps = _callsTimeStamps
        .where((t) =>
            t.isAfter(DateTime.now().subtract(const Duration(seconds: 30))))
        .toList();

    return _callsTimeStamps.length > 100;
  }

  Future<SharedPreferences> getPref() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    return await SharedPreferences.getInstance();
  }

  Future<void> storeLastLoggedInVersion() async {
    SharedPreferences prefs = await getPref();
    final PackageInfo info = await PackageInfo.fromPlatform();
    await prefs.setString(
        LocalStorageKeys.LAST_LOGGED_IN_VERSION, info.version);
  }

  Future<String?> getLastLoggedInVersion() async {
    SharedPreferences prefs = await getPref();
    return prefs.getString(LocalStorageKeys.LAST_LOGGED_IN_VERSION);
  }

  Future<void> clearLastLoggedInVersion() async {
    SharedPreferences prefs = await getPref();
    await prefs.remove(LocalStorageKeys.LAST_LOGGED_IN_VERSION);
  }

  Future<void> storeActiveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        LocalStorageKeys.ACTIVE_USER, json.encode(user.toJson()));
    await prefs.setStringList(
        LocalStorageKeys.ACTIVE_USER_FRIENDS, user.friendsUids);
    _activeUser = user;
  }

  Future<User?> getActiveUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPref = prefs.getString(LocalStorageKeys.ACTIVE_USER);
    if (userPref == null) return null;
    List<String>? friends =
        prefs.getStringList(LocalStorageKeys.ACTIVE_USER_FRIENDS);
    User user = User.fromJson(json.decode(userPref));
    if (friends != null) {
      user.friendsUids = friends;
    }
    _activeUser = user;
    return _activeUser;
  }

  Future<void> clearActiveUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalStorageKeys.ACTIVE_USER);
    await prefs.remove(LocalStorageKeys.ACTIVE_USER_FRIENDS);
    _activeUser = null;
  }

  Future<void> storeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(LocalStorageKeys.LANGUAGE, languageCode);
    _languageCode = languageCode;
  }

  Future<String?> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languagePref = prefs.getString(LocalStorageKeys.LANGUAGE);
    if (languagePref == null) return null;
    String? lang = prefs.getString(LocalStorageKeys.LANGUAGE);
    _languageCode = lang;
    return _languageCode;
  }

  Future<void> clearLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalStorageKeys.LANGUAGE);
    _languageCode = null;
  }

  Future<void> clearUsers() async {
    SharedPreferences prefs = await getPref();

    await prefs.remove(LocalStorageKeys.USERS);
  }

  Future<void> storeUsers(List<User> users) async {
    SharedPreferences prefs = await getPref();
    await prefs.setString(
        LocalStorageKeys.USERS,
        json.encode({
          "timestamp": Timestamp.now().millisecondsSinceEpoch,
          "value": users.map((u) => u.toJson()).toList(),
        }));
  }

  Future<CachedValue<List<User>>?> getUsers() async {
    SharedPreferences prefs = await getPref();
    String? s = prefs.getString(LocalStorageKeys.USERS);
    if (s == null) return null;
    dynamic jsonData = json.decode(s);
    int timestamp = jsonData['timestamp'];
    List<dynamic> schedule =
        jsonData['value'].map((u) => User.fromJson(u)).toList();

    CachedValue<List<User>> cachedValue = CachedValue(
        Timestamp.fromMillisecondsSinceEpoch(timestamp),
        schedule.cast<User>().toList());
    return cachedValue;
  }

  Future<void> storeAnonGame(SingleplayerGameRound game) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _anonGames.add(game);
    await prefs.setString(LocalStorageKeys.ANON_GAMES,
        json.encode(_anonGames.map((g) => g.toJson()).toList()));
    _languageCode = languageCode;
  }

  Future<List<SingleplayerGameRound>> getAnonGames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? anonGamesPref = prefs.getString(LocalStorageKeys.ANON_GAMES);
    if (anonGamesPref == null) return [];
    List<dynamic> anonGamesData = json.decode(anonGamesPref);
    _anonGames = anonGamesData
        .map((d) => SingleplayerGameRound.fromJson(anonGamesData))
        .toList();
    return _anonGames;
  }

  Future<void> clearAnonGames() async {
    SharedPreferences prefs = await getPref();

    await prefs.remove(LocalStorageKeys.ANON_GAMES);
  }

  Future<void> init() async {
    String? lastLoggedInVersion = await getLastLoggedInVersion();
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (lastLoggedInVersion == null || lastLoggedInVersion != info.version) {
      //app has updated
      clearActiveUser();
      clearLastLoggedInVersion();
      clearLanguage();
    } else {
      _activeUser = await getActiveUser();
      _languageCode = await getLanguage();
    }
    _anonGames = await getAnonGames();
  }
}
