import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> friendScreenKey = GlobalKey(
    debugLabel: "Friend Screen",
  );
  static final GlobalKey<NavigatorState> singleplayerScreenKey = GlobalKey(
    debugLabel: "Singleplayer Screen",
  );
  static final GlobalKey<NavigatorState> multiplayerScreenKey = GlobalKey(
    debugLabel: "Multiplayer Screen",
  );
  static final GlobalKey<NavigatorState> leaderboardScreenKey = GlobalKey(
    debugLabel: "Leaderboard Screen",
  );

  static const FRIEND_TAB = "/friend_tab";
  static const SINGLEPLAYER_TAB = "/singleplayer_tab";
  static const LEADERBOARD_TAB = "/leaderboard_tab";
  static const MULTIPLAYER_TAB = "/multiplayer_tab";
  static const GAMEPLAY_SCREEN = "/gameplay";
  static const SETUP_LANGUAGE_SCREEN = "/new_game_language";
  static const SETUP_INVITE_SCREEN = "/new_game_invite";
  static const SETUP_WORD_SCREEN = "/new_game_word";
  static const PROFILE_SCREEN = "/profile";

  static const List<String> TAB_PATHS = [
    SINGLEPLAYER_TAB,
    MULTIPLAYER_TAB,
    FRIEND_TAB,
    LEADERBOARD_TAB,
  ];

  static String currentPath = "/";

  static Future navigateTo(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      TransitionType? transition,
      Duration transitionDuration = const Duration(milliseconds: 250),
      RouteTransitionsBuilder? transitionBuilder}) {
    currentPath = path;
    return router!.navigateTo(context, path,
        clearStack: clearStack,
        transition: transition,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder);
  }

  static bool pathEquals(String path) {
    return currentPath == path;
  }

  static bool pathStartsWith(String path) {
    return currentPath.startsWith(path);
  }

  static String pathForGame(String gameId) {
    return "${AppRouter.GAMEPLAY_SCREEN}?gameid=$gameId";
  }

  static handleTabNavigation(int index) {
    currentPath = TAB_PATHS[index];
  }

  static FluroRouter? router;
}
