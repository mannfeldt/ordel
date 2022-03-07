import 'dart:math';

import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ordel/services/game_provider.dart';
import 'package:ordel/utils/constants.dart';
import 'package:ordel/utils/utils.dart';
import 'package:ordel/widgets/letter_button.dart';
import 'package:ordel/widgets/word_grid.dart';
import 'package:provider/provider.dart';

class Gameplay extends StatefulWidget {
  final String answer;
  final List<String> extraKeys;
  final Function onFinished;
  final Size? size;
  const Gameplay({
    Key? key,
    required this.answer,
    required this.extraKeys,
    required this.onFinished,
    this.size,
  }) : super(key: key);

  @override
  State<Gameplay> createState() => _GameplayState();
}

class _GameplayState extends State<Gameplay> {
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

  FocusNode inputFocus = FocusNode();
  final String basicAlfabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  final sleepEndDuration = const Duration(seconds: 2);
  late DateTime _startTimeStamp;
  String _currentGuess = "";
  List<String> _guesses = [
    "",
    "",
    "",
    "",
    "",
    "",
  ];

  int get keyboardSize => basicAlfabet.length + widget.extraKeys.length;

  @override
  void initState() {
    inputFocus.requestFocus();

    startGame();

    MediaQueryData mq =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);

    Size size =
        widget.size ?? Size(mq.size.width, mq.size.height - mq.padding.top);

    letterBoxSize = (size.width -
            (Constants.horizontalPadding * 2) -
            (Constants.boxMargin * 10)) /
        5;

    bool tablet = size.height > 1300 && size.width > 800;
    keySize = (min(1000, tablet ? size.width - 30 : size.width) -
            (Constants.horizontalPadding / 2) -
            (Constants.keyMargin * 22)) /
        11;

    double minKeyBoardHeight = keySize * 12;
    double maxLetterBoxSize =
        (size.height - minKeyBoardHeight - (Constants.boxMargin * 10)) / 6;
    letterBoxSize = min(letterBoxSize, maxLetterBoxSize);
    super.initState();
  }

//flutter build apk --target-platform android-arm,android-arm64,android-x64

  Future<void> endGame() async {
    await toggleAll();
    widget.onFinished(_guesses, DateTime.now().difference(_startTimeStamp));
  }

  void startGame() {
    setState(() {
      _currentGuess = "";

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
        msg: "Game Over: ${widget.answer}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 15 + (keySize / 4));
  }

  Future<void> displayWinToast() async {
    await Fluttertoast.showToast(
        msg: "Correct answer!",
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
    int start = rowIndex * widget.answer.length;
    int end = start + widget.answer.length;
    for (int i = start; i < end; i++) {
      _flipControllers[i].toggleCard();
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

    if (_currentGuess == widget.answer) {
      flipRow(activeRow);
      await onGameWin();
    } else if (activeRow == widget.answer.length) {
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
        const SizedBox(height: Constants.horizontalPadding / 2),
        for (int i = 0; i < 6; i++)
          WordRow(
            boxSize: letterBoxSize,
            controllers: _flipControllers.sublist(i * 5, (i + 1) * 5),
            guess: _guesses[i].isNotEmpty
                ? _guesses[i]
                : activeRow == i
                    ? _currentGuess
                    : "",
            answer: widget.answer,
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
      size: keyboardSize > 27 ? keySize : keySize * 11 / 10,
      letter: key,
      state: getKeyState(key, answer: widget.answer, guesses: _guesses),
      onTap: _addGuess,
    );
  }

  Widget _buildKeyboard() {
    double ks = keyboardSize > 27 ? keySize : keySize * 11 / 10;

    Widget actionButtons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: (ks * 1.5) + ((Constants.keyMargin * 2)),
          height: ks * 1.3,
          child: IconButton(
            onPressed: _backSpace,
            icon: const Icon(
              Icons.backspace_outlined,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: (ks * 0.92) + ((Constants.keyMargin * 2)),
          height: ks * 1.3,
          child: IconButton(
            onPressed: () async {
              await _enterGuess();
            },
            icon: const Icon(
              Icons.send,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );

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
            if (widget.extraKeys.length > 1)
              _buildKeyBoardButton(widget.extraKeys[1]),
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
            if (widget.extraKeys.isNotEmpty)
              _buildKeyBoardButton(widget.extraKeys[0]),
            if (widget.extraKeys.length > 2)
              _buildKeyBoardButton(widget.extraKeys[2]),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.extraKeys.length <= 3) SizedBox(width: ks),
            _buildKeyBoardButton("Z"),
            _buildKeyBoardButton("X"),
            _buildKeyBoardButton("C"),
            _buildKeyBoardButton("V"),
            _buildKeyBoardButton("B"),
            _buildKeyBoardButton("N"),
            _buildKeyBoardButton("M"),
            if (widget.extraKeys.length > 3)
              _buildKeyBoardButton(widget.extraKeys[3]),
            if (widget.extraKeys.length < 5) actionButtons,
            if (widget.extraKeys.length > 4)
              ...widget.extraKeys
                  .sublist(4)
                  .map((c) => _buildKeyBoardButton(c))
                  .toList(),
          ],
        ),
        if (widget.extraKeys.length > 4) actionButtons,
        SizedBox(height: keySize * (widget.extraKeys.length > 4 ? 0 : 0.5)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: inputFocus,
      onKey: (event) async {
        if (event.runtimeType == RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            _backSpace();
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            _enterGuess();
          } else if (event.logicalKey != LogicalKeyboardKey.altLeft) {
            _addGuess(event.character.toString().toUpperCase());
          }
        }
      },
      child: Consumer<GameProvider>(
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
