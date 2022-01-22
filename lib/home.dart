import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ordel/constants.dart';
import 'package:ordel/letter_button.dart';
import 'package:ordel/models/game_round_result_model.dart';
import 'package:ordel/utils.dart';
import 'package:ordel/word_grid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

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

  void initRemoteConfig() async {
    remoteConfig = RemoteConfig.instance;
    remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: kReleaseMode
            ? const Duration(hours: 12)
            : const Duration(seconds: 60),
      ),
    );
    remoteConfig.setDefaults({
      "answers": ["BJÖRK", "AKTIE"]
    });
    await remoteConfig.fetchAndActivate();
    // maxPlayers = remoteConfig.getInt("max_players");
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

      _wordList = remoteConfig
          .getString("answers")
          .split(",")
          .where((w) => w.length == 5)
          .toList();
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
