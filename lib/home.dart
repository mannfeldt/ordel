import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ordel/constants.dart';
import 'package:ordel/game_provider.dart';
import 'package:ordel/letter_button.dart';
import 'package:ordel/utils.dart';
import 'package:ordel/word_grid.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double letterBoxSize;
  late double keySize;
  late RemoteConfig remoteConfig;

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

  List<String> _wordList = [];
  List<FlipCardController> get activeFlipControllers =>
      getFlipControllers(activeRow);

  List<FlipCardController> getFlipControllers(int row) {
    return _flipControllers.sublist(row * 5, (row + 1) * 5);
  }

  final sleepEndDuration = const Duration(seconds: 2);
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

  @override
  void initState() {
    remoteConfig = RemoteConfig.instance;
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
//flutter build apk --target-platform android-arm,android-arm64,android-x64
// todo här
  //visa total stats kring vilken rank man har. bästa rundan osv.
  //! när detta är på plats finns det lite att spela för och då är vi redo för att releasea version till play store.
  //TODO vidare: lägg till stöd för flera språk. Ett språk har en KeyboardConfig som definerar vilka bokstäver som är på vilken rad
  //TODO inkl var enter och delete är? Språket styr också vilken remoteconfig paramter vi hämtar upp för answers.
  //TODO vi sprar språk till roundHistory också.
  //TODO också en referens till en sråkfil. en json/property fil likt vi använder i pelabs. translations.dart kopiera rakt av typ.
  //Tror jag kör allt på engelska tillsvidare dock.

  //skapa en Provider och klient för detta. Flytta upp _currentHistorik och _allHistorik dit
  //när man är klar med en runda så läggs det till i provider.currentHistorik osv.
  //Kolla lite på Bloc Clean architecture etc. använd det?

  Future<void> endGame() async {
    Provider.of<GameProvider>(context, listen: false).createGame(
      answer: _answer,
      guesses: _guesses,
      duration: DateTime.now().difference(_startTimeStamp),
    );
    await toggleAll();
  }

  void startGame() {
    setState(() {
      _currentGuess = "";

      _wordList = remoteConfig
          .getString("answers")
          .split(",")
          .where((w) => w.length == 5)
          .toList();
      _answer = _wordList[Random().nextInt(_wordList.length - 1)];
      print(_answer);
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
    int filledRows = activeRow;
    if (filledRows < 2) {
      await Future.delayed(const Duration(milliseconds: 1200));
    }
    for (int i = 0; i < filledRows; i++) {
      await flipRow(i);
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  int get activeRow {
    int row = _guesses.indexWhere((g) => g.isEmpty);
    return row == -1 ? _guesses.length : row;
  }

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
        msg: "Game Over: $_answer",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 15 + (keySize / 4));
  }

  Future<void> displayWinToast() async {
    await Fluttertoast.showToast(
        msg: "You Won!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 15 + (keySize / 4));
  }

  Future<void> newRound() async {
    setState(() {
      _guesses[activeRow] = _currentGuess;
      _currentGuess = "";
    });
    await endGame();
    startGame();
  }

  Future<void> flipRow(int rowIndex) async {
    int start = rowIndex * _answer.length;
    int end = start + _answer.length;
    for (int i = start; i < end; i++) {
      _flipControllers[i].toggleCard();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Future<void> flipGuess() async {
  //   for (FlipCardController c in activeFlipControllers) {
  //     c.toggleCard();
  //     await Future.delayed(const Duration(milliseconds: 100));
  //   }
  // }

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
      flipRow(activeRow);
      await onGameWin();
    } else if (activeRow == _answer.length) {
      flipRow(activeRow);
      await onGameOver();
    } else {
      flipRow(activeRow);
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
                getWinStreak(
                    Provider.of<GameProvider>(context, listen: false).myGames),
                size: keySize,
              ),
              IconButton(
                onPressed: () {
                  Provider.of<GameProvider>(context, listen: false).loadGames();
                },
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
      body: Consumer<GameProvider>(
        builder: (context, gameProvide, child) => SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWordGrid(),
              _buildKeyboard(),
            ],
          ),
        ),
      ),
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
