import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/language_model.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/screens/multiplayer/widgets/multiplayer_game_standings.dart';

class GameMyTurnSection extends StatelessWidget {
  final List<MultiplayerGame> games;
  final Function onOpenGame;
  final Function onDeleteGame;
  final List<User> users;
  final User activeUser;
  final List<Language> languages;

  const GameMyTurnSection({
    Key? key,
    required this.games,
    required this.onOpenGame,
    required this.users,
    required this.activeUser,
    required this.languages,
    required this.onDeleteGame,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My turn",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        ...games.map(
          (g) {
            User opponent = users.firstWhere(
              (u) => u.uid != g.currentPlayerUid,
              orElse: () => User.empty(),
            );
            Language language = languages.firstWhere(
                (l) => l.code == g.language,
                orElse: () => Language("", ""));
            return ExpansionTile(
              // key: Key(PlayKeys.gameListItemForid(g.id)),
              title: Text(
                kReleaseMode ? "${language.name} duel" : g.id,
                style: TextStyle(color: Colors.grey.shade100),
              ),
              subtitle: Text("Opponent: ${opponent.displayname}",
                  style: TextStyle(color: Colors.grey.shade100)),
              trailing: TextButton(
                // key: Key(PlayKeys.OPEN_GAME_BUTTON),
                onPressed: () => onOpenGame(g),
                child: Container(
                  child: Text(
                    "Play",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(color: Colors.white, width: 2.0)),
                ),
              ),
              children: [
                ListView(
                  shrinkWrap: true,
                  children: [
                    MultiplayerGameStandings(
                      game: g,
                      activeUser: activeUser,
                      otherUser: users.firstWhere((u) =>
                          u.uid ==
                          g.playerUids
                              .firstWhere((id) => id != activeUser.uid)),
                      size: Size(
                        mq.size.width,
                        mq.size.height - mq.padding.top,
                      ),
                    ),
                    IconButton(
                      onPressed: () => onDeleteGame(g),
                      icon: Icon(
                        Icons.delete,
                        color: Colors.grey.shade100,
                      ),
                    )
                  ],
                )
              ],
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
