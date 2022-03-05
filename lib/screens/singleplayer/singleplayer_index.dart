import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ordel/models/game_round_model.dart';
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
        builder: (context, gameProvider, child) => SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        Column(
                          children: [
                            Text(
                              kReleaseMode ? "Word streak" : _answer,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 20,
                              ),
                            ),
                            WinStreakText(
                              getWinStreak(Provider.of<GameProvider>(context,
                                      listen: false)
                                  .myGames),
                              size: 20,
                            ),
                          ],
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
              Positioned(
                right: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showStatsDialog(gameProvider.myGames);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showStatsDialog(List<SingleplayerGameRound> games) async {
    //skapa en map med groupby language... för att dela upp games.

    Map<String, List<SingleplayerGameRound>> languageGameMap =
        groupBy(games, (SingleplayerGameRound game) => game.language);
    //TODO grupperingen fungerar men det blir något fel..
    //TODO när man byter språk så sparas den pågående omgången med språket man byter till... fast än ordet man spelar just nu är andra språket
    //TODO fixa den buggen.
    //TODO 2. sen skicka in denna map till BasicStats och använd för att skapa upp pages.

    await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "label",
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(left: 20),
          backgroundColor: Colors.grey.shade900,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Statistics",
                style: TextStyle(color: Colors.grey.shade100),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          scrollable: true,
          content: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //TODO skapa en till första rad här som visar global RANK. den baseras på alla users topstreak.
                  BasicStats(games: games),

                  Text(
                    "Guess distribution",
                    style: TextStyle(color: Colors.grey.shade100),
                  ),
                  Column(
                    children: [
                      //TODO ta in en horizontel barchart här... räkna ut disribution utifrån alla games..
                      //TODO väldig enkel data. se screnshot taiga. barsen heter 1,2,3,4,5,6.
                    ],
                  ),
                  //TODO skapa också kanske en linjegraf över tid baserat på points.
                  //TODO behöver inte skriva ut points eller något. det är bara en trend
                  //En linje per språk kanske. kräver minst x antal games för att få vara med i grafen.
                  Text(
                    "Performance Trend",
                    style: TextStyle(color: Colors.grey.shade100),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

class BasicStats extends StatefulWidget {
  List<SingleplayerGameRound> games;
  BasicStats({Key? key, required this.games}) : super(key: key);

  @override
  State<BasicStats> createState() => _BasicStatsState();
}

class _BasicStatsState extends State<BasicStats> {
  bool _autoPlay = true;
  Widget _buildStatsRow(
      {String? label, required List<SingleplayerGameRound> games}) {
    return Column(
      children: [
        if (label != null)
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade100),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //TODO detta blir totala för alla games. skapa också en sån här rad med alla tre värdena per specifikt språk som finns spelat.
            //Räcker om det finns bara en spelad runda på språket..
            // hur visar vi upp de raderna? bara lägga dem rakt under kanske så får man scrolla. alt lägga de språkspecifka längst ned.
            //alt så kan man swipea horizontelt på raden för att swappa mellan total, en, sv etc..karusell.
            //man ser vilken man är på genom att texten i först byts bara? "Total played" "English played" "swedish played"
            //! jag tror på en lösning med toggle/swipe för att ändra på raden. inte flera rader.
            //! swipe karusell är ju snyggt men hur visar vi med UX att man kan swipea. en pil höger/vänster kanske om det går att swipea.
            //! som då också är klickbara för att trigga en swipe. så i början är vi på total. med en pil höger längst u till höger.
            //! om man klickar på den så kommer man till index 1 och kan då få en vänsterpil för att komma tillbaka på samma sätt.
            //! även ev en till höger till om det finns gåon språk till. Så kanske inte en karusell om det är svårt.
            //! eller en akrusell om det är enkelt så har vi vänster och höger pilar alltid...
            //! !!!!pageView, kolla vad som är enklast. helst en karusell med alla spelade språk. inkl små knappar vänster höger.
            _buildStatsLabel("33", "Played"),
            _buildStatsLabel("33%", "Succes"),
            _buildStatsLabel("233", "Top Streak"),
            // kolla på pageview för flera RowWidgets, en per språk.
            //  räkna ut dynamisk gruppering games per språk. och skapa en sån här rad i en pageview per sån grupp
          ],
        ),
      ],
    );
  }

  Widget _buildStatsLabel(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 1.125,
            color: Colors.grey.shade100,
          ),
        ),
        SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        onPageChanged: (int page, CarouselPageChangedReason reason) {
          if (reason == CarouselPageChangedReason.manual) {
            setState(() {
              _autoPlay = false;
            });
          }
        },
        height: 70.0,
        viewportFraction: 1.0,
        autoPlay: _autoPlay,
      ),
      items: [1, 2, 3].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return _buildStatsRow(label: "språk $i", games: widget.games);
          },
        );
      }).toList(),
    );
  }
}
