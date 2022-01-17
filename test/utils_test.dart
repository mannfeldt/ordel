import 'package:flutter_test/flutter_test.dart';
import 'package:ordel/utils.dart';

void main() {
  group("getKeyState", () {
    test('unknow', () {
      expect(getKeyState("A", guesses: [""], answer: "BCD"), KeyState.unknow);
      expect(getKeyState("A", guesses: ["BC"], answer: "BCD"), KeyState.unknow);
      expect(
          getKeyState("A", guesses: ["BCD"], answer: "BCD"), KeyState.unknow);
      expect(
          getKeyState("A",
              guesses: ["BDC", "BCD", "BCD", "BCD", "BCD", "BCD"],
              answer: "BCD"),
          KeyState.unknow);
    });
    test('wrong', () {
      expect(getKeyState("A", guesses: ["A"], answer: "BCD"), KeyState.wrong);
      expect(getKeyState("A", guesses: ["AAA"], answer: "BCD"), KeyState.wrong);
      expect(getKeyState("A", guesses: ["BCD", "A"], answer: "BCD"),
          KeyState.wrong);
      expect(
          getKeyState("A",
              guesses: ["AAA", "AAA", "AAA", "AAA", "AAA", "AAA"],
              answer: "BCD"),
          KeyState.wrong);
    });
    test('included', () {
      expect(
          getKeyState("A", guesses: ["A"], answer: "BCDA"), KeyState.included);
      expect(getKeyState("A", guesses: ["ABCD"], answer: "BCDA"),
          KeyState.included);
      expect(getKeyState("A", guesses: ["AAAB"], answer: "BCDA"),
          KeyState.included);
      expect(
          getKeyState("A",
              guesses: ["AAAB", "AAAC", "AAAD", "AAAB", "AAAB", "AAAB"],
              answer: "BCDA"),
          KeyState.included);
    });
    test('correct', () {
      expect(getKeyState("A", guesses: ["A"], answer: "A"), KeyState.correct);
      expect(getKeyState("A", guesses: ["ABCD"], answer: "AAAA"),
          KeyState.correct);
      expect(getKeyState("A", guesses: ["ABCD"], answer: "ABCD"),
          KeyState.correct);
      expect(getKeyState("A", guesses: ["BBAB"], answer: "BCAD"),
          KeyState.correct);
      expect(
          getKeyState("A",
              guesses: ["BBBBB", "BCDEF", "BCDEF", "BCDEF", "BCDEF", "BCADF"],
              answer: "BCADD"),
          KeyState.correct);
      expect(
          getKeyState("A",
              guesses: ["ABBBB", "BCDEF", "BCDEF", "BCDEF", "BCDEF", "BCADF"],
              answer: "BCADF"),
          KeyState.correct);
      expect(
          getKeyState("A",
              guesses: ["BBABB", "BCDEF", "BCDEF", "BCDEF", "BCDEF", "ACDFE"],
              answer: "BCADF"),
          KeyState.correct);
    });
  });
  group("getLetterBoxState", () {
    test('inactive', () {
      expect(
          getLetterBoxState(0,
              rowState: RowState.inactive,
              activeIndex: 0,
              answer: "ABC",
              guess: ""),
          LetterBoxState.inactive);
      expect(
          getLetterBoxState(0,
              rowState: RowState.inactive,
              activeIndex: 0,
              answer: "ABC",
              guess: "ABC"),
          LetterBoxState.inactive);
      expect(
          getLetterBoxState(0,
              rowState: RowState.inactive,
              activeIndex: 1,
              answer: "ABC",
              guess: "ABC"),
          LetterBoxState.inactive);
      expect(
          getLetterBoxState(1,
              rowState: RowState.inactive,
              activeIndex: 0,
              answer: "ABC",
              guess: "ABC"),
          LetterBoxState.inactive);
    });
    test('active', () {
      expect(
          getLetterBoxState(0,
              rowState: RowState.active,
              activeIndex: 1,
              answer: "ABC",
              guess: ""),
          LetterBoxState.active);
      expect(
          getLetterBoxState(1,
              rowState: RowState.active,
              activeIndex: 0,
              answer: "ABC",
              guess: ""),
          LetterBoxState.active);
      expect(
          getLetterBoxState(0,
              rowState: RowState.active,
              activeIndex: 1,
              answer: "ABC",
              guess: "ABC"),
          LetterBoxState.active);
      expect(
          getLetterBoxState(1,
              rowState: RowState.active,
              activeIndex: 0,
              answer: "ABC",
              guess: "ABC"),
          LetterBoxState.active);
    });
    test('focused', () {
      expect(
          getLetterBoxState(0,
              rowState: RowState.active,
              activeIndex: 0,
              answer: "ABC",
              guess: ""),
          LetterBoxState.focused);
      expect(
          getLetterBoxState(1,
              rowState: RowState.active,
              activeIndex: 1,
              answer: "ABC",
              guess: ""),
          LetterBoxState.focused);
      expect(
          getLetterBoxState(0,
              rowState: RowState.active,
              activeIndex: 0,
              answer: "ABC",
              guess: "ABC"),
          LetterBoxState.focused);
      expect(
          getLetterBoxState(1,
              rowState: RowState.active,
              activeIndex: 1,
              answer: "ABC",
              guess: "ABC"),
          LetterBoxState.focused);
    });
    test('correct', () {
      expect(
          getLetterBoxState(0,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABC",
              guess: "AYY"),
          LetterBoxState.correct);
      expect(
          getLetterBoxState(1,
              rowState: RowState.done,
              activeIndex: 1,
              answer: "YBY",
              guess: "ABC"),
          LetterBoxState.correct);
      expect(
          getLetterBoxState(1,
              rowState: RowState.done,
              activeIndex: 1,
              answer: "ABC",
              guess: "ABC"),
          LetterBoxState.correct);
    });
    test('included', () {
      expect(
          getLetterBoxState(0,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "BCA",
              guess: "AYY"),
          LetterBoxState.included);
      expect(
          getLetterBoxState(1,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "BCA",
              guess: "YAY"),
          LetterBoxState.included);
      expect(
          getLetterBoxState(1,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABA",
              guess: "AAB"),
          LetterBoxState.included);
      expect(
          getLetterBoxState(2,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "AAB",
              guess: "ABA"),
          LetterBoxState.included);
      expect(
          getLetterBoxState(1,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABCDE",
              guess: "BAAAA"),
          LetterBoxState.included);
      expect(
          getLetterBoxState(2,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABCDE",
              guess: "BAAAA"),
          LetterBoxState.included);
      expect(
          getLetterBoxState(3,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABCDE",
              guess: "BAAAA"),
          LetterBoxState.included);
      expect(
          getLetterBoxState(4,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABCDE",
              guess: "BAAAA"),
          LetterBoxState.included);
    });
    test('wrong', () {
      expect(
          getLetterBoxState(0,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABC",
              guess: "XBC"),
          LetterBoxState.wrong);
      expect(
          getLetterBoxState(1,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABC",
              guess: "AXC"),
          LetterBoxState.wrong);

      //TODO de här nedan blir fel va. de blir included just nu..
      expect(
          getLetterBoxState(1,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABC",
              guess: "AAA"),
          LetterBoxState.wrong);
      expect(
          getLetterBoxState(2,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "ABC",
              guess: "AAA"),
          LetterBoxState.wrong);
      expect(
          getLetterBoxState(2,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "AAB",
              guess: "AAA"),
          LetterBoxState.wrong);
      expect(
          getLetterBoxState(2,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "AAXAA",
              guess: "AAAAA"),
          LetterBoxState.wrong);
      expect(
          getLetterBoxState(4,
              rowState: RowState.done,
              activeIndex: 0,
              answer: "AAAAA",
              guess: "AAAAB"),
          LetterBoxState.wrong);
    });
  });
}
