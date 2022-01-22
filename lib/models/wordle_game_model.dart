import 'package:cloud_firestore/cloud_firestore.dart';

class WordleGame {
  final String answer;
  final List<String> guesses;
  final Duration duration;
  final String language;
  final String user;
  final DateTime date;

  bool get isWin => guesses.contains(answer);
  Duration get averageGuessTime => Duration(
      milliseconds: (duration.inMilliseconds / guesses.length).round());

  WordleGame({
    required this.answer,
    required this.guesses,
    required this.duration,
    required this.language,
    required this.user,
    required this.date,
  });

  factory WordleGame.fromJson(dynamic json) {
    String answer = json['answer'];
    String user = json['user'];
    Timestamp timestamp = json['date'];
    DateTime date = DateTime.parse(timestamp.toDate().toString());

    String lang = json['lang'];
    List<dynamic> guessesData = json['guesses'];
    List<String> guesses = guessesData.map((g) => g.toString()).toList();
    int dur = json['dur'];
    Duration duration = Duration(milliseconds: dur);

    WordleGame game = WordleGame(
      answer: answer,
      guesses: guesses,
      language: lang,
      user: user,
      duration: duration,
      date: date,
    );

    return game;
  }
  Map<String, dynamic> toJson() {
    return {
      "answer": answer,
      "guesses": guesses,
      "lang": language,
      "user": user,
      "dur": duration.inMilliseconds,
      "date": date,
    };
  }
}
