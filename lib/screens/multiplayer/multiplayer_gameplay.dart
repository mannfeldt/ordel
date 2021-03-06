import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/models/language_model.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/screens/multiplayer/widgets/multiplayer_game_load_controller.dart';
import 'package:ordel/screens/multiplayer/widgets/multiplayer_game_standings.dart';
import 'package:ordel/services/game_provider.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/utils/utils.dart';
import 'package:ordel/widgets/gameplay.dart';
import 'package:ordel/widgets/loader.dart';
import 'package:ordel/widgets/word_grid.dart';
import 'package:provider/provider.dart';

class MultiplayerGameplayScreen extends StatelessWidget {
  final String gameId;
  const MultiplayerGameplayScreen({Key? key, required this.gameId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<MultiplayerProvider, UserProvider>(
        builder: (context, multiplayerProvider, userProvider, child) => Loader(
          controller: GameplayLoadController(
            multiplayerProvider,
            userProvider,
            gameId,
            MediaQuery.of(context),
          ),
          result: MultiplayerGameplay(
            game: multiplayerProvider.activeGame ?? MultiplayerGame.empty(),
            activeUser: userProvider.activeUser!,
            otherUser: userProvider.getUserById(multiplayerProvider
                        .activeGame?.playerUids
                        .firstWhere((p) => p != userProvider.activeUser!.uid) ??
                    userProvider.activeUser!.uid) ??
                User.empty(),
          ),
        ),
      ),
    );
  }
}

class MultiplayerGameplay extends StatefulWidget {
  final MultiplayerGame game;
  final User activeUser;
  final User otherUser;

  const MultiplayerGameplay({
    Key? key,
    required this.game,
    required this.activeUser,
    required this.otherUser,
  }) : super(key: key);

  @override
  State<MultiplayerGameplay> createState() => _MultiplayerGameplayState();
}

class _MultiplayerGameplayState extends State<MultiplayerGameplay> {
  late RemoteConfig remoteConfig;

  List<String> _wordList = [];
  List<Language> _supportedLanguages = [];
  late Language _language;
  final String basicAlfabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  List<String> _extraCharacters = [];
  late Size _gamePlaySize;

  final sleepEndDuration = const Duration(seconds: 2);

  void initLanguages() {
    setState(() {
      _supportedLanguages = remoteConfig
          .getString("supported_languages")
          .split(",")
          .toList()
          .map((l) => Language(l.split(":").first, l.split(":").last))
          .toList();
      _language = _supportedLanguages.firstWhere(
          (l) => l.code == widget.game.language,
          orElse: () => _supportedLanguages.first);

      _wordList = remoteConfig
          .getString("answers_${_language.code}")
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
    });
  }

  @override
  void initState() {
    remoteConfig = RemoteConfig.instance;
    initLanguages();
    MediaQueryData mq =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    _gamePlaySize = Size(mq.size.width, mq.size.height - mq.padding.top);
    super.initState();
  }

//flutter build apk --target-platform android-arm,android-arm64,android-x64

  Future<void> _onGameFinished(User currentUser) async {
    MultiplayerProvider provider =
        Provider.of<MultiplayerProvider>(context, listen: false);
    provider.finishGame();

    await showGeneralDialog<String>(
      barrierDismissible: false,
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            "Game finished",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              MultiplayerGameStandings(
                game: widget.game,
                activeUser: widget.activeUser,
                otherUser: widget.otherUser,
                size: Size(_gamePlaySize.width - 80, _gamePlaySize.height),
              ),
              TextButton(
                onPressed: () async {
                  // Navigator.pop(context); //beh??vs?
                  AppRouter.navigateTo(
                    context,
                    "${AppRouter.SETUP_WORD_SCREEN}?language=${widget.game.language}&invite=${widget.game.playerUids.firstWhere((p) => p != currentUser.uid)}",
                    replace: true,
                    // clearStack: true,
                    transition: TransitionType.inFromBottom,
                  );
                },
                child: Container(
                  child: Text(
                    "Rematch",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(color: Colors.white, width: 2.0)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  AppRouter.navigateTo(
                    context,
                    AppRouter.SETUP_LANGUAGE_SCREEN,
                    replace: true,
                    // clearStack: true, //! clearstack replace?
                    transition: TransitionType.inFromBottom,
                  );
                },
                child: Container(
                  child: Text(
                    "New Game",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(color: Colors.white, width: 2.0)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  AppRouter.navigateTo(
                    context,
                    AppRouter.MULTIPLAYER_TAB,
                    replace: true,
                    // clearStack: true,
                  );
                },
                child: Container(
                  child: Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(color: Colors.white, width: 2.0)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onRoundFinished(
      List<String> guesses, Duration duration, BuildContext context) async {
    MultiplayerProvider provider =
        Provider.of<MultiplayerProvider>(context, listen: false);
    provider.saveRound(guesses, duration);

    if (widget.game.isFinished) {
      _onGameFinished(provider.currentUser!);
    } else {
      await _startNewRound(context);
    }
  }

  Future<void> _startNewRound(BuildContext context) async {
    MultiplayerProvider provider =
        Provider.of<MultiplayerProvider>(context, listen: false);
    String? newWord = await showGeneralDialog<String>(
      barrierDismissible: false,
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        MediaQueryData mq = MediaQuery.of(context);
        double size = ((mq.size.width - 200) / 5);
        final List<String> _words = [];
        List<String> wordList = RemoteConfig.instance
            .getString("answers_${widget.game.language}")
            .split(",")
            .where((w) => w.length == 5)
            .toList();
        Random _random = Random();
        while (_words.length < 3) {
          String randomWord = wordList[_random.nextInt(wordList.length)];
          if (!_words.contains(randomWord)) {
            _words.add(randomWord);
          }
        }
        return WillPopScope(
          onWillPop: () async => true,
          child: SafeArea(
            child: AlertDialog(
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              title: Text(
                "Select next word",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.grey.shade900,
              content: Column(
                mainAxisSize: MainAxisSize.max,
                children: _words
                    .map(
                      (word) => Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          width: double.infinity,
                          child: MaterialButton(
                            elevation: 0,
                            focusElevation: 4,
                            highlightColor: Colors.grey.shade900,
                            splashColor: Colors.grey.shade900,
                            color: Colors.grey.shade900,
                            onPressed: () => Navigator.pop(context, word),
                            child: Center(
                              child: IgnorePointer(
                                child: WordRow(
                                  boxSize: size,
                                  answer: word,
                                  guess: word,
                                  state: RowState.done,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
    if (newWord != null) {
      await provider.startNewRound(newWord);
      AppRouter.navigateTo(
        context,
        AppRouter.MULTIPLAYER_TAB,
        replace: true,
        // clearStack: true,
        transition: TransitionType.inFromBottom,
      );
    }
  }

  Widget _buildLanguageIcon(Language? lang) {
    return Image.asset(
      "assets/img/${lang?.code ?? "unknown"}.png",
      height: 30,
      errorBuilder: (context, error, stackTrace) => Text(
        lang?.code ?? "unknown",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    GameRound activeRound = widget.game.activeGameRound;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Consumer<GameProvider>(
        builder: (context, gameProvide, child) => SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: MultiplayerGameStandings(
                      game: widget.game,
                      activeUser: widget.activeUser,
                      otherUser: widget.otherUser,
                      size: _gamePlaySize,
                    ),
                  ),
                  Gameplay(
                    answer: activeRound.answer,
                    extraKeys: _extraCharacters,
                    onFinished: (List<String> guesses, Duration duration) =>
                        _onRoundFinished(guesses, duration, context),
                    size: _gamePlaySize,
                  ),
                ],
              ),
              Container(
                alignment: Alignment.topCenter,
                child: _buildLanguageIcon(_language),
              ),
              if (!kReleaseMode)
                Container(
                  alignment: Alignment.topRight,
                  child: Text(
                    activeRound.answer,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
