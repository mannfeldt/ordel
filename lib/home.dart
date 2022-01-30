import 'dart:math';
import 'dart:ui';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ordel/constants.dart';
import 'package:ordel/game_provider.dart';
import 'package:ordel/letter_button.dart';
import 'package:ordel/loader.dart';
import 'package:ordel/models/language_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/score_loading_controller.dart';
import 'package:ordel/utils.dart';
import 'package:ordel/word_grid.dart';
import 'package:provider/provider.dart';

class SinglePlayerScreen extends StatefulWidget {
  final String userLanguage;
  const SinglePlayerScreen({Key? key, required this.userLanguage})
      : super(key: key);

  @override
  State<SinglePlayerScreen> createState() => _SinglePlayerScreenState();
}

class _SinglePlayerScreenState extends State<SinglePlayerScreen> {
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
  List<Language> _supportedLanguages = [];
  Language? _language;
  List<FlipCardController> get activeFlipControllers =>
      getFlipControllers(activeRow);

  List<FlipCardController> getFlipControllers(int row) {
    return _flipControllers.sublist(row * 5, (row + 1) * 5);
  }

  FocusNode inputFocus = FocusNode();
  final String basicAlfabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  List<String> _extraCharacters = [];
  List<String> _excludedCharacters = [];

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

  int get keyboardSize => basicAlfabet.length + _extraCharacters.length;

  bool get isSwedish => _language?.code == "sv";

  void initLanguages() {
    setState(() {
      _supportedLanguages = remoteConfig
          .getString("supported_languages")
          .split(",")
          .toList()
          .map((l) => Language(l.split(":").first, l.split(":").last))
          .toList();
      _language = _supportedLanguages.firstWhere(
          (l) => l.code == (_language?.code ?? widget.userLanguage),
          orElse: () => _supportedLanguages.first);

      _wordList = remoteConfig
          .getString("answers_${_language?.code}")
          .split(",")
          .where((w) => w.length == 5)
          .toList();

      final List<String> uniqueChars = [];
      for (String word in _wordList) {
        for (String letter in word.characters) {
          if (!uniqueChars.contains(letter)) {
            uniqueChars.add(letter);
          }
        }
      }
      _extraCharacters =
          uniqueChars.where((c) => !basicAlfabet.contains(c)).toList();

      _excludedCharacters = basicAlfabet.characters
          .where((c) => uniqueChars.contains(c))
          .toList();
    });
  }

  @override
  void initState() {
    inputFocus.requestFocus();
    remoteConfig = RemoteConfig.instance;
    initLanguages();

    startGame();

    MediaQueryData mq =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    letterBoxSize = (mq.size.width -
            (Constants.horizontalPadding * 2) -
            (Constants.boxMargin * 10)) /
        5;

    keySize = (mq.size.width -
            (Constants.horizontalPadding / 2) -
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
        language: _language!.code);
    await toggleAll();
  }

  void startGame() {
    setState(() {
      _currentGuess = "";

      _answer = _wordList[Random().nextInt(_wordList.length)];
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

  void _logOut() async {
    Navigator.pushReplacementNamed(context, '/sign-in');
    await Provider.of<GameProvider>(context).logOut();
  }

  Widget _buildWordGrid() {
    return Column(
      children: [
        const SizedBox(height: Constants.horizontalPadding / 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kReleaseMode ? "Ordel" : _answer,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: letterBoxSize / 2,
              ),
            ),
            if (!kReleaseMode)
              TextButton(onPressed: _logOut, child: Text("logout")),
          ],
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
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return ScoreDialog();
                    },
                  );
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
      size: keyboardSize > 27 ? keySize : keySize * 11 / 10,
      letter: key,
      state: getKeyState(key, answer: _answer, guesses: _guesses),
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
              color: Colors.white,
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
            if (_extraCharacters.length > 1)
              _buildKeyBoardButton(_extraCharacters[1]),
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
            if (_extraCharacters.isNotEmpty)
              _buildKeyBoardButton(_extraCharacters[0]),
            if (_extraCharacters.length > 2)
              _buildKeyBoardButton(_extraCharacters[2]),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_extraCharacters.length <= 3) SizedBox(width: ks),
            _buildKeyBoardButton("Z"),
            _buildKeyBoardButton("X"),
            _buildKeyBoardButton("C"),
            _buildKeyBoardButton("V"),
            _buildKeyBoardButton("B"),
            _buildKeyBoardButton("N"),
            _buildKeyBoardButton("M"),
            if (_extraCharacters.length > 3)
              _buildKeyBoardButton(_extraCharacters[3]),
            if (_extraCharacters.length < 5) actionButtons,
            if (_extraCharacters.length > 4)
              ..._extraCharacters
                  .sublist(4)
                  .map((c) => _buildKeyBoardButton(c))
                  .toList(),
          ],
        ),
        if (_extraCharacters.length > 4) actionButtons,
        SizedBox(height: keySize * (_extraCharacters.length > 4 ? 0 : 1)),
      ],
    );
  }

  Widget _buildLanguageIcon(Language? lang) {
    return Image.asset(
      "assets/img/${lang?.code ?? "unknown"}.png",
      errorBuilder: (context, error, stackTrace) => Text(
        lang?.code ?? "unknown",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: RawKeyboardListener(
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
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWordGrid(),
                    _buildKeyboard(),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: PopupMenuButton<Language>(
                    icon: _buildLanguageIcon(_language),
                    onSelected: (Language? newValue) {
                      if (_language != newValue) {
                        Fluttertoast.showToast(
                            msg: "Next word will be ${newValue?.name}",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black87,
                            textColor: Colors.white,
                            fontSize: 15 + (keySize / 4));
                      }
                      setState(() {
                        _language = newValue!;
                      });
                      initLanguages();
                    },
                    itemBuilder: (BuildContext context) {
                      return _supportedLanguages.map((Language choice) {
                        return PopupMenuItem<Language>(
                          value: choice,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(choice.name),
                              Container(
                                padding: const EdgeInsets.only(left: 10),
                                width: letterBoxSize,
                                child: _buildLanguageIcon(choice),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                Positioned(
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/profile');
                    },
                    icon: const Icon(Icons.person_pin, color: Colors.white),
                  ),
                ),
              ],
            ),
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

//TODO hela denna ska flyttas till leadboard tabben
class ScoreDialog extends StatelessWidget {
  const ScoreDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) => Loader(
        controller: ScoreLoadingController(provider),
        result: Material(
          type: MaterialType.transparency,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.black87,
                ),
                child: Column(
                  children: [
                    Text(
                      "total games played: ${provider.allGames.length}",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "my games played: ${provider.myGames.length}",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    GameStreakList(
                        provider.getUserLeaderBoard(provider.currentUser!.uid)),
                    const SizedBox(height: 10),
                    // LeaderBoard(provider.leaderboard, provider.users,
                    //     provider.currentUser!.uid),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("close"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameStreakList extends StatelessWidget {
  final List<List<GameRound>> streaks;
  const GameStreakList(this.streaks, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text(
        "My top streaks",
        style: TextStyle(color: Colors.white),
      ),
      ...streaks
          .map(
            (streak) => ListTile(
              title: Text(
                "${streak.length}",
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Text(
                DateFormat(DateFormat.YEAR_MONTH_DAY).format(streak.last.date),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
          .toList(),
    ]);
  }
}

class LeaderBoard extends StatelessWidget {
  final List<List<GameRound>> leaderboard;
  final List<User> users;

  final String activeUser;
  const LeaderBoard(this.leaderboard, this.users, this.activeUser, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int activeUserTopRanking =
        leaderboard.indexWhere((streak) => streak.first.user == activeUser);
    List<GameRound> activeUserTopGame = leaderboard[activeUserTopRanking];
    final List<List<GameRound>> cut =
        leaderboard.sublist(0, min(10, leaderboard.length));

    return ListView(
      shrinkWrap: true,
      children: [
        const Text(
          "Leaderboard",
          style: TextStyle(color: Colors.white),
        ),
        ...cut
            .map(
              (streak) => ListTile(
                selected: streak.first.user == activeUser,
                title: Text(
                  "${streak.length} ${users.firstWhere((u) => u.uid == streak.first.user, orElse: () => User.empty(displayname: "Unknown")).displayname}",
                  style: TextStyle(
                      color: streak.first.user == activeUser
                          ? Colors.green
                          : Colors.white),
                ),
                trailing: Text(
                  DateFormat(DateFormat.YEAR_MONTH_DAY)
                      .format(streak.last.date),
                  style: TextStyle(
                      color: streak.first.user == activeUser
                          ? Colors.green
                          : Colors.white),
                ),
              ),
            )
            .toList(),
        if (activeUserTopRanking > 9)
          Column(
            children: [
              const Divider(color: Colors.white),
              ListTile(
                tileColor: Colors.green,
                leading: Text("..${activeUserTopRanking + 1}"),
                title: Text(
                  "${activeUserTopGame.length} ${activeUser}",
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  activeUserTopGame.last.date.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
