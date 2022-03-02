import 'package:flutter_test/flutter_test.dart';

import 'games_data.dart';

void main() {
  test('isWin', () {
    expect(createGameFromGuesses(answer: "a", guesses: ["a"]).isWin, true);
    expect(createGameFromGuesses(answer: "a", guesses: ["b"]).isWin, false);
    expect(createGameFromGuesses(answer: "a", guesses: ["b", "c", "d"]).isWin,
        false);
    expect(createGameFromGuesses(answer: "a", guesses: ["a", "c", "d"]).isWin,
        true);
    expect(createGameFromGuesses(answer: "a", guesses: ["b", "a", "d"]).isWin,
        true);
    expect(createGameFromGuesses(answer: "a", guesses: ["b", "a", "d"]).isWin,
        true);
    expect(createGameFromGuesses(answer: "a", guesses: ["a", "a", "a"]).isWin,
        true);
  });

  test('points', () {
    expect(createGame(winIndex: -1, finalGuess: null).points, 0);
    expect(createGame(winIndex: 0).points, 100);
    expect(createGame(winIndex: 1).points, 90);
    expect(createGame(winIndex: 2).points, 80);
    expect(createGame(winIndex: 3).points, 70);
    expect(createGame(winIndex: 4).points, 60);
    expect(createGame(winIndex: 5).points, 50);
    expect(
      createGame(winIndex: -1, answer: "abcde", finalGuess: "xxxxx").points,
      0,
    );
    expect(
      createGame(winIndex: -1, answer: "abcde", finalGuess: "xaxxx").points,
      1,
    );
    expect(
      createGame(winIndex: -1, answer: "abcde", finalGuess: "xaaxx").points,
      2,
    );
    expect(
      createGame(winIndex: -1, answer: "abcde", finalGuess: "axxxx").points,
      5,
    );
    expect(
      createGame(winIndex: -1, answer: "abcde", finalGuess: "aaaaa").points,
      5,
    );
    expect(
      createGame(winIndex: -1, answer: "abcde", finalGuess: "xxxee").points,
      5,
    );
    expect(
      createGame(winIndex: -1, answer: "abcde", finalGuess: "edcba").points,
      9,
    );
    expect(
      createGame(winIndex: -1, answer: "abcde", finalGuess: "abcda").points,
      20,
    );
  });
}
