import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ordel/constants.dart';
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

  User? get activeUser => _activeUser;

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

  Future<void> init() async {
    String? lastLoggedInVersion = await getLastLoggedInVersion();
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (lastLoggedInVersion == null || lastLoggedInVersion != info.version) {
      //app has updated
      clearActiveUser();
      clearLastLoggedInVersion();
    } else {
      _activeUser = await getActiveUser();
    }
  }
}
