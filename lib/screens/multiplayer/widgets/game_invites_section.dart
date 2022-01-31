import 'package:flutter/material.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/widgets/user_tile.dart';

class GameInvitesSection extends StatelessWidget {
  final List<MultiplayerGame> games;
  final List<User> users;
  final User me;
  final Function onAcceptInvite;
  final Function onDeclineInvite;

  const GameInvitesSection(
      {Key? key,
      required this.games,
      required this.users,
      required this.me,
      required this.onAcceptInvite,
      required this.onDeclineInvite})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Game invites",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...games
            .map(
              (g) => ExpansionTile(
                // key: Key(PlayKeys.gameListItemForid(g.id)),
                title: Text(g.id),
                subtitle: Text("${g.invitees.length - 1} more is invited"),
                trailing: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 25,
                      child: TextButton(
                        onPressed: () => onAcceptInvite(g, me),
                        child: Text("Accept"),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                      child: TextButton(
                        onPressed: () => onDeclineInvite(g, me),
                        child: Text("Decline"),
                      ),
                    )
                  ],
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 30),
                          user: user,
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
        Divider(),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
