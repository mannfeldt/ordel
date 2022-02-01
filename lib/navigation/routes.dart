// ignore_for_file: avoid_print

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ordel/main.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/screens/friends/profile_page.dart';
import 'package:ordel/screens/leaderboards/leaderboards_index.dart';
import 'package:ordel/screens/multiplayer/multiplayer_gameplay.dart';
import 'package:ordel/screens/multiplayer/widgets/setup_invite.dart';
import 'package:ordel/screens/multiplayer/widgets/setup_language.dart';
import 'package:ordel/screens/multiplayer/widgets/setup_word.dart';
import 'package:ordel/widgets/main_pages.dart';

class Routes {
  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define("/", handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const AppRoot();
    }));
    router.define(AppRouter.SINGLEPLAYER_TAB, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return MainPages(initialPageIndex: 0);
    }));
    router.define(AppRouter.MULTIPLAYER_TAB, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return MainPages(initialPageIndex: 1);
    }));
    router.define(AppRouter.FRIEND_TAB, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return MainPages(initialPageIndex: 2);
    }));
    router.define(AppRouter.LEADERBOARD_TAB, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return LeaderboardScreen();
    }));
    router.define(AppRouter.SETUP_LANGUAGE_SCREEN, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return SetupLanguageScreen();
    }));
    router.define(AppRouter.SETUP_INVITE_SCREEN, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      String language = params['language']?.first ?? "en";
      return SetupInviteScreen(language: language);
    }));
    router.define(AppRouter.SETUP_WORD_SCREEN, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      String language = params['language']!.first;
      String invite = params['invite']!.first;

      return SetupWordScreen(language: language, invite: invite);
    }));
    router.define(AppRouter.PROFILE_SCREEN, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return ProfilePageScreen();
    }));
    router.define(AppRouter.GAMEPLAY_SCREEN, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      String gameId = params['gameid']!.first;

      return MultiplayerGameplayScreen(gameId: gameId);
    }));
  }
}
