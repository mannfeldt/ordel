// import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/services/cache_manager.dart';
import 'package:ordel/services/firebase_client.dart';
import 'package:ordel/services/local_storage.dart';

class UserProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  // ignore: unused_field
  final FirebaseAnalyticsObserver _observer;
  final CacheManager _cacheManager;

  List<User>? _users;
  List<User>? _followers;

  UserProvider(
      {required FirebaseClient client,
      required LocalStorage localStorage,
      required FirebaseAnalyticsObserver observer,
      required CacheManager cacheManager})
      : _client = client,
        _localStorage = localStorage,
        _observer = observer,
        _cacheManager = cacheManager;

  List<User>? get users => _users;
  List<User>? get followers => _followers;
  User? get activeUser => _client.user;
  bool get isLoggedIn => activeUser != null;
  bool get asdf => _client.user != null;

  Future<void> signOut() async {
    _localStorage.clearActiveUser();
    await _client.clear();

    // _client.signOut();

    notifyListeners();
  }

  // void setActiveUser(User? user) {
  //   //TODO här kommer vi in om det fanns användare sparat i minnet så vi loggas in direkt.
  //   //TODO men sätts _client.activeuser då? det är viktigt va?
  //   if (user != null) {
  //     _activeUser = user;
  //     _localStorage.storeActiveUser(user);
  //     _client.setActiveUser(user);
  //   }
  //   notifyListeners();
  // }

  Future<List<User>> getUsers() async {
    //TODO cacha båda dessa likt F1. med duration från remote config
    _users = await _cacheManager.getUsers();
    _followers = await _client.getFollowers();
    notifyListeners();
    return _users!;
  }

  Future<void> refreshUsers() async {
    //TODO cacha båda dessa likt F1. med duration från remote config
    _users = await _client.getUsers();
    _followers = await _client.getFollowers();
    notifyListeners();
  }

  User? getUserById(String uid) =>
      _users?.firstWhere((user) => user.uid == uid);

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
    await _localStorage.clearUsers();
    await _localStorage.clearAnonGames();
  }

  Future<void> updateProfile(
      String displayName, String color, bool notification) async {
    bool newName = displayName != activeUser!.displayname;
    bool newColor = color != activeUser!.colorString;
    bool newNotification = notification != hasActivePushNotifications;
    // bool newNotification = false;
    if (newName || newColor || newNotification) {
      User newUser = User(
          colorString: color,
          displayname: displayName,
          fcm: notification ? _client.fcmToken : "fail",
          image: activeUser!.image,
          uid: activeUser!.uid,
          username: activeUser!.username,
          friendsUids: activeUser!.friendsUids,
          isAnonymous: activeUser!.isAnonymous);
      // _activeUser!.colorString = color;
      // _activeUser!.displayname = displayName;
      // _activeUser!.fcm = notification ? _client.fcmToken : "fail";
      await _client.updateUserProfile(newUser, newName, newColor, notification);
      notifyListeners();
    }
  }

  Future<void> initUser() async {
    //TODO! direkt när man loggar in så blir man anonym? måste starta om appen?
//TODO problem med att nya användare inte skapas heller? körs inte alltid createUser??
//TODO eller den skapas men med annat displayname/kod...
// behöver helt enkelt debugga lite kring vad som händer här...
    await _client.init(null);
    // _activeUser = await _client.getUser();
    // _activeUser ??= await _client.createUser();
    _localStorage.storeActiveUser(activeUser!);
    notifyListeners();
  }

  bool get hasActivePushNotifications =>
      activeUser?.fcm != null && activeUser!.fcm == _client.fcmToken;

  Future<void> resetUsers() async {
    _users = null;
    _followers = null;

    notifyListeners();
  }
}
