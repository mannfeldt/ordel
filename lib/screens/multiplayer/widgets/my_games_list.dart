import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/screens/multiplayer/widgets/game_finished_section.dart';
import 'package:ordel/screens/multiplayer/widgets/game_invites_section.dart';
import 'package:ordel/screens/multiplayer/widgets/game_my_turn_section.dart';
import 'package:ordel/screens/multiplayer/widgets/game_pending_section.dart';
import 'package:ordel/screens/multiplayer/widgets/game_playing_section.dart';

class MyGamesList extends StatelessWidget {
  final List<MultiplayerGame> games;
  final List<User> users;

  final User me;
  final Function onAcceptInvite;
  final Function onDeclineInvite;
  final Function onDeleteGame;
  final Function onOpenGame;

  const MyGamesList(
      {Key? key,
      required this.games,
      required this.users,
      required this.me,
      required this.onAcceptInvite,
      required this.onDeclineInvite,
      required this.onDeleteGame,
      required this.onOpenGame})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MultiplayerGame> gamesPlaying = games
        .where(
            (g) => g.state == GameState.Playing && g.currentPlayerUid != me.uid)
        .toList();

    List<MultiplayerGame> gamesPending = games
        .where((g) =>
            g.state == GameState.Inviting && !g.invitees.contains(me.uid))
        .toList();

    List<MultiplayerGame> gameInvitations = games
        .where(
            (g) => g.state == GameState.Inviting && g.invitees.contains(me.uid))
        .toList();

    List<MultiplayerGame> gamesMyTurn = games
        .where(
            (g) => g.state == GameState.Playing && g.currentPlayerUid == me.uid)
        .toList();

    List<MultiplayerGame> gamesFinished =
        games.where((g) => g.isFinished).toList();
//TODO design till dessa lite mer. ta bort id och sätt bättre info. kanske ta med start datum?
    return ListView(
      // key: Key(PlayKeys.MY_GAMES_LIST),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      children: [
        if (gameInvitations.isNotEmpty)
          GameInvitesSection(
            games: gameInvitations,
            users: users,
            me: me,
            onAcceptInvite: onAcceptInvite,
            onDeclineInvite: onDeclineInvite,
          ),
        if (gamesMyTurn.isNotEmpty)
          GameMyTurnSection(
            users: users,
            games: gamesMyTurn,
            onOpenGame: onOpenGame,
          ),
        if (gamesPlaying.isNotEmpty)
          GamePlayingSection(
            games: gamesPlaying,
            users: users,
            onOpenGame: onOpenGame,
          ),
        if (gamesPending.isNotEmpty)
          GamePendingSection(
            games: gamesPending,
            users: users,
            onDeleteGame: onDeleteGame,
            me: me,
          ),
        if (gamesFinished.isNotEmpty)
          GameFinishedSection(
            games: gamesFinished,
            onOpenGame: onOpenGame,
            users: users,
            onDeleteGame: onDeleteGame,
            me: me,
          ),
      ],
    );
  }
}
