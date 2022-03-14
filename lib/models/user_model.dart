import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ordel/utils/colors_helper.dart';
import 'package:ordel/utils/constants.dart';

class User {
  late String uid;
  String? fcm;
  final String username;
  String displayname;
  String colorString;
  final String? image;
  List<String> friendsUids;
  final bool isAnonymous;
  int topStreak;

  User({
    required this.uid,
    required this.fcm,
    required this.username,
    required this.image,
    friendsUids,
    required this.displayname,
    required this.colorString,
    this.isAnonymous = false,
    this.topStreak = 0,
  }) : friendsUids = friendsUids ?? <String>[];

  User.empty({
    uid,
    fcm,
    username,
    image,
    friendsUids,
    displayname,
    colorString,
    topStreak,
    this.isAnonymous = false,
  })  : friendsUids = friendsUids ?? <String>[],
        uid = uid ?? "",
        fcm = fcm ?? "",
        username = username ?? "",
        image = image ?? "",
        colorString = colorString ?? "",
        topStreak = topStreak ?? 0,
        displayname = displayname ?? "";

  factory User.fromJson(dynamic json) {
    try {
      String uid = json[UID_FIELD];
      String fcm = json[FCM_FIELD];
      String username = json[USERNAME_FIELD];
      String? image = json[IMAGE_FIELD];
      String displayname = json[DISPLAYNAME_FIELD];
      String color = json[COLOR_FIELD];
      bool isAnon = json["anon"] != null;
      int topStreak = json[STREAK_FIELD] ?? 0;

      Map<String, dynamic>? friendsMap = json[FRIENDS_FIELD];

      User user = User(
        uid: uid,
        fcm: fcm,
        username: username,
        image: image,
        displayname: displayname,
        colorString: color,
        isAnonymous: isAnon,
        topStreak: topStreak,
      );
      if (friendsMap != null) {
        user.friendsUids = friendsMap.values.map((f) => f.toString()).toList();
      }
      return user;
    } catch (e) {
      return User.empty();
    }
  }

  factory User.generateUser(
      {String? uid,
      required String fcm,
      String? image,
      bool isAnonymous = false}) {
    int number = Random().nextInt(9000) + 1000;
    String username =
        Constants.ADJECTIVE[Random().nextInt(Constants.ADJECTIVE.length)] +
            Constants.NOUNS[Random().nextInt(Constants.NOUNS.length)] +
            "#$number";

    return User(
      fcm: fcm,
      uid: uid ?? UniqueKey().toString(),
      username: username,
      image: image,
      displayname: username.split("#").first,
      colorString: ColorHelpers.toHexString(
          Colors.primaries[Random().nextInt(Colors.primaries.length - 1)]),
      isAnonymous: isAnonymous,
      topStreak: 0,
    );
  }

  int get colorInt => ColorHelpers.fromHexString(colorString);

  Map<String, dynamic> toJson() {
    return {
      UID_FIELD: uid,
      FCM_FIELD: fcm,
      USERNAME_FIELD: username,
      DISPLAYNAME_FIELD: displayname,
      COLOR_FIELD: colorString,
      if (image != null) IMAGE_FIELD: image,
      if (isAnonymous) "anon": true,
      STREAK_FIELD: topStreak,
    };
  }

  Map<String, dynamic> toJsonWithFriends() {
    return {
      UID_FIELD: uid,
      FCM_FIELD: fcm,
      USERNAME_FIELD: username,
      DISPLAYNAME_FIELD: displayname,
      COLOR_FIELD: colorString,
      if (image != null) IMAGE_FIELD: image,
      FRIENDS_FIELD: friendsUids,
      STREAK_FIELD: topStreak,
    };
  }

  static const String UID_FIELD = 'uid';
  static const String FCM_FIELD = 'fcm';
  static const String USERNAME_FIELD = 'username';
  static const String DISPLAYNAME_FIELD = 'displayname';
  static const String COLOR_FIELD = 'color';
  static const String PIECE_FIELD = 'piece';
  static const String IMAGE_FIELD = 'img';
  static const String FRIENDS_FIELD = 'friends';
  static const String STREAK_FIELD = 'streak';
}
