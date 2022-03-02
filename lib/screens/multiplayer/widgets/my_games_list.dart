import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ordel/models/language_model.dart';
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

    List<Language> supportedLanguages = RemoteConfig.instance
        .getString("supported_languages")
        .split(",")
        .toList()
        .map((l) => Language(l.split(":").first, l.split(":").last))
        .toList();

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
            languages: supportedLanguages,
          ),
        if (gamesMyTurn.isNotEmpty)
          GameMyTurnSection(
            users: users,
            games: gamesMyTurn,
            activeUser: me,
            onOpenGame: onOpenGame,
            //! skulle kunna förbättre delete pågånede game till abandonGame
            // och hantera det sngygare som att man bara tar bort sig själv och ändrar status/sätter abandonedUid:
            // alltså ta bort användaren direkt från game.playerUids men spara undan uid så andra anvädnaren kan se och ta bort gamet helt
            // kanske även med en notis att "blabla have abandoned the game.."
            // så användare2 kan se gamet under finishedGames t.ex. och ta bort det på riktigt där då.
            onDeleteGame: onDeleteGame,
            languages: supportedLanguages,
          ),
        if (gamesPlaying.isNotEmpty)
          GamePlayingSection(
            games: gamesPlaying,
            users: users,
            activeUser: me,
            onOpenGame: onOpenGame,
            onDeleteGame: onDeleteGame,
            languages: supportedLanguages,
          ),
        if (gamesPending.isNotEmpty)
          GamePendingSection(
            games: gamesPending,
            users: users,
            onDeleteGame: onDeleteGame,
            me: me,
            languages: supportedLanguages,
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
