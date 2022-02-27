import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:native_updater/native_updater.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';

class VersionChecker {
  static run(BuildContext context) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    String currentVersion = info.version;
    final RemoteConfig remoteConfig = RemoteConfig.instance;

    String minAppVersion = remoteConfig.getString("min_app_version");
    String minAppVersion2 = remoteConfig.getString("changelog");

    // NativeUpdater.displayUpdateAlert(
    //   context,
    //   forceUpdate: true,
    // );

    if (isNewerVersionNumber(minAppVersion, currentVersion)) {
      bool useCustomMessage = false;

      Map<String, dynamic> changelog =
          json.decode(remoteConfig.getString("changelog"));
      List<String> changelogVersions = changelog.keys
          .toList()
          .where((v) => isNewerVersionNumber(v, currentVersion))
          .toList();

      if (changelogVersions.isNotEmpty) {
        changelogVersions.sort((a, b) => isNewerVersionNumber(a, b) ? -1 : 1);

        useCustomMessage = true;
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text("New update required"),
                content: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: SvgPicture.asset('assets/img/new_version.svg'),
                      ),
                    ),
                    if (!useCustomMessage)
                      Text(
                          "You must update to the latest version of the app to continue."),
                    if (useCustomMessage)
                      SizedBox(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                          reverse: false,
                          shrinkWrap: true,
                          children: changelogVersions.map((v) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    v,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...changelog[v]
                                    .map(
                                      (x) => Text(
                                        "- $x",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    )
                                    .toList()
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text("Update now"),
                    onPressed: () => StoreRedirect.redirect(),
                  ),
                ],
              ),
            );
          });
    }
  }
}

bool isNewerVersionNumber(String v1, String v2) {
  try {
    final numbersA = v1.split(".").map((x) => int.parse(x)).toList();
    final numbersB = v2.split(".").map((x) => int.parse(x)).toList();
    if (numbersA.length < numbersB.length) {
      throw "missmatch version format";
    }
    if (numbersA.length > numbersB.length) {
      return true;
    }
    for (int i = 0; i < numbersA.length; i++) {
      int compareResult = numbersA[i] - numbersB[i];
      if (compareResult > 0) return true;
      if (compareResult < 0) return false;
    }
    return false;
  } catch (e) {
    return false;
  }
}
