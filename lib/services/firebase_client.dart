// ignore_for_file: unused_field

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/services/local_storage.dart';
import 'package:ordel/services/notification_service.dart';
import 'package:ordel/utils/constants.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
  String _fcmToken = "fail";

  String get fcmToken => _fcmToken;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  FirebaseClient(this._observer, this._localStorage);
  late PushNotificationsManager _notificationService;

  User? get user => _activeUser;

  Future<void> init() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client init---------------------");
    // _firestore ??= FirebaseFirestore.instance;
    // _auth ??= auth.FirebaseAuth.instance;

    _notificationService = PushNotificationsManager();
    _notificationService.init();
    _fcmToken = await _notificationService.getFcmToken();
    _activeUser = User.generateUser(
        uid: _auth.currentUser?.uid,
        fcm: _fcmToken,
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

    if (newNotification) {
      _observer.analytics.setUserProperty(
          name: "notifications", value: user.fcm == _fcmToken ? "on" : "off");
    }
  }

  Future<List<User>> getFollowers() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client getFollowers---------------------");

    QuerySnapshot? snapshot = await _firestore
        .collectionGroup('friends')
        .where('uid', isEqualTo: _activeUser!.uid)
        .get();

    List<User> followers = [];
    for (DocumentSnapshot doc in snapshot.docs) {
      DocumentSnapshot follower = await doc.reference.parent.parent!.get();
      followers.add(User.fromJson(follower.data()));
    }

    return followers;
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

    if (newFriend.fcm != null && newFriend.fcm != "fail") {
      final HttpsCallable callable = _functions.httpsCallable(
        CloudFunctionName.NEW_FOLLOWER,
      );
      //callable.call();
      callable.call(<String, dynamic>{
        'userFcm': newFriend.fcm,
        'followerName': user.displayname,
        'followerUid': user.uid,
      }).catchError((e) {
        print(e.toString());
      });
    }
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

  Future<List<SingleplayerGameRound>> getSingleplayerGames() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client getGames---------------------");
    CollectionReference gamesCollection = _firestore.collection('games');

    QuerySnapshot snapshot = await gamesCollection.get();

    List<SingleplayerGameRound> games = snapshot.docs
        .map((x) => SingleplayerGameRound.fromJson(x.data()))
        .toList();

    return games;
  }

  Future<void> createGame(GameRound game) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client createGame---------------------");
    CollectionReference gamesCollection = _firestore.collection('games');

    await gamesCollection.add(game.toJson());
  }
  //!---------------------------------------------------------------------------------------------------------------------------

  //game lifecycle:
  //1 game skapas med en host och en lista med invitees med status inviting, host läggs till som player direkt
  //2. när en spelare acccepterar så läggs den till som player i gamet och tas bort från invitelistan
  //3. när en spelare declinar tas den bara bort från invitelistan utan att skapas som player
  //4. host kan starta gamet så länge det finns minst två spelare inkl en själv.
  //5. när det startas sätts stat om bara? host blir första spelaren ut då den är currentPlayer?
  //6. updates av game occh players sker under spelet

  Future<List<MultiplayerGame>> getMultiplayerGames() async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client getMultiplayerGames---------------------");

    CollectionReference gamesCollection =
        _firestore.collection('multiplayer_games');
    Query isInvited = gamesCollection.where(MultiplayerGame.INVITEES_FIELD,
        arrayContains: _activeUser!.uid);
    //Query isHost = gamesCollection.where(Game.HOST_FIELD, isEqualTo: _user.uid); om man är host finns man också i playing redan?
    Query isPlaying = gamesCollection.where(MultiplayerGame.PLAYER_UIDS_FIELD,
        arrayContains: _activeUser!.uid);

    List<QuerySnapshot> snapshots =
        await Future.wait([isInvited.get(), isPlaying.get()]);

    List<MultiplayerGame> games = [];

    for (QuerySnapshot snapshot in snapshots) {
      games
          .addAll(snapshot.docs.map((x) => MultiplayerGame.fromJson(x.data())));
    }

    return games;
  }

  Future<MultiplayerGame?> getMultiplayerGame(String gameId) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client getMultiplayerGame---------------------");

    DocumentSnapshot snapshot =
        await _firestore.collection('multiplayer_games').doc(gameId).get();

    if (!snapshot.exists) return null;
    return MultiplayerGame.fromJson(snapshot.data());
  }

  StreamSubscription<DocumentSnapshot> subscribeToGame(
      String gameId, Function callback) {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client subscribeToGame---------------------");

    return _firestore
        .collection('multiplayer_games')
        .doc(gameId)
        .snapshots()
        .listen((snapshot) {
      if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
      print("----------firebase_client subscribeToGame snapshot-----------");
      MultiplayerGame game = MultiplayerGame.fromJson(snapshot.data());

      callback(game);
    }, onError: (e) {
      print("ERROR---------subscribeToGame----------------");
    });
  }

  Future<MultiplayerGame> createMultiplayerGame(
      MultiplayerGame game, List<User> invitedUsers, User hostUser) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client createMultiplayerGame---------------------");

    DocumentReference ref = await _firestore.collection('games').add({});

    game.id = ref.id;

    _firestore.collection('multiplayer_games').doc(game.id).set(game.toJson());

    for (User invitee in invitedUsers) {
      if (invitee.fcm != "fail") {
        final HttpsCallable callable =
            _functions.httpsCallable(CloudFunctionName.GAME_INVITE);
        callable.call(<String, dynamic>{
          'invited_fcm': invitee.fcm,
          'host_name': hostUser.displayname,
          'game_id': game.id,
        });
      }
    }

    _observer.analytics.logEvent(name: "play__create_game", parameters: {
      "players": invitedUsers.length,
    });

    return game;
  }

  Future<MultiplayerGame> acceptGameInvite(
      MultiplayerGame game, User user, User? host) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client acceptGameInvite---------------------");

    await _firestore.collection('multiplayer_games').doc(game.id).update({
      MultiplayerGame.INVITEES_FIELD: FieldValue.arrayRemove([user.uid]),
      MultiplayerGame.PLAYER_UIDS_FIELD: FieldValue.arrayUnion([user.uid])
    });
    //vi vet ju hela värdet så skulle kunna köra en hårt set till game. game.invitees game.playerUids etc. om det är effektivare?

    //ska vi updatera själva gamet här? eller i providern kanske?
    game.invitees.remove(user.uid);
    game.playerUids.add(user.uid);

    final HttpsCallable callable =
        _functions.httpsCallable(CloudFunctionName.ACCEPT_GAME_INVITE);
    if (host?.fcm != null && host?.fcm != "fail") {
      callable.call(<String, dynamic>{
        'accepted_name': user.displayname,
        'host_fcm': host!.fcm,
        'host_uid': game.host,
        'game_player_count': game.playerUids.length,
        'game_unanswered_count': game.invitees.length,
        'game_id': game.id,
        //kolla i funktionen om host_fcm finns, annars behöver vi hämta det från users med hjälp av host_uid
      });
    }
    _observer.analytics.logEvent(name: "play__accept_game_invite");
    return game;
  }

  Future<void> declineGameInvite(
      MultiplayerGame game, User user, User? host) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client declineGameInvite---------------------");

    game.invitees.remove(user.uid);
    if (!game.hasUnansweredInvites && game.playerUids.length < 2) {
      await _firestore.collection('multiplayer_games').doc(game.id).delete();

      if (host?.fcm != null && host?.fcm != "fail") {
        final HttpsCallable callable = _functions
            .httpsCallable(CloudFunctionName.DECLINE_DELETE_GAME_INVITE);
        callable.call(<String, dynamic>{
          'declined_name': user.displayname,
          'host_fcm': host!.fcm,
          'host_uid': game.host,
          'game_id': game.id,
        });
      }
      _observer.analytics
          .logEvent(name: "play__decline_game_invite_delete_game");
    } else {
      await _firestore.collection('multiplayer_games').doc(game.id).update({
        MultiplayerGame.INVITEES_FIELD: FieldValue.arrayRemove([user.uid])
      });
      final HttpsCallable callable =
          _functions.httpsCallable(CloudFunctionName.DECLINE_GAME_INVITE);
      callable.call(<String, dynamic>{
        'declined_name': user.displayname,
        if (host != null) 'host_fcm': host.fcm,
        if (host == null) 'host_uid': game.host,
        'game_player_count': game.playerUids.length,
        'game_unanswered_count': game.invitees.length,
        'game_id': game.id,
      });
      _observer.analytics.logEvent(name: "play__decline_game_invite");
    }
  }

  Future<MultiplayerGame> startGame(MultiplayerGame game) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client startGame---------------------");

    Map<String, dynamic> gameJson = game.toJson();

    await _firestore.collection('multiplayer_games').doc(game.id).update({
      MultiplayerGame.CURRENT_PLAYER_FIELD:
          gameJson[MultiplayerGame.CURRENT_PLAYER_FIELD],
      MultiplayerGame.INVITEES_FIELD: FieldValue.delete(),
      MultiplayerGame.STATE_FIELD: gameJson[MultiplayerGame.STATE_FIELD],
      MultiplayerGame.ROUNDS_FIELD: gameJson[MultiplayerGame.ROUNDS_FIELD],
    });
    // testa att start game funkar bättre nu. och att bara host kans starta. och att den startas rätt både i firebase och i _games
    _observer.analytics.logEvent(name: "play__start_game", parameters: {
      "players": game.playerUids.length,
      "skiped_players": game.invitees.length,
    });
    return game;
  }

  Future<void> deleteGame(MultiplayerGame game) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client deleteGame---------------------");

    await _firestore.collection('multiplayer_games').doc(game.id).delete();
    _observer.analytics.logEvent(
      name: "play__delete_game_${GAME_STATE_NAMES[game.state]}",
    );
  }

  Future<void> updateGame(MultiplayerGame game) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print("------------------firebase_client updateGame---------------------");
    await _firestore
        .collection('multiplayer_games')
        .doc(game.id)
        .update(game.toJson());

    //används alla gånger något ändras i gamet,
    //ny currentplayer
    //hosten startar gamet
    //spelet är klart
    //m.m
    //separat metod för att updatera enn player i ett game
  }

  Future<void> notifyGameHasEnded(
      List<User> users, MultiplayerGame game) async {
    if (isPossibleInfiniteLoop) throw "POSSIBLE INFINITE LOOP";
    print(
        "------------------firebase_client notifyGameHasEnded---------------------");

    for (User user in users) {
      if (user.fcm != null && user.fcm != "fail") {
        final HttpsCallable callable =
            _functions.httpsCallable(CloudFunctionName.GAME_FINISHED);
        callable.call(<String, dynamic>{
          'target': user.fcm,
          'game_id': game.id,
          //vill jag ha någon info om vilket game eller placering? just nu bvara genereisk push och ett id som gör att man kan navigeras dit precis som vid "Min tur"
        });
      }
    }
  }
}
