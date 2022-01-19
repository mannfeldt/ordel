class GameRoundResult {
  final String answer;
  final List<String> guesses;
  Duration? duration;

  bool get isWin => guesses.contains(answer);
  Duration get averageGuessTime => Duration(
      milliseconds: (duration!.inMilliseconds / guesses.length).round());

  GameRoundResult({
    required this.answer,
    required this.guesses,
    this.duration,
  });
}
