import 'package:flutter/material.dart';
import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/utils/constants.dart';
import 'package:ordel/utils/utils.dart';
import 'package:ordel/widgets/word_grid.dart';

class MultiplayerGameStandings extends StatelessWidget {
  final MultiplayerGame game;
  final User activeUser;
  final User otherUser;
  final Size size;
  const MultiplayerGameStandings({
    Key? key,
    required this.game,
    required this.activeUser,
    required this.otherUser,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    //TODO en rad med två columner. namn överst ivarje kolumn sen en rad per omgång som multiplayer spelas i.
    //TODO finns ingen på det indexet så visas bara svarata rutor utan någon bokstav, eller med frågetecken kanke.
    //annars visas en WordRow med rätt färger och ev poäng för varje rad? total poäng visas upptill vid användarnamnet.
    List<GameRound> activeUserRounds =
        game.rounds.where((r) => r.user == activeUser.uid).toList();
    List<GameRound> otherUserRounds =
        game.rounds.where((r) => r.user == otherUser.uid).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildUserStanding(activeUserRounds),
        _buildUserStanding(otherUserRounds)
      ],
    );

    //Visa denna även i gameList i details på alla rader. extensionTile...
  }

  Widget _buildUserStanding(List<GameRound> rounds) {
    int points = rounds.fold(
        0, (int previousValue, element) => previousValue + element.points);
    return Column(
      children: [
        Row(
          children: [
            Text(
              activeUser.displayname,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "($points)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.green,
              ),
            )
          ],
        ),
        for (int i = 0; i < Constants.multiplayerRounds; i++)
          _buildStandingRow(
            rounds.length > i ? rounds[i] : null,
          ),
      ],
    );
  }

  Widget _buildStandingRow(GameRound? game) {
    if (game == null) {
      return WordRow(
        answer: "xxxxx",
        guess: "",
        boxMargin: 1.0,
        state: RowState.inactive,
        boxSize: (size.width - 80) / 10,
      );
    }
    return WordRow(
      answer: game.answer,
      guess: game.finalGuess ?? "?????",
      defaultFlipped: true,
      boxMargin: 1.0,
      state: game.isPlayed ? RowState.done : RowState.active,
      boxSize: (size.width - 80) / 10,
    );
  }
}