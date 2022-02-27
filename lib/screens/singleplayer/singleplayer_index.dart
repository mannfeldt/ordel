import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ordel/models/language_model.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/services/game_provider.dart';
import 'package:ordel/services/session_provider.dart';
import 'package:ordel/utils/constants.dart';
import 'package:ordel/utils/utils.dart';
import 'package:ordel/widgets/gameplay.dart';
import 'package:provider/provider.dart';

class SingleplayerScreen extends StatefulWidget {
  final String sessionLanguageCode;
  const SingleplayerScreen({Key? key, required this.sessionLanguageCode})
      : super(key: key);

  @override
  State<SingleplayerScreen> createState() => _SingleplayerScreenState();
}

class _SingleplayerScreenState extends State<SingleplayerScreen> {
  late RemoteConfig remoteConfig;

  List<String> _wordList = [];
  List<Language> _supportedLanguages = [];
  Language? _language;
  late Language _currentRoundLanguage;
  final String basicAlfabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  List<String> _extraCharacters = [];
  // List<String> _excludedCharacters = [];
  late Size _gamePlaySize;

  final sleepEndDuration = const Duration(seconds: 2);
  String _answer = "";

  void initLanguages() {
    setState(() {
      _supportedLanguages = remoteConfig
          .getString("supported_languages")
          .split(",")
          .toList()
          .map((l) => Language(l.split(":").first, l.split(":").last))
          .toList();
      _language = _supportedLanguages.firstWhere(
          (l) => l.code == (_language?.code ?? widget.sessionLanguageCode),
          orElse: () => _supportedLanguages.first);
      _currentRoundLanguage = _language!;

      _wordList = remoteConfig
          .getString("answers_${_currentRoundLanguage.code}")
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

      // _excludedCharacters = basicAlfabet.characters
      //     .where((c) => uniqueChars.contains(c))
      //     .toList();
    });
  }

  @override
  void initState() {
    remoteConfig = RemoteConfig.instance;
    initLanguages();
    _answer = _wordList[Random().nextInt(_wordList.length)];
    MediaQueryData mq =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    _gamePlaySize = Size(mq.size.width, mq.size.height - mq.padding.top);
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

  Future<void> _onRoundFinished(List<String> guesses, Duration duration) async {
    //_language.code blir fel. måste ha en currentRoundLanguage också?
    //så man inte kan ändra mitt i gamet..
    await Provider.of<GameProvider>(context, listen: false).createGame(
        answer: _answer,
        guesses: guesses,
        duration: duration,
        language: _currentRoundLanguage.code);
    initLanguages();

    setState(() {
      _answer = _wordList[Random().nextInt(_wordList.length)];
    });
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
      key: AppRouter.singleplayerScreenKey,
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
                      Text(
                        kReleaseMode ? "Word streak" : _answer,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Constants.horizontalPadding / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.help,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        WinStreakText(
                          getWinStreak(
                              Provider.of<GameProvider>(context, listen: false)
                                  .myGames),
                          size: 20,
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Gameplay(
                    language: _currentRoundLanguage,
                    answer: _answer,
                    extraKeys: _extraCharacters,
                    onFinished: _onRoundFinished,
                    size: _gamePlaySize,
                  ),
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
                          fontSize: 30);
                      Provider.of<SessionProvider>(context, listen: false)
                          .setLanguage(newValue);
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
                              width: 28,
                              child: _buildLanguageIcon(choice),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
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
