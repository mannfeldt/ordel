enum KeyState { unknow, included, correct, wrong }
enum RowState { inactive, active, done }
enum LetterBoxState { inactive, active, focused, wrong, included, correct }

KeyState getKeyState(String key,
    {required List<String> guesses, required String answer}) {
  KeyState state = KeyState.unknow;
  for (String guess in guesses) {
    for (int i = 0; i < guess.length; i++) {
      if (guess[i] == key) {
        if (key == answer[i]) return KeyState.correct;
        if (answer.contains(key)) {
          state = KeyState.included;
        } else if (state == KeyState.unknow) {
          state = KeyState.wrong;
        }
      }
    }
  }
  return state;
}

LetterBoxState getLetterBoxState(
  int i, {
  required RowState rowState,
  required int activeIndex,
  required String answer,
  required String guess,
}) {
  //TODO lägg till tetfall på hur jag vill ha det med alla olika kombinationer
  //TODO inkl buggen jag upptäckte
  if (rowState == RowState.inactive) return LetterBoxState.inactive;
  if (rowState == RowState.active) {
    return activeIndex == i ? LetterBoxState.focused : LetterBoxState.active;
  }
  String guessLetter = guess[i];
  if (guessLetter == answer[i]) return LetterBoxState.correct;
  if (answer.contains(guessLetter)) {
    int matches = guessLetter.allMatches(answer).length;
    for (int j = 0; j < guess.length; j++) {
      if (i != j && answer[j] == guess[j] && answer[j] == guessLetter) {
        matches--;
      }
    }
    if (matches > 0) return LetterBoxState.included;
  }
  return LetterBoxState.wrong;
}
