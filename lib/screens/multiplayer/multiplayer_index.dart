import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/screens/multiplayer/multiplayer_load_controller.dart';
import 'package:ordel/screens/multiplayer/widgets/game_list.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/loader.dart';
import 'package:provider/provider.dart';

class MultiplayerScreen extends StatelessWidget {
  const MultiplayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //börja enkelt med bara en game list och en knapp för att skapa nya games
    //kan bygga ut senare
    return SafeArea(
      key: AppRouter.multiplayerScreenKey,
      child: Consumer2<UserProvider, MultiplayerProvider>(
          builder: (context, userProvider, multiplayerProvider, child) {
        if (userProvider.activeUser!.isAnonymous) {
          return Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "You must be a registered user to duel",
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
          controller:
              MultiplayerGameLoadController(userProvider, multiplayerProvider),
          result: GameList(
            userProvider: userProvider,
            multiplayerProvider: multiplayerProvider,
          ),
        );
      }),
    );
  }
}
