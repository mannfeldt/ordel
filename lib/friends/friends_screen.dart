import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ordel/friends/friends_load_controller.dart';
import 'package:ordel/friends/widgets/friend_list.dart';
import 'package:ordel/loader.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/user_provider.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({Key? key}) : super(key: key);
// HÄÄÄÄR lägg till userporvider till Provider.dart
//TODO få till tabbar och navigering ny routing hela friend hrejen. sen börjar jag debuga att det faktiskt fungerar.
//TODO spelet fungerar och lägga till vänner fungerar fortfarande..
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: AppRouter.friendScreenKey,
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) => Loader(
          controller: FriendsLoadController(userProvider),
          result: FriendList(userProvider: userProvider),
        ),
      ),
    );
  }
}
