import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/screens/friends/friends_load_controller.dart';
import 'package:ordel/screens/friends/profile_page.dart';
import 'package:ordel/screens/friends/widgets/friend_list.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/loader.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: AppRouter.friendScreenKey,
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.activeUser!.isAnonymous) {
            return Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "You must be a registered user to access friends",
                          style: TextStyle(color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: TextButton(
                            child: const Text(
                              "Register or Login now",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              await userProvider.signOut();
                              AppRouter.navigateTo(
                                context,
                                "/",
                                clearStack: true,
                                transition: TransitionType.fadeIn,
                                transitionDuration: Duration(milliseconds: 50),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }
          return Loader(
            controller: FriendsLoadController(userProvider),
            empty: ProfilePage(userProvider: userProvider),
            result: FriendList(userProvider: userProvider),
          );
        },
      ),
    );
  }
}
