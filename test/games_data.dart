import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/models/multiplayer_game_model.dart';

GameRound createGameFromGuesses({
  String answer = "answer",
  List<String> guesses = const [],
  Duration? duration,
  String user = "user1",
  bool win = false,
}) {
  return GameRound.fromGuesses(
    answer: answer,
    guesses: guesses.isEmpty && win ? [answer] : guesses,
    duration: duration ?? const Duration(seconds: 30),
    user: user,
  );
}

GameRound createGame({
  String answer = "answer",
  String? finalGuess,
  Duration? duration,
  String user = "user1",
  int winIndex = -1,
}) {
  return GameRound(
    answer: answer,
    finalGuess: finalGuess,
    winIndex: winIndex,
    duration: duration ?? const Duration(seconds: 30),
    user: user,
  );
}

MultiplayerGame createMultiplayerGame({
  String host = "host",
  String id = "id1",
  String language = "sv",
  DateTime? startTime,
  GameState state = GameState.Playing,
  List<String> invitees = const [],
  List<String>? playerUids,
  List<GameRound>? rounds,
}) {
  return MultiplayerGame(
    host: host,
    id: id,
    language: language,
    startTime: startTime ?? DateTime(2022, 1, 1),
    state: state,
    invitees: invitees,
    playerUids: playerUids ?? [host, ...invitees],
    rounds: rounds ?? [],
  );
}

SingleplayerGameRound createSingleplayerGameRound({
  String answer = "answer",
  List<String> guesses = const [],
  Duration? duration,
  String language = "sv",
  String user = "user1",
  DateTime? date,
  bool win = false,
}) {
  return SingleplayerGameRound.fromGuesses(
    answer: answer,
    guesses: guesses.isEmpty && win ? [answer] : guesses,
    duration: duration ?? const Duration(seconds: 30),
    language: language,
    user: user,
    date: date ?? DateTime(2020, 1, 1),
  );
}
