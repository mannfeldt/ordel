import 'package:cloud_firestore/cloud_firestore.dart';

class SingleplayerGameRound extends GameRound {
  final String language;
  final DateTime date;

  SingleplayerGameRound(
      {required this.language,
      required this.date,
      answer,
      duration,
      user,
      finalGuess,
      winIndex})
      : super(
            answer: answer,
            duration: duration,
            user: user,
            finalGuess: finalGuess,
            winIndex: winIndex);

  factory SingleplayerGameRound.fromGuesses({
    required String answer,
    required Duration duration,
    required String language,
    required String user,
    required DateTime date,
    required List<String> guesses,
  }) {
    return SingleplayerGameRound(
      language: language,
      date: date,
      answer: answer,
      user: user,
      duration: duration,
      finalGuess: guesses.last,
      winIndex: guesses.indexOf(answer),
    );
  }

  factory SingleplayerGameRound.fromJson(dynamic json) {
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

    SingleplayerGameRound game = SingleplayerGameRound(
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

  @override
  Map<String, dynamic> toJson() {
    return {
      "answer": answer,
      if (isWin) "win": winIndex,
      if (!isWin) "guess": finalGuess,
      "lang": language,
      "user": user,
      if (duration != null) "dur": duration!.inMilliseconds,
      "date": date,
    };
  }
}

class GameRound {
  final String answer;
  Duration? duration;
  final String user;
  String? finalGuess;
  int winIndex;

  bool get isWin => winIndex > -1;
  int get enteredGuesses => isWin ? winIndex + 1 : 6;
  bool get isPlayed => isWin || finalGuess != null;
  Duration? get averageGuessTime => duration != null
      ? Duration(
          milliseconds: (duration!.inMilliseconds / enteredGuesses).round())
      : null;

  GameRound({
    required this.answer,
    this.duration,
    required this.user,
    this.finalGuess,
    this.winIndex = -1,
  });

  factory GameRound.fromGuesses({
    required String answer,
    required Duration duration,
    required String user,
    required List<String> guesses,
  }) {
    return GameRound(
      answer: answer,
      user: user,
      duration: duration,
      finalGuess: guesses.last,
      winIndex: guesses.indexOf(answer),
    );
  }

  factory GameRound.fromJson(dynamic json) {
    String answer = json['answer'];
    String user = json['user'];
    int? dur = json['dur'];
    Duration? duration = dur != null ? Duration(milliseconds: dur) : null;
    String? finalGuess = json['guess'];
    int? winIndexData = json['win'];
    int winIndex = winIndexData ?? -1;

    GameRound game = GameRound(
      answer: answer,
      user: user,
      duration: duration,
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
      "user": user,
      if (duration != null) "dur": duration!.inMilliseconds,
    };
  }
}
