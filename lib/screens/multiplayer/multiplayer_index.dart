import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/screens/multiplayer/play_load_controller.dart';
import 'package:ordel/screens/multiplayer/widgets/game_list.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/loader.dart';
import 'package:provider/provider.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //börja enkelt med bara en game list och en knapp för att skapa nya games
    //kan bygga ut senare
    return SafeArea(
      key: AppRouter.multiplayerScreenKey,
      child: Consumer2<UserProvider, MultiplayerProvider>(
        builder: (context, userProvider, multiplayerProvider, child) => Loader(
          controller:
              MultiplayerGameLoadController(userProvider, multiplayerProvider),
          result: GameList(
            userProvider: userProvider,
            multiplayerProvider: multiplayerProvider,
          ),
        ),
      ),
    );
  }
}
