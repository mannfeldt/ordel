import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/utils/constants.dart';
import 'package:ordel/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  // ignore: unused_field
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          _serializeMessage(message, internal: false);
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null && !kIsWeb) {
          try {
            _serializeMessage(message, internal: true);
          } catch (e) {
            print(e.toString());
          }
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        try {
          _serializeMessage(message, internal: false);
        } catch (e) {
          print(e.toString());
        }
      });

      String token = await FirebaseMessaging.instance.getToken() ?? "fail";
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }

  void _handleExternalNotification(
      Map<String, dynamic> data, String pushFunction, BuildContext context) {
    switch (pushFunction) {
      case CloudFunctionName.NEXT_TURN:
        var gameId = data['game'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameUpdated(gameId);
        // AppRouter.navigateTo(context, AppRouter.pathForGame(gameId),
        //     replace: true);
        AppRouter.navigateTo(context, AppRouter.MULTIPLAYER_TAB, replace: true);

        break;
      case CloudFunctionName.GAME_INVITE:
        var gameId = data['game'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameUpdated(gameId);
        AppRouter.navigateTo(context, AppRouter.MULTIPLAYER_TAB, replace: true);
        break;
      case CloudFunctionName.ACCEPT_GAME_INVITE:
        var gameId = data['game'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameUpdated(gameId);
        AppRouter.navigateTo(context, AppRouter.MULTIPLAYER_TAB, replace: true);
        break;
      case CloudFunctionName.DECLINE_GAME_INVITE:
        var gameId = data['game'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameDeleted(gameId);
        AppRouter.navigateTo(context, AppRouter.MULTIPLAYER_TAB, replace: true);
        break;
      case CloudFunctionName.DECLINE_DELETE_GAME_INVITE:
        var gameId = data['game'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameDeleted(gameId);
        AppRouter.navigateTo(context, AppRouter.MULTIPLAYER_TAB, replace: true);
        break;
      case CloudFunctionName.NEW_FOLLOWER:
        var followerUid = data['follower'];
        Provider.of<UserProvider>(context, listen: false)
            .handleNewFollower(followerUid);
        AppRouter.navigateTo(context, AppRouter.FRIEND_TAB, replace: true);
        break;
      case CloudFunctionName.GAME_FINISHED:
        var gameId = data['game'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameUpdated(gameId);
        AppRouter.navigateTo(context, AppRouter.pathForGame(gameId),
            replace: true);
        break;
      default:
    }
  }

  void _handleInternalNotification(
      Map<dynamic, dynamic> data, String pushFunction, BuildContext context) {
    switch (pushFunction) {
      case CloudFunctionName.NEXT_TURN:
        var gameId = data['game'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameUpdated(gameId);
        // kan jag skippa att visa denna notis om jag redan ??r inne p?? /gameplay?
        // om gameid ??r en annan ??n gameProvider.activeGame s?? visa "din tur i annat game" etc

        //PROBLEM: kan inte lita p?? AppRouter.currentPath d?? den kan blir fel efter en pop()

// vi har ju 4 l??gen en spelare kan vara i typ.
//1:appen ??r inte aktiv, d?? f??r man en notis n??r det ??r ens tur.
//2:man ??r inne i appen men inte i n??got game, d?? f??r man en intern notis om att det ??r ens tur
//3:man ??r inne i ett annat game, d?? ska man f?? en intern notis om att det ??r ens tur
//4:man ??r inne i samma game och det blev nu enns tur (vanligt om man spelare in-person), beh??ver hantera att gameplayProvider.activeGame updateras....
// kan vi kolla om gameplayProvider.activeGame inte ??r null i pushNotificcations.dart och is??fall k??ra n??gon gameplayProvider.handleMyTurn...?
//alternativet f??r fall 4 ??r att vi har en lyssnare p?? gamet och players s?? vi f??r informationen om att det ??r ens tur d??rigenom ist??llet f??r via notis, s?? i det fallet beh??ver vi
//fortfarande g??ra en speciell hantering i pushnotifications att om gameplayProvider.activeGame finns och ??r samma game som notisen kom in med s?? g??r ingenting typ.
//fast det g??r ju inte s?? mycket. V??rsta fallet ??r att vi f??r en notis n??r det ??r ens tur fast man kanske redan vet om det f??r att man ??r inne i gamet, g??r ju inte s?? mycket.

        NotificationSnackbar.display(
          context,
          "It??s your turn to play!",
          title: "Hey!",
          // onNavigate: () => AppRouter.navigateTo(
          //     context, AppRouter.pathForGame(gameId),
          //     replace: true),
        );

        break;
      case CloudFunctionName.GAME_INVITE:
        var gameId = data['game'];
        var name = data['name'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameUpdated(gameId);

        NotificationSnackbar.display(context, "$name has invited you to a game",
            title: "Game invite");
        break;
      case CloudFunctionName.ACCEPT_GAME_INVITE:
        var gameId = data['game'];
        var name = data['name'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameUpdated(gameId);
        NotificationSnackbar.display(context, "$name accepted your game invite",
            title: "Invite accepted");
        break;
      case CloudFunctionName.DECLINE_GAME_INVITE:
        var gameId = data['game'];
        var name = data['name'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameDeleted(gameId);
        NotificationSnackbar.display(context, "$name declined your game invite",
            title: "Game invite declined");
        break;
      case CloudFunctionName.DECLINE_DELETE_GAME_INVITE:
        var gameId = data['game'];
        var name = data['name'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameDeleted(gameId);
        NotificationSnackbar.display(context,
            "$name declined your game invite. Game was removed as there is not enough players",
            title: "Game invite declined");
        break;
      case CloudFunctionName.NEW_FOLLOWER:
        var followerUid = data['follower'];
        var name = data['name'];
        Provider.of<UserProvider>(context, listen: false)
            .handleNewFollower(followerUid);
        NotificationSnackbar.display(
            context, "$name just added you as a friend",
            title: "Hey!");
        break;
      case CloudFunctionName.GAME_FINISHED:
        var gameId = data['game'];
        Provider.of<MultiplayerProvider>(context, listen: false)
            .handleGameUpdated(gameId);
        NotificationSnackbar.display(context, "Game has finished",
            title: "Well played!"
            // onNavigate: () => AppRouter.navigateTo(
            //     context, AppRouter.pathForGame(gameId),
            //     replace: true),
            );
        break;
      default:
    }
  }

  void _serializeMessage(RemoteMessage message, {bool internal = false}) {
    var notificationData = message.data;
    var pushFunc = notificationData['push_func'];
    if (pushFunc != null) {
      BuildContext? context = AppRouter.singleplayerScreenKey.currentContext ??
          AppRouter.friendScreenKey.currentContext ??
          AppRouter.multiplayerScreenKey.currentContext ??
          AppRouter.leaderboardScreenKey.currentContext;
      if (context == null) return;
      if (internal) {
        _handleInternalNotification(notificationData, pushFunc, context);
      } else {
        _handleExternalNotification(notificationData, pushFunc, context);
      }
    }
  }

  Future<String> getFcmToken() async {
    return await FirebaseMessaging.instance.getToken() ?? "fail";
  }
}
