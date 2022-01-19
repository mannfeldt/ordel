import 'package:flutter_test/flutter_test.dart';
import 'package:ordel/models/game_round_result_model.dart';

void main() {
  test('isWin', () {
    expect(GameRoundResult(answer: "a", guesses: []).isWin, false);
    expect(GameRoundResult(answer: "a", guesses: ["a"]).isWin, true);
    expect(GameRoundResult(answer: "a", guesses: ["b"]).isWin, false);
    expect(GameRoundResult(answer: "a", guesses: ["b", "c", "d"]).isWin, false);
    expect(GameRoundResult(answer: "a", guesses: ["a", "c", "d"]).isWin, true);
    expect(GameRoundResult(answer: "a", guesses: ["b", "a", "d"]).isWin, true);
    expect(GameRoundResult(answer: "a", guesses: ["b", "a", "d"]).isWin, true);
    expect(GameRoundResult(answer: "a", guesses: ["a", "a", "a"]).isWin, true);
  });
}
