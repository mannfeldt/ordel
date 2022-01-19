import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ordel/constants.dart';
import 'package:ordel/models/game_round_result_model.dart';
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

// todo
// lägg till responsivitet.
// lägg till streaks. skapa en gameResult model som innehåller all möjlig info.. hur många gissningar det tog åtminstone.

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
  late double letterBoxSize;
  late double keySize;

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

  final sleepEndDuration = const Duration(seconds: 2);
  final List<GameRoundResult> _gameHistory = [];
  late DateTime _startTimeStamp;
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

  //1. blinkande sträckade linjen visas inte längre? efter rad 4... kan inte riktigt återskapa
  // 2.efer att gameover så ser det lite konstigt ut med att alltblir grått först?
  // kan helst vara svar vid gameover tills flippen kommer och då blir de svar/grått för alla inaktiva rader.
  // 3.vid win också lite konstigt med att nästa rad blir svart. borde fortsatt vara grå inget nytt.
  // allt detta borde gå att lösa med att sätta rätt state vid rätt tid..
  //4. streak verkar inte räkna rätt. se kommentar ovan fixa testfall
  @override
  void initState() {
    startGame();
    MediaQueryData mq =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    letterBoxSize = (mq.size.width -
            (Constants.horizontalPadding * 2) -
            (Constants.boxMargin * 10)) /
        5;

    keySize = (mq.size.width -
            (Constants.horizontalPadding) -
            (Constants.keyMargin * 22)) /
        11;
    double minKeyBoardHeight = keySize * 10;
    double screenHeight = (mq.size.height - mq.padding.top);
    double maxLetterBoxSize =
        (screenHeight - minKeyBoardHeight - (Constants.boxMargin * 10)) / 6;
    letterBoxSize = min(letterBoxSize, maxLetterBoxSize);
    super.initState();
  }

  Future<void> endGame() async {
    setState(() {
      _gameHistory.add(GameRoundResult(
        answer: _answer,
        guesses: _guesses,
        duration: _startTimeStamp.difference(DateTime.now()),
      ));
    });
    await toggleAll();
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
      _startTimeStamp = DateTime.now();
    });
  }

  Future<void> toggleAll() async {
    for (var c in _flipControllers) {
      c.toggleCard();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  int get activeRow => _guesses.indexWhere((g) => g.isEmpty);

  void _addGuess(String letter) {
    if (_currentGuess.length == 5) return;
    setState(() {
      _currentGuess = _currentGuess + letter;
    });
  }

  void _backSpace() {
    if (_currentGuess.isEmpty) return;
    setState(() {
      _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
    });
  }

  bool isValidWord(String word) {
    return true;
  }

  Future<void> displayLoseToast() async {
    await Fluttertoast.showToast(
        msg: "Game Over",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 14 + (keySize / 4));
  }

  Future<void> displayWinToast() async {
    await Fluttertoast.showToast(
        msg: "You Won!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14 + (keySize / 4));
  }

  Future<void> newRound() async {
    await endGame();
    setState(() {
      _guesses[activeRow] = _currentGuess;
      _currentGuess = "";
    });
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
          duration: const Duration(milliseconds: 120),
          total: const Duration(milliseconds: 400));
    }
    await Future.delayed(const Duration(milliseconds: 400));
    for (FlipCardController c in activeFlipControllers) {
      c.hint(
          duration: const Duration(milliseconds: 1),
          total: const Duration(milliseconds: 4));
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

    if (_currentGuess == _answer) {
      await onGameWin();
    } else if (activeRow == _answer.length) {
      await onGameOver();
    } else {
      flipGuess();
      setState(() {
        _guesses[activeRow] = _currentGuess;
        _currentGuess = "";
      });
    }
  }

  Future<void> onGameOver() async {
    await displayLoseToast();
    await newRound();
  }

  Future<void> onGameWin() async {
    await displayWinToast();
    await newRound();
  }

  Widget _buildWordGrid() {
    return Column(
      children: [
        const SizedBox(height: Constants.horizontalPadding / 3),
        Text(
          "Ordel",
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: letterBoxSize / 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.help,
                  color: Colors.white,
                ),
              ),
              WinStreakText(
                getWinStreak(_gameHistory),
                size: keySize,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        for (int i = 0; i < 6; i++)
          WordRow(
            boxSize: letterBoxSize,
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
      size: keySize,
      letter: key,
      state: getKeyState(key, answer: _answer, guesses: _guesses),
      onTap: _addGuess,
    );
  }

  Widget _buildKeyboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
        const SizedBox(height: Constants.keyMargin),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
        const SizedBox(height: Constants.keyMargin),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: keySize + (Constants.keyMargin * 2)),
            _buildKeyBoardButton("Z"),
            _buildKeyBoardButton("X"),
            _buildKeyBoardButton("C"),
            _buildKeyBoardButton("V"),
            _buildKeyBoardButton("B"),
            _buildKeyBoardButton("N"),
            _buildKeyBoardButton("M"),
            SizedBox(
              width: (keySize * 1.5) + ((Constants.keyMargin * 2)),
              height: keySize * 1.3,
              //Höjden på dessa som stälelr till det? mer space vertikalt till sista raden.
              child: IconButton(
                onPressed: _backSpace,
                icon: const Icon(
                  Icons.backspace_outlined,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: (keySize * 1.5) + ((Constants.keyMargin * 2)),
              height: keySize * 1.3,
              child: IconButton(
                onPressed: () async {
                  await _enterGuess();
                },
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: keySize * 2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
  final double size;
  const LetterButton({
    Key? key,
    required this.onTap,
    required this.letter,
    required this.size,
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
      margin: const EdgeInsets.all(Constants.keyMargin),
      height: size * 1.3,
      width: size,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color,
          primary: Colors.white,
          textStyle: TextStyle(
            fontSize: size / 2,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(letter),
        onPressed: state != KeyState.wrong ? () => onTap(letter) : () {},
      ),
    );
  }
}

class WordRow extends StatefulWidget {
  final String answer;
  final String guess;
  final RowState state;
  final List<FlipCardController> controllers;
  final double boxSize;

  const WordRow({
    Key? key,
    this.state = RowState.inactive,
    this.guess = "",
    this.answer = "",
    required this.boxSize,
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
            size: widget.boxSize,
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

class WinStreakText extends StatelessWidget {
  final int streak;
  final double size;
  const WinStreakText(this.streak, {Key? key, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "$streak",
      style: TextStyle(
        fontSize: size,
        color: streak > 0 ? Colors.green : Colors.white,
      ),
    );
  }
}

class LetterBox extends StatelessWidget {
  final LetterBoxState state;
  final String letter;
  final FlipCardController? flipController;
  final double size;

  const LetterBox({
    Key? key,
    required this.size,
    this.state = LetterBoxState.inactive,
    this.letter = "",
    this.flipController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Color boxColor;
    late Color boxColorHidden;
    switch (state) {
      case LetterBoxState.inactive:
        boxColor = Colors.grey.shade600;
        boxColorHidden = Colors.grey.shade600;
        break;
      case LetterBoxState.active:
        boxColor = Colors.black87;
        boxColorHidden = Colors.black87;
        break;
      case LetterBoxState.focused:
        boxColor = Colors.black87;
        boxColorHidden = Colors.black87;

        break;
      case LetterBoxState.wrong:
        boxColor = Colors.blueGrey.shade900;
        boxColorHidden = Colors.black87;

        break;
      case LetterBoxState.included:
        boxColor = Colors.purple;
        boxColorHidden = Colors.black87;

        break;
      case LetterBoxState.correct:
        boxColor = Colors.green;
        boxColorHidden = Colors.black87;

        break;
      default:
    }

    Widget hidden = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: boxColorHidden,
        borderRadius: BorderRadius.all(Radius.circular(2 + (size / 10))),
      ),
      padding: const EdgeInsets.all(Constants.boxMargin),
      margin: const EdgeInsets.all(Constants.boxMargin),
      child: state == LetterBoxState.focused
          ? Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.symmetric(
                horizontal: size / 6,
                vertical: size / 12,
              ),
              child: const BlinkingUnderline(),
            )
          : Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: size / 2,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
    Widget revealed = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.all(Radius.circular(2 + (size / 10))),
      ),
      padding: const EdgeInsets.all(Constants.boxMargin),
      margin: const EdgeInsets.all(Constants.boxMargin),
      child: state == LetterBoxState.focused
          ? Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.symmetric(
                horizontal: size / 6,
                vertical: size / 12,
              ),
              child: const BlinkingUnderline(),
            )
          : Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: size / 2,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );

    return FlipCard(
      controller: flipController,
      flipOnTouch: true,
      speed: 500,
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
