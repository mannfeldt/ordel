import 'package:cloud_firestore/cloud_firestore.dart';

class GameRound {
  final String answer;
  final Duration duration;
  final String language;
  final String user;
  final DateTime date;
  final String finalGuess;
  final int winIndex;

  bool get isWin => winIndex > -1;
  int get enteredGuesses => isWin ? winIndex + 1 : 6;
  Duration get averageGuessTime => Duration(
      milliseconds: (duration.inMilliseconds / enteredGuesses).round());

  GameRound({
    required this.answer,
    required this.duration,
    required this.language,
    required this.user,
    required this.date,
    required this.finalGuess,
    this.winIndex = -1,
  });

  factory GameRound.fromGuesses({
    required String answer,
    required Duration duration,
    required String language,
    required String user,
    required DateTime date,
    required List<String> guesses,
  }) {
    return GameRound(
      answer: answer,
      language: language,
      user: user,
      duration: duration,
      date: date,
      finalGuess: guesses.last,
      winIndex: guesses.indexOf(answer),
    );
  }

  factory GameRound.fromJson(dynamic json) {
    String answer = json['answer'];
    String user = json['user'];
    Timestamp timestamp = json['date'];
    DateTime date = DateTime.parse(timestamp.toDate().toString());

    String lang = json['lang'];
    int dur = json['dur'];
    Duration duration = Duration(milliseconds: dur);
    String finalGuess = json['guess'];
    dynamic winIndexData = json['win'];
    int winIndex = int.tryParse(winIndexData) ?? -1;

    GameRound game = GameRound(
      answer: answer,
      language: lang,
      user: user,
      duration: duration,
      date: date,
      finalGuess: winIndex > -1 ? answer : finalGuess,
      winIndex: winIndex,
    );

    return game;
  }

  Map<String, dynamic> toJson() {
    return {
      "answer": answer,
      if (isWin) "win": winIndex,
      if (!isWin) "guess": finalGuess,
      "lang": language,
      "user": user,
      "dur": duration.inMilliseconds,
      "date": date,
    };
  }
}
