import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ordel/utils.dart';

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

class WordRowController {
  Future<void> Function()? flip;
  Future<void> Function()? shake;
}

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

class _MyHomePageState extends State<MyHomePage> {
  final List<FlipCardController> _flipControllers = [
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController(),
    FlipCardController()
  ];

  List<FlipCardController> get activeFlipControllers =>
      getFlipControllers(activeRow);

  List<FlipCardController> getFlipControllers(int row) {
    return _flipControllers.sublist(row * 5, (row + 1) * 5);
  }

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

//TODO om det här inte fungerar får vi skapa upp mer statiska 5x6 flipcontrollers direkt och räkna ut vilka som ska flippas varje gång.
  @override
  void initState() {
    startGame();
    // _wordControllers.add(WordRowController());
    // _wordControllers.add(WordRowController());
    // _wordControllers.add(WordRowController());
    // _wordControllers.add(WordRowController());
    // _wordControllers.add(WordRowController());
    // _wordControllers.add(WordRowController());

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
      _flipControllers.forEach((c) => c.toggleCard());
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
    await Fluttertoast.showToast(
        msg: "Game Over",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0);
    await Future.delayed(const Duration(seconds: 2));

    startGame();
  }

  Future<void> onGameWon() async {
    setState(() {
      _guesses[activeRow] = _currentGuess;
      _currentGuess = "";
    });
    await Fluttertoast.showToast(
        msg: "You Won!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    await Future.delayed(const Duration(seconds: 2));
    startGame();
  }

  Future<void> flipGuess() async {
    for (FlipCardController c in activeFlipControllers) {
      c.toggleCard();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> shakeRow() async {
    for (FlipCardController c in activeFlipControllers) {
      c.hint(
          duration: Duration(milliseconds: 100),
          total: Duration(milliseconds: 400));
    }
    await Future.delayed(Duration(milliseconds: 400));
    for (FlipCardController c in activeFlipControllers) {
      c.hint(
          duration: Duration(milliseconds: 1),
          total: Duration(milliseconds: 4));
    }
  }

  Future<void> _enterGuess() async {
    if (_currentGuess.length != 5) {
      shakeRow();
      return;
    }

    if (!isValidWord(_currentGuess)) {
      shakeRow();
      return;
    }

    flipGuess();

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
  }

  Widget _buildWordGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < 6; i++)
          WordRow(
            controllers: _flipControllers.sublist(i * 5, (i + 1) * 5),
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

  Widget _buildKeyBoardButton(String key) {
    return LetterButton(
      letter: key,
      state: getKeyState(key, answer: _answer, guesses: _guesses),
      onTap: _addGuess,
    );
  }

  Widget _buildKeyboard() {
    //TODO även disabled om den inte är med i answer?
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
            const SizedBox(height: 60),
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

class WordRow extends StatefulWidget {
  final String answer;
  final String guess;
  final RowState state;
  final List<FlipCardController> controllers;

  const WordRow({
    Key? key,
    this.state = RowState.inactive,
    this.guess = "",
    this.answer = "",
    required this.controllers,
  }) : super(key: key);

  @override
  State<WordRow> createState() => _WordRowState();
}

class _WordRowState extends State<WordRow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int activeLetterIndex = widget.guess.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 5; i++)
          LetterBox(
            flipController: widget.controllers[i],
            state: getLetterBoxState(
              i,
              rowState: widget.state,
              activeIndex: activeLetterIndex,
              answer: widget.answer,
              guess: widget.guess,
            ),
            letter: activeLetterIndex > i ? widget.guess[i] : "",
          ),
      ],
    );
  }
}

class LetterBox extends StatelessWidget {
  final LetterBoxState state;
  final String letter;
  final FlipCardController? flipController;

  const LetterBox({
    Key? key,
    this.state = LetterBoxState.inactive,
    this.letter = "",
    this.flipController,
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

    //TODO Gör det responsivt
    Widget hidden = Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.black87,
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
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
    Widget revealed = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.all(4.0),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return FlipCard(
      controller: flipController,
      flipOnTouch: true,
      direction: FlipDirection.HORIZONTAL,
      front: hidden,
      back: revealed,
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
