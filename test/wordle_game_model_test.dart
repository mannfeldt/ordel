import 'package:flutter_test/flutter_test.dart';
import 'package:ordel/models/wordle_game_model.dart';

void main() {
  test('isWin', () {
    expect(WordleGame(answer: "a", guesses: []).isWin, false);
    expect(WordleGame(answer: "a", guesses: ["a"]).isWin, true);
    expect(WordleGame(answer: "a", guesses: ["b"]).isWin, false);
    expect(WordleGame(answer: "a", guesses: ["b", "c", "d"]).isWin, false);
    expect(WordleGame(answer: "a", guesses: ["a", "c", "d"]).isWin, true);
    expect(WordleGame(answer: "a", guesses: ["b", "a", "d"]).isWin, true);
    expect(WordleGame(answer: "a", guesses: ["b", "a", "d"]).isWin, true);
    expect(WordleGame(answer: "a", guesses: ["a", "a", "a"]).isWin, true);
  });
}
