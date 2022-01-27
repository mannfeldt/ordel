import 'package:ordel/models/wordle_game_model.dart';

WordleGame createGame({
  String answer = "answer",
  List<String> guesses = const [],
  Duration? duration,
  String language = "sv",
  String user = "user1",
  DateTime? date,
  bool win = false,
}) {
  return WordleGame(
    answer: answer,
    guesses: guesses.isEmpty && win ? [answer] : guesses,
    duration: duration ?? const Duration(seconds: 30),
    language: language,
    user: user,
    date: date ?? DateTime(2020, 1, 1),
  );
}
