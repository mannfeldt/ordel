import 'package:flutter/material.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';

class GameFinishedSection extends StatelessWidget {
  final List<MultiplayerGame> games;
  final List<User> users;
  final User me;
  final Function onDeleteGame;
  final Function onOpenGame;

  const GameFinishedSection({
    Key? key,
    required this.games,
    required this.users,
    required this.me,
    required this.onDeleteGame,
    required this.onOpenGame,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Finished games",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...games
            .map(
              (g) => ListTile(
                // key: Key(PlayKeys.gameListItemForid(g.id)),
                title: Text(g.id),
                subtitle: Text("${g.invitees.length} more is invited"),
                leading: IconButton(
                  onPressed: () => onDeleteGame(g),
                  icon: Icon(
                    Icons.delete,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () => onOpenGame(g),
                  icon: Icon(Icons.chevron_right),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
