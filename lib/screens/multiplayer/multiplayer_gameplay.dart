import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/models/language_model.dart';
import 'package:ordel/models/multiplayer_game_model.dart';
import 'package:ordel/screens/multiplayer/widgets/multiplayer_game_load_controller.dart';
import 'package:ordel/services/game_provider.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/gameplay.dart';
import 'package:ordel/widgets/loader.dart';
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
            game: multiplayerProvider.activeGame,
          ),
        ),
      ),
    );
  }
}

class MultiplayerGameplay extends StatefulWidget {
  final MultiplayerGame game;
  //TODO används för att visa lite ställnign osv i headern.. skapa en getter som hämtar activeRound och släng in det i gameplay..
  //Språk hämtar vi härifrån också

  const MultiplayerGameplay({Key? key, required this.game}) : super(key: key);

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

  Future<void> _onRoundFinished(List<String> guesses, Duration duration) async {
    //TODO när rundan är klar så ska vi visa dialog om att välja nytt ord och sen skicka det till nästa spelare.
    //TODO eller om det är finished nu så spara och visa slutresultatet.
    //_language.code blir fel. måste ha en currentRoundLanguage också?
    //så man inte kan ändra mitt i gamet..
    // await Provider.of<GameProvider>(context, listen: false).createGame(
    //     answer: _answer,
    //     guesses: guesses,
    //     duration: duration,
    //     language: _currentRoundLanguage.code);
    // initLanguages();

    // setState(() {
    //   _answer = _wordList[Random().nextInt(_wordList.length)];
    // });
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
    GameRound activeRound = widget.game.activeRound;
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Consumer<GameProvider>(
        builder: (context, gameProvide, child) => SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLanguageIcon(_language),
                      Text(
                        kReleaseMode ? "Ordel" : activeRound.answer,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Gameplay(
                    language: _language,
                    answer: activeRound.answer,
                    extraKeys: _extraCharacters,
                    onFinished: _onRoundFinished,
                    size: _gamePlaySize,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
