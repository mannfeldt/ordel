import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:ordel/models/user_model.dart';
import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/services/local_storage.dart';

class FirebaseClient {
  final FirebaseAnalyticsObserver _observer;
  User? _activeUser;

  List<DateTime> _callsTimeStamps = [];

  bool get isPossibleInfiniteLoop {
    _callsTimeStamps.add(DateTime.now());
    _callsTimeStamps = _callsTimeStamps
        .where((t) =>
            t.isAfter(DateTime.now().subtract(const Duration(seconds: 60))))
        .toList();
    print(
        "------------------${_callsTimeStamps.length} calls in last minute firebase---------------------");
    //kanske behöver göra exception för när vi kör mot eemulator/mock här. kan vi kolla på _firestore för att avgöra det?
    //om mock/emulator så tillåt ett högre antal?
    return _callsTimeStamps.length > 100;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final LocalStorage _localStorage;
  final String _fcmToken = "fail";

  String get fcmToken => _fcmToken;

  FirebaseClient(this._observer, this._localStorage);
  // CloudFunctions _functions = CloudFunctions.instance;
  // PushNotificationService _notificationService;

  User? get user => _activeUser;
  // String _fcmToken;

  // String get fcmToken => _fcmToken;

  // FieldValue.increment(value)
  // FieldValue.serverTimestamp()

  Future<void> init() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client init---------------------");
    // _firestore ??= FirebaseFirestore.instance;
    // _auth ??= auth.FirebaseAuth.instance;

    // _notificationService = PushNotificationService();
    // _notificationService.initialize();
    // _fcmToken = await _notificationService.token;
    _activeUser = User.generateUser(
        uid: _auth.currentUser?.uid,
        fcm: "fcm",
        image: _auth.currentUser?.photoURL);
  }

  Future<void> clear() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client auth.signout---------------------");
    _activeUser = null;
    await _auth.signOut();
  }

  Future<User> createUser() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client createUser---------------------");

    await _firestore.collection('users').doc(user!.uid).set(user!.toJson());

    return user!;
  }

  Future<void> updateUserProfile(
      User user, bool newName, bool newColor, bool newNotification) async {
    await _firestore.collection('users').doc(user.uid).update({
      User.DISPLAYNAME_FIELD: user.displayname,
      User.COLOR_FIELD: user.colorString,
      User.FCM_FIELD: user.fcm,
    });
    if (newName) {
      _observer.analytics.logEvent(name: "profile__update_profile_name");
    }
    if (newColor) {
      _observer.analytics.logEvent(name: "profile__update_profile_color");
    }

    // if (newNotification) {
    //   _observer.analytics.setUserProperty(
    //       name: "notifications", value: user.fcm == _fcmToken ? "on" : "off");
    // }
  }

  Future<List<User>> getFollowers() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client getFollowers---------------------");

//hur funkar detta när mna inte har några vänner?
    try {
      dynamic vv = await _firestore.collectionGroup('friends').get();
      QuerySnapshot? snapshot = await _firestore
          .collectionGroup('friends')
          .where('uid', isEqualTo: _activeUser!.uid)
          .get();

      // if (snapshot == null) return [];

      List<User> followers = [];
      for (DocumentSnapshot doc in snapshot.docs) {
        DocumentSnapshot follower = await doc.reference.parent.parent!.get();
        followers.add(User.fromJson(follower.data()));
      }

      return followers;
    } catch (e) {
      //TODO något problem med followers etc. vad är problemet??
      //TODO hur sätter vi groypcollection friends??
      print(e.toString());
      //varje hot refresh så
      return [];
      // throw e.toString();
    }
  }

  Future<User?> getUser() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client getUser---------------------");

    DocumentSnapshot doc =
        await _firestore.collection("users").doc(_activeUser!.uid).get();

    if (doc.exists) {
      User user = User.fromJson(doc.data());
      QuerySnapshot friendsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .get();
      if (friendsSnapshot.docs.isNotEmpty) {
        user.friendsUids = friendsSnapshot.docs.map((x) {
          dynamic data = x.data();
          return data['uid'].toString();
        }).toList();
      }

      return user;
    }
    return null;
  }

  Future<void> addFriend(User user, User newFriend) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client addFriend---------------------");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(newFriend.uid)
        .set({'uid': newFriend.uid});

//TODO pushnotis
    // if (newFriend.fcm != null && newFriend.fcm != "fail") {
    //   final HttpsCallable callable = _functions.getHttpsCallable(
    //     functionName: CloudFunctionName.NEW_FOLLOWER,
    //   );
    //   //callable.call();
    //   callable.call(<String, dynamic>{
    //     'userFcm': newFriend.fcm,
    //     'followerName': user.displayname,
    //     'followerUid': user.uid,
    //   }).catchError((e) {
    //     print(e.toString());
    //   });
    // }
    _observer.analytics.logEvent(name: "friends_add_friend");
  }

  Future<void> removeFriend(User user, String uid) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client removeFriend---------------------");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(uid)
        .delete();
    _observer.analytics.logEvent(name: "friends__delete_friend");
  }

  Future<List<User>> getUsers() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client getUsers---------------------");
    CollectionReference gamesCollection = _firestore.collection('users');

    QuerySnapshot snapshot = await gamesCollection.get();

    List<User> users =
        snapshot.docs.map((x) => User.fromJson(x.data())).toList();

    return users;
  }

  Future<List<GameRound>> getGames() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client getGames---------------------");
    CollectionReference gamesCollection = _firestore.collection('games');

    QuerySnapshot snapshot = await gamesCollection.get();

    List<GameRound> games =
        snapshot.docs.map((x) => GameRound.fromJson(x.data())).toList();

    return games;
  }

  Future<void> createGame(GameRound game) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client createGame---------------------");
    CollectionReference gamesCollection = _firestore.collection('games');

    await gamesCollection.add(game.toJson());
  }

  // Future<List<UserPrediction>> getUserPredictions() async {
  //   if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
  //   print(
  //       "------------------firebase_client getUserPredictions---------------------");
  //   CollectionReference predictionsCollection =
  //       _firestore.collection('predictions');

  //   Query hasAccess = predictionsCollection.where('uid', isEqualTo: _user.uid);

  //   List<QuerySnapshot> snapshots = await Future.wait([hasAccess.get()]);

  //   List<UserPrediction> predictions = [];

  //   for (QuerySnapshot snapshot in snapshots) {
  //     predictions
  //         .addAll(snapshot.docs.map((x) => UserPrediction.fromJson(x.data())));
  //   }
  //   return predictions;
  // }

  // Future<void> createUserPrediction(UserPrediction prediction) async {
  //   if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
  //   print(
  //       "------------------firebase_client createUserPrediction---------------------");

  //   prediction.uid ??= _user.uid;
  //   await _firestore
  //       .collection('predictions')
  //       .doc("${prediction.id}${_user.uid}")
  //       .set(prediction.toJson());
  //   // await _firestore.collection('predictions').add(prediction.toJson());
  // }
}
