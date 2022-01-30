// ignore_for_file: avoid_print

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ordel/main.dart';
import 'package:ordel/main_pages.dart';
import 'package:ordel/navigation/app_router.dart';

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
      return MainPages(initialPageIndex: 3);
    }));
  }
}
