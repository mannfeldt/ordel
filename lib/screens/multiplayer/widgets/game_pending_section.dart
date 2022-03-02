import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/language_model.dart';
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
  final List<Language> languages;

  const GamePendingSection({
    Key? key,
    required this.games,
    required this.users,
    required this.me,
    required this.onDeleteGame,
    required this.languages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pending game invites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ...games.map((g) {
          User invitee = users.firstWhere(
            (u) => u.uid == g.invitees.first,
            orElse: () => User.empty(),
          );
          Language language = languages.firstWhere((l) => l.code == g.language,
              orElse: () => Language("", ""));
          return ExpansionTile(
            // key: Key(PlayKeys.gameListItemForid(g.id)),
            title: Text(
              kReleaseMode ? "${language.name} duel" : g.id,
              style: TextStyle(color: Colors.grey.shade100),
            ),
            subtitle: Text(
              "Challenged: ${invitee.displayname}",
              style: TextStyle(color: Colors.grey.shade100),
            ),
            trailing: g.host == me.uid
                ? IconButton(
                    onPressed: () => onDeleteGame(g),
                    icon: Icon(
                      Icons.delete,
                      color: Colors.grey.shade100,
                    ),
                  )
                : Text(
                    GAME_STATE_NAMES[g.state]?.toUpperCase() ?? "unkown",
                    style: TextStyle(
                      color: Colors.grey.shade100,
                    ),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade100,
                        ),
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
                                await Provider.of<MultiplayerProvider>(context,
                                        listen: false)
                                    .acceptGameInvite(g, user, me)
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.grey.shade100,
                              ),
                            )
                          : null,
                      contentPadding: EdgeInsets.symmetric(horizontal: 30),
                      trailing: Text(
                        "Pending response",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade100,
                        ),
                      ),
                    );
                  })
                ],
              )
            ],
          );
        }).toList(),
      ],
    );
  }
}
