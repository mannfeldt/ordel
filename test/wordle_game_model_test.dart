import 'package:flutter_test/flutter_test.dart';

import 'games_data.dart';

void main() {
  test('isWin', () {
    expect(createGame(answer: "a", guesses: []).isWin, false);
    expect(createGame(answer: "a", guesses: ["a"]).isWin, true);
    expect(createGame(answer: "a", guesses: ["b"]).isWin, false);
    expect(createGame(answer: "a", guesses: ["b", "c", "d"]).isWin, false);
    expect(createGame(answer: "a", guesses: ["a", "c", "d"]).isWin, true);
    expect(createGame(answer: "a", guesses: ["b", "a", "d"]).isWin, true);
    expect(createGame(answer: "a", guesses: ["b", "a", "d"]).isWin, true);
    expect(createGame(answer: "a", guesses: ["a", "a", "a"]).isWin, true);
  });
}
