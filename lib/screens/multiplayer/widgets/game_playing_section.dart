import 'package:flutter/material.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';

class GamePlayingSection extends StatelessWidget {
  final List<MultiplayerGame> games;
  final List<User> users;
  final Function onOpenGame;

  const GamePlayingSection(
      {Key? key,
      required this.games,
      required this.onOpenGame,
      required this.users})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Active games",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...games.map(
          (g) {
            User playing = users.firstWhere(
              (u) => u.uid == g.currentPlayerUid,
              orElse: () => User.empty(),
            );
            return ListTile(
              // key: Key(PlayKeys.gameListItemForid(g.id)),
              subtitle: Text("Turn to play: ${playing.displayname}"),
              title: Text(g.id),
              trailing: IconButton(
                // key: Key(PlayKeys.OPEN_GAME_BUTTON),
                onPressed: () => onOpenGame(g),
                icon: Icon(Icons.chevron_right),
              ),
            );
          },
        ).toList(),
        Divider(),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
