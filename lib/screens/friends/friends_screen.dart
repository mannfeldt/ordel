import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        builder: (context, userProvider, child) => Loader(
          controller: FriendsLoadController(userProvider),
          // empty: ProfilePage(userProvider: userProvider),
          result: FriendList(userProvider: userProvider),
        ),
      ),
    );
  }
}
