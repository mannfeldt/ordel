import 'package:flutter/material.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';

class GameMyTurnSection extends StatelessWidget {
  final List<MultiplayerGame> games;
  final Function onOpenGame;
  final List<User> users;

  const GameMyTurnSection({
    Key? key,
    required this.games,
    required this.onOpenGame,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My turn",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...games
            .map(
              (g) => ListTile(
                // key: Key(PlayKeys.gameListItemForid(g.id)),
                title: Text(g.id),
                subtitle: Row(
                  children: g.playerUids.map((p) {
                    User user = users.firstWhere(
                      (u) => u.uid == p,
                      orElse: () => User.empty(),
                    );
                    return Text(user.displayname);
                  }).toList(),
                ),
                trailing: IconButton(
                  // key: Key(PlayKeys.OPEN_GAME_BUTTON),
                  onPressed: () => onOpenGame(g),
                  icon: Icon(Icons.chevron_right),
                ),
              ),
            )
            .toList(),
        Divider(),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
