// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
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
  String LAST_LOGGED_IN_VERSION = "last_login_version";

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
    await prefs.setString(LAST_LOGGED_IN_VERSION, info.version);
  }

  Future<String?> getLastLoggedInVersion() async {
    SharedPreferences prefs = await getPref();
    return prefs.getString(LAST_LOGGED_IN_VERSION);
  }

  Future<void> clearLastLoggedInVersion() async {
    SharedPreferences prefs = await getPref();
    await prefs.remove(LAST_LOGGED_IN_VERSION);
  }

  Future<void> init() async {
    String? lastLoggedInVersion = await getLastLoggedInVersion();
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (lastLoggedInVersion == null || lastLoggedInVersion != info.version) {
      //app has updated
      // clearActiveUser();
      clearLastLoggedInVersion();
    } else {
      // _activeUser = await getActiveUser();
    }
  }
}
