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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        ...games.map(
          (g) {
            User playing = users.firstWhere(
              (u) => u.uid == g.currentPlayerUid,
              orElse: () => User.empty(),
            );
            return ListTile(
              // key: Key(PlayKeys.gameListItemForid(g.id)),
              subtitle: Text("Turn to play: ${playing.displayname}",
                  style: TextStyle(color: Colors.grey.shade100)),
              title: Text(g.id, style: TextStyle(color: Colors.grey.shade100)),
              trailing: IconButton(
                // key: Key(PlayKeys.OPEN_GAME_BUTTON),
                onPressed: () => onOpenGame(g),
                icon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
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
