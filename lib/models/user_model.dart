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

  User({
    required this.uid,
    required this.fcm,
    required this.username,
    required this.image,
    friendsUids,
    required this.displayname,
    required this.colorString,
    this.isAnonymous = false,
  }) : friendsUids = friendsUids ?? <String>[];

  User.empty({
    uid,
    fcm,
    username,
    image,
    friendsUids,
    displayname,
    colorString,
    this.isAnonymous = false,
  })  : friendsUids = friendsUids ?? <String>[],
        uid = uid ?? "",
        fcm = fcm ?? "",
        username = username ?? "",
        image = image ?? "",
        colorString = colorString ?? "",
        displayname = displayname ?? "";

  factory User.fromJson(dynamic json) {
    String uid = json[UID_FIELD];
    String fcm = json[FCM_FIELD];
    String username = json[USERNAME_FIELD];
    String? image = json[IMAGE_FIELD];
    String displayname = json[DISPLAYNAME_FIELD];
    String color = json[COLOR_FIELD];

    Map<String, dynamic>? friendsMap = json[FRIENDS_FIELD];

    User user = User(
      uid: uid,
      fcm: fcm,
      username: username,
      image: image,
      displayname: displayname,
      colorString: color,
    );
    if (friendsMap != null) {
      user.friendsUids = friendsMap.values.map((f) => f.toString()).toList();
    }
    return user;
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
}
