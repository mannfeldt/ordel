// import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:ordel/firebase_client.dart';
import 'package:ordel/local_storage.dart';
import 'package:ordel/models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  final FirebaseAnalyticsObserver _observer;
  List<User>? _users;
  List<User>? _followers;
  User? _activeUser;

  UserProvider(
      {required FirebaseClient client,
      required LocalStorage localStorage,
      required FirebaseAnalyticsObserver observer})
      : _client = client,
        _localStorage = localStorage,
        _observer = observer;

  List<User>? get users => _users;
  List<User>? get followers => _followers;
  User? get activeUser => _activeUser;
  bool get isLoggedIn => _activeUser != null;
  bool get asdf => _client.user != null;

  Future<void> signOut() async {
    _activeUser = null;
    _localStorage.clearActiveUser();
    await _client.clear();

    // _client.signOut();

    notifyListeners();
  }

  void setActiveUser(User? user) {
    if (user != null) {
      _activeUser = user;
      _localStorage.storeActiveUser(user);
    }
    notifyListeners();
  }

  Future<List<User>> getUsers() async {
    _users = await _client.getUsers();
    _followers = await _client.getFollowers();
    notifyListeners();
    return _users!;
  }

  void handleNewFollower(String userUid) async {
    //if null then getUsers will run instead and get followers anyway
    if (_followers == null || _users == null) return;

    User follower = _users!.firstWhere(
        (u) => u.uid == userUid && userUid != activeUser!.uid,
        orElse: () => User.empty(uid: "-1"));
    if (follower.uid != "-1") {
      _followers!.add(follower);
      notifyListeners();
    }
  }

  Future<void> addFriend(User user) async {
    await _client.addFriend(activeUser!, user);
    activeUser!.friendsUids.add(user.uid);
    _localStorage.storeActiveUser(activeUser!);
    notifyListeners();
  }

  Future<void> removeFriend(User user) async {
    await _client.removeFriend(activeUser!, user.uid);
    activeUser!.friendsUids.remove(user.uid);
    _localStorage.storeActiveUser(activeUser!);
    notifyListeners();
  }

  Future<void> clearLocalStorage() async {
    await _localStorage.clearActiveUser();
    await _localStorage.clearLastLoggedInVersion();
  }

  Future<void> updateProfile(
      String displayName, String color, String piece, bool notification) async {
    bool newName = displayName != _activeUser!.displayname;
    bool newColor = color != _activeUser!.colorString;
    // bool newNotification = notification != hasActivePushNotifications;
    bool newNotification = false;
    if (newName || newColor || newNotification) {
      _activeUser!.colorString = color;
      _activeUser!.displayname = displayName;
      _activeUser!.fcm = notification ? _client.fcmToken : "fail";
      await _client.updateUserProfile(
          _activeUser!, newName, newColor, notification);
      notifyListeners();
    }
  }

  Future<void> initUser() async {
    _activeUser = await _client.getUser();
    _activeUser ??= await _client.createUser();
    _localStorage.storeActiveUser(_activeUser!);
    print(_activeUser!.uid);
    notifyListeners();
  }

  // bool get hasActivePushNotifications => _activeUser.fcm == _client.fcmToken;

  Future<void> resetUsers() async {
    _users = null;
    _followers = null;

    notifyListeners();
  }
}
