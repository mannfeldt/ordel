import 'package:auto_size_text/auto_size_text.dart';
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
    List<GameRound> activeUserRounds =
        game.rounds.where((r) => r.user == activeUser.uid).toList();
    List<GameRound> otherUserRounds =
        game.rounds.where((r) => r.user == otherUser.uid).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildUserStanding(activeUserRounds, activeUser),
        _buildUserStanding(otherUserRounds, otherUser)
      ],
    );

    //Visa denna även i gameList i details på alla rader. extensionTile...
  }

  Widget _buildUserStanding(List<GameRound> rounds, User user) {
    int points = rounds.fold(
        0, (int previousValue, element) => previousValue + element.points);
    return Column(
      children: [
        SizedBox(
          width: (size.width - 80) / 2,
          child: Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  user.displayname,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
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
