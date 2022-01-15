import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

//en rad kan ha 3 states. inactive, active, used,
//en ruta kan ha 3 states. empty, focused, filled,
//
//lägg en grid 5 rutor per rad 6 rader. sen ett custom tangentbord. som jag kan syra alla knappar etc.
//kolla paket för det eller fixa det helt själv custom med knappar bäst kanske. ska kunna vara olika tangentbord per språk
//en tangentbordknapp har en bokstav kopplad till sig. layout är per språk.
//https://ordel.se/
//1. fixa helt offline att själva spelet fungerar. ta några manuellt handplockade ord https://doon.se/ordl%C3%A4ngd/5
//2. lägg till coola animationer. allt ska vara responsivt. höjden är det känsliga. behöver inte visa alla 6 rader samtidigt? om det blir tight.
//3. lägg till funktion för pågående streak, nollställs helt när man failar. inget sparas historiskt.
//2. lägg till möjlighet att loggain, se firebase fltuter 2.8 widgeten? då sparar man sina spel och kan se streaks etc.
//3. är man inte inloggad så kan man bara spela sessionsbasis. man kan kanske fortfarande se pågående streak men inte sina rekord osv.
//4. lägg till highscorelist/lite mer statistik om vilken rank man är, vilken procenttile man är av alla spelare.
//5. det är streak som gäller. man kan ha flera olika typer av steaks. 1. klarade ord 2. klarade ord på under x rader etc.
//6. Lägg till möjlighet till matchmaking/duel där man tävlar likt quizkampen. man får välja 1 av 3 ord till den andra spelaren
//   den ska då spela och sen väljer den tillbaka ett ord osv. bäst av 5 kanske. man får poäng beronde på hur få gissningar man behövde.
//   det kan bli lika? eller tiebreak är tiden? man har max 1 minut per omgång och den med mest tid kvar vinner om det blev lika.
//   Det kan vara auto matchmaking (ranked) eller casual (invite friend).

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum KeyState { unknow, included, correct, wrong }

class _MyHomePageState extends State<MyHomePage> {
  String _answer = "";
  String _currentGuess = "";
  List<String> _guesses = [
    "",
    "",
    "",
    "",
    "",
    "",
  ];
  final List<String> _wordList = [
    "KAMEL",
    "BASTU",
    "AKTIE",
    "BETYG",
    "BJÖRK",
    "CYKEL",
    "DRUVA",
    "FALSK",
    "SAHAR",
    "FLÄKT",
    "GURKA",
    "HAVRE",
    "INTYG",
    "KABEL",
    "JUVEL",
  ];

  @override
  void initState() {
    startGame();
    super.initState();
  }

  void startGame() {
    setState(() {
      _currentGuess = "";
      _answer = _wordList[Random().nextInt(_wordList.length - 1)];
      _guesses = [
        "",
        "",
        "",
        "",
        "",
        "",
      ];
    });
  }

  int get activeRow => _guesses.indexWhere((g) => g.isEmpty);

  //hantera när vi lägger till en bokstav så läggs det till här max 5 chars per sträng då.
  //klickar man på delte så försvinner den senaste char.

  void _addGuess(String letter) {
    //kanske lägg till någon skakanimation att det inte går
    if (_currentGuess.length == 5) return;
    setState(() {
      _currentGuess = _currentGuess + letter;
    });
  }

  void _backSpace() {
    //kanske lägg till någon skakanimation att det inte går
    if (_currentGuess.isEmpty) return;
    setState(() {
      _currentGuess =
          _currentGuess.substring(0, _currentGuess.length - 1); //kanske -2?
    });
  }

  bool isValidWord(String word) {
    return true;
  }

  Future<void> gameOver() async {
    await Future.delayed(const Duration(seconds: 1));
    startGame();
  }

  Future<void> onGameWon() async {
    setState(() {
      _guesses[activeRow] = _currentGuess;
      _currentGuess = "";
    });
    await Future.delayed(const Duration(seconds: 2));
    startGame();
  }

  Future<void> _enterGuess() async {
    //kanske lägg till någon skakanimation att det inte går
    if (_currentGuess.length != 5) return;
    if (!isValidWord(_currentGuess)) return;

    if (_currentGuess == _answer) {
      await onGameWon();
    } else if (activeRow == _answer.length) {
      await gameOver();
    } else {
      setState(() {
        _guesses[activeRow] = _currentGuess;
        _currentGuess = "";
      });
    }

    //TODO reveal av resultatet ska ske med https://pub.dev/packages/flip_card
    //Det baksidan är samma widget fast då med rätt färgsättning.
    //så framsidan ska visas om korete är inaktivt/activt men när den är något annat så flippar vi till baksidan som då har färgerna
    //framsidan är alltid black87 ?
  }

  Widget _buildWordGrid() {
    return Column(
      children: [
        for (int i = 0; i < 6; i++)
          WordRow(
            guess: _guesses[i].isNotEmpty
                ? _guesses[i]
                : activeRow == i
                    ? _currentGuess
                    : "",
            answer: _answer,
            state: activeRow == i
                ? RowState.active
                : activeRow > i
                    ? RowState.done
                    : RowState.inactive,
          )
      ],
    );
  }

  KeyState getKeyState(String key) {
    KeyState state = KeyState.unknow;
    for (String guess in _guesses) {
      for (int i = 0; i < guess.length; i++) {
        if (guess[i] == key) {
          if (key == _answer[i]) return KeyState.correct;
          if (_answer.contains(key)) {
            state = KeyState.included;
          } else if (state == KeyState.unknow) {
            state = KeyState.wrong;
          }
        }
      }
    }
    return state;
  }

  Widget _buildKeyBoardButton(String key) {
    return LetterButton(
      letter: key,
      state: getKeyState(key),
      onTap: _addGuess,
    );
  }

  Widget _buildKeyboard() {
    //TODO knapparna här ska vara snygga och kuna ha färger beroende på answer + guesses.
    //TODO knapp kan ha state (unknown, included, correct, wrong)
    //även disabled om den inte är med i answer
    return Column(
      children: [
        Row(
          children: [
            _buildKeyBoardButton("Q"),
            _buildKeyBoardButton("W"),
            _buildKeyBoardButton("E"),
            _buildKeyBoardButton("R"),
            _buildKeyBoardButton("T"),
            _buildKeyBoardButton("Y"),
            _buildKeyBoardButton("U"),
            _buildKeyBoardButton("I"),
            _buildKeyBoardButton("O"),
            _buildKeyBoardButton("P"),
            _buildKeyBoardButton("Å"),
          ],
        ),
        Row(
          children: [
            _buildKeyBoardButton("A"),
            _buildKeyBoardButton("S"),
            _buildKeyBoardButton("D"),
            _buildKeyBoardButton("F"),
            _buildKeyBoardButton("G"),
            _buildKeyBoardButton("H"),
            _buildKeyBoardButton("J"),
            _buildKeyBoardButton("K"),
            _buildKeyBoardButton("L"),
            _buildKeyBoardButton("Ö"),
            _buildKeyBoardButton("Ä"),
          ],
        ),
        Row(
          children: [
            _buildKeyBoardButton("Z"),
            _buildKeyBoardButton("X"),
            _buildKeyBoardButton("C"),
            _buildKeyBoardButton("V"),
            _buildKeyBoardButton("B"),
            _buildKeyBoardButton("N"),
            _buildKeyBoardButton("M"),
            IconButton(
              onPressed: _backSpace,
              icon: const Icon(Icons.backspace_outlined),
            ),
            IconButton(
              onPressed: () async {
                await _enterGuess();
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWordGrid(),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }
}

class LetterButton extends StatelessWidget {
  final String letter;
  final KeyState state;
  final void Function(String) onTap;
  const LetterButton({
    Key? key,
    required this.onTap,
    required this.letter,
    this.state = KeyState.unknow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Color color;
    switch (state) {
      case KeyState.unknow:
        color = Colors.grey.shade600;
        break;
      case KeyState.wrong:
        color = Colors.blueGrey.shade900;
        break;
      case KeyState.included:
        color = Colors.purple;
        break;
      case KeyState.correct:
        color = Colors.green;
        break;
      default:
    }
    return Container(
      margin: EdgeInsets.all(1),
      height: 40,
      width: 30,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color,
          primary: Colors.white,
          textStyle: const TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        child: Text(letter),
        onPressed: () => onTap(letter),
      ),
    );
  }
}

enum RowState { inactive, active, done }
enum LetterBoxState { inactive, active, focused, wrong, included, correct }

class WordRow extends StatelessWidget {
  final String answer;
  final String guess;
  final RowState state;
  const WordRow({
    Key? key,
    this.state = RowState.inactive,
    this.guess = "",
    this.answer = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int activeLetterIndex = guess.length;

    LetterBoxState getLetterBoxState(int i) {
      if (state == RowState.inactive) return LetterBoxState.inactive;
      if (state == RowState.active) {
        return activeLetterIndex == i
            ? LetterBoxState.focused
            : LetterBoxState.active;
      }
      if (guess[i] == answer[i]) return LetterBoxState.correct;
      if (answer.contains(guess[i])) return LetterBoxState.included;
      return LetterBoxState.wrong;
    }

    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          LetterBox(
            state: getLetterBoxState(i),
            letter: activeLetterIndex > i ? guess[i] : "",
          ),
      ],
    );
  }
}

class LetterBox extends StatelessWidget {
  final LetterBoxState state;
  final String letter;

  const LetterBox({
    Key? key,
    this.state = LetterBoxState.inactive,
    this.letter = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Color boxColor;
    switch (state) {
      case LetterBoxState.inactive:
        boxColor = Colors.grey.shade600;
        break;
      case LetterBoxState.active:
        boxColor = Colors.black87;
        break;
      case LetterBoxState.focused:
        boxColor = Colors.black87;
        break;
      case LetterBoxState.wrong:
        boxColor = Colors.blueGrey.shade900;
        break;
      case LetterBoxState.included:
        boxColor = Colors.purple;
        break;
      case LetterBoxState.correct:
        boxColor = Colors.green;
        break;
      default:
    }
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.all(4.0),
          child: state == LetterBoxState.focused
              ? const Align(
                  child: BlinkingUnderline(),
                  alignment: Alignment.bottomCenter,
                )
              : Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class BlinkingUnderline extends StatefulWidget {
  const BlinkingUnderline({Key? key}) : super(key: key);

  @override
  _BlinkingUnderlineState createState() => _BlinkingUnderlineState();
}

class _BlinkingUnderlineState extends State<BlinkingUnderline>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        height: 3,
        color: Colors.white70,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
