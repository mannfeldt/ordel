import 'package:flutter/material.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/screens/multiplayer/widgets/multiplayer_game_standings.dart';

class GamePlayingSection extends StatelessWidget {
  final List<MultiplayerGame> games;
  final List<User> users;
  final Function onOpenGame;
  final User activeUser;

  const GamePlayingSection(
      {Key? key,
      required this.games,
      required this.onOpenGame,
      required this.activeUser,
      required this.users})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);

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
            return ExpansionTile(
              // key: Key(PlayKeys.gameListItemForid(g.id)),
              subtitle: Text("Turn to play: ${playing.displayname}",
                  style: TextStyle(color: Colors.grey.shade100)),
              title: Text(g.id, style: TextStyle(color: Colors.grey.shade100)),
              trailing: Icon(
                Icons.arrow_downward,
                color: Colors.white,
              ),
              children: [
                ListView(
                  shrinkWrap: true,
                  children: [
                    MultiplayerGameStandings(
                      //TODO funkar inte riktigt med namnen här eller väl inne i game viewn.. man får bara sitt egna.
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
