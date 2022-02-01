import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/widgets/user_tile.dart';
import 'package:provider/provider.dart';

class GamePendingSection extends StatelessWidget {
  final List<MultiplayerGame> games;
  final List<User> users;
  final User me;
  final Function onDeleteGame;
  final Function onStartGame;

  const GamePendingSection(
      {Key? key,
      required this.games,
      required this.users,
      required this.me,
      required this.onDeleteGame,
      required this.onStartGame})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pending games",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...games
            .map(
              (g) => ExpansionTile(
                // key: Key(PlayKeys.gameListItemForid(g.id)),
                title: Text(g.id),
                subtitle: Text("Waiting for response"),
                trailing: g.host == me.uid
                    ? IconButton(
                        onPressed: () => onDeleteGame(g),
                        icon: Icon(
                          Icons.delete,
                        ),
                      )
                    : Text(
                        GAME_STATE_NAMES[g.state]?.toUpperCase() ?? "unkown",
                      ),
                children: [
                  ListView(
                    shrinkWrap: true,
                    children: [
                      ...g.playerUids.map((i) {
                        User user = users.firstWhere(
                          (u) => u.uid == i,
                          orElse: () => User.empty(),
                        );
                        if (user.uid.isEmpty) return Container();
                        return UserTile(
                          dense: true,
                          user: user,
                          contentPadding: EdgeInsets.symmetric(horizontal: 30),
                          trailing: Text(
                            g.host == i ? "Host" : "Accepted",
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      }),
                      ...g.invitees.map((i) {
                        User user = users.firstWhere(
                          (u) => u.uid == i,
                          orElse: () => User.empty(),
                        );
                        if (user.uid.isEmpty) return Container();
                        return UserTile(
                          dense: true,
                          user: user,
                          leading: !kReleaseMode && g.host == me.uid
                              ? IconButton(
                                  onPressed: () async => {
                                    await Provider.of<MultiplayerProvider>(
                                            context,
                                            listen: false)
                                        .acceptGameInvite(g, user, me)
                                  },
                                  icon: Icon(
                                    Icons.add,
                                  ),
                                )
                              : null,
                          contentPadding: EdgeInsets.symmetric(horizontal: 30),
                          trailing: Text(
                            "Pending response",
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      })
                    ],
                  )
                ],
              ),
            )
            .toList(),
      ],
    );
  }
}
