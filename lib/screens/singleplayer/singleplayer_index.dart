import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/models/language_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/screens/singleplayer/rank_load_controller.dart';
import 'package:ordel/services/game_provider.dart';
import 'package:ordel/services/session_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/utils/constants.dart';
import 'package:ordel/utils/utils.dart';
import 'package:ordel/widgets/gameplay.dart';
import 'package:ordel/widgets/loader.dart';
import 'package:ordel/widgets/word_grid.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  int _currentWinStreak = 0;
  final sleepEndDuration = const Duration(seconds: 2);
  String _answer = "";
  bool _hasGuessed = false;

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
    _currentWinStreak =
        getWinStreak(Provider.of<GameProvider>(context, listen: false).myGames);
    super.initState();
  }

  void _startNewRound() {
    initLanguages();

    setState(() {
      _hasGuessed = false;
      _currentWinStreak = getWinStreak(
          Provider.of<GameProvider>(context, listen: false).myGames);
      _answer = _wordList[Random().nextInt(_wordList.length)];
    });
  }

  Future<void> _onRoundFinished(List<String> guesses, Duration duration) async {
    await Provider.of<GameProvider>(context, listen: false).createGame(
        answer: _answer,
        guesses: guesses,
        duration: duration,
        language: _currentRoundLanguage.code);

    _startNewRound();

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    User? user = userProvider.activeUser;
    if (user != null && _currentWinStreak > user.topStreak) {
      userProvider.updateTopStreak(_currentWinStreak);
    }
  }

  void _onGuess(String guess) {
    setState(() {
      _hasGuessed = true;
    });
  }

  void _languageChanged(Language? language) {
    if (_language != language) {
      Provider.of<SessionProvider>(context, listen: false)
          .setLanguage(language);
      if (_hasGuessed) {
        Fluttertoast.showToast(
            msg: "Next word will be ${language?.name}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 30);
      } else {
        setState(() {
          _language = language!;
        });
        _startNewRound();
      }
    }
    setState(() {
      _language = language!;
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
                    child: Column(
                      children: [
                        Text(
                          kReleaseMode ? "Word streak" : _answer,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 20,
                          ),
                        ),
                        WinStreakText(
                          getWinStreak(
                              Provider.of<GameProvider>(context, listen: false)
                                  .myGames),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  Gameplay(
                    onGuess: _onGuess,
                    answer: _answer,
                    extraKeys: _extraCharacters,
                    onFinished: _onRoundFinished,
                    size: _gamePlaySize,
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.help,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showHelpDialog();
                      },
                    ),
                    PopupMenuButton<Language>(
                      icon: _buildLanguageIcon(_language),
                      onSelected: _languageChanged,
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
                  ],
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
                    showStatsDialog(
                        gameProvider.myGames, gameProvider.currentUser);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showHelpDialog() async {
    await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "help",
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(left: 20),
          backgroundColor: Colors.grey.shade900,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "How to play",
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
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Guess the correct word in six tries.",
                    style: TextStyle(
                      color: Colors.grey.shade100,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "After each guess you will get clues.",
                    style: TextStyle(
                      color: Colors.grey.shade100,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Example",
                    style: TextStyle(
                      color: Colors.grey.shade100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  WordRow(
                    boxSize: (_gamePlaySize.width - 180) / 5,
                    answer: "XOVXX",
                    defaultFlipped: true,
                    state: RowState.done,
                    guess: "SOLVE",
                  ),
                  SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey.shade100,
                        fontSize: 16,
                      ),
                      children: const [
                        TextSpan(
                          text: "The letter",
                        ),
                        TextSpan(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          text: " O ",
                        ),
                        TextSpan(
                          text: "is in the word and in the correct spot.",
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey.shade100,
                        fontSize: 16,
                      ),
                      children: const [
                        TextSpan(
                          text: "The letter",
                        ),
                        TextSpan(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                          text: " V ",
                        ),
                        TextSpan(
                          text: "is in the word but in the wrong spot.",
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "The remaining letters is not in the word.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade100,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  showStatsDialog(List<SingleplayerGameRound> games, User? currentUser) async {
    Map<Language, List<SingleplayerGameRound>> languageGameMap = groupBy(
        games,
        (SingleplayerGameRound game) => _supportedLanguages.firstWhere(
            (l) => l.code == game.language,
            orElse: () => _supportedLanguages.first));
    languageGameMap.putIfAbsent(Language("global", "Total"), () => games);

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
                  if (currentUser != null && !currentUser.isAnonymous)
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) => Loader(
                        controller: RankLoadController(userProvider),
                        waiting: Container(
                          alignment: Alignment.center,
                          height: 45,
                          child: DefaultWaitingWidget(),
                        ),
                        result: Container(
                          alignment: Alignment.center,
                          height: 45,
                          child: StatsValueLabel(
                            label: "Global Rank",
                            value: userProvider.getRank().toString(),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 15),
                  BasicStats(gameMap: languageGameMap),
                  SizedBox(height: 15),
                  if (games.length > 9)
                    StatsTrendChart(languageGameMap: languageGameMap),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class StatsTrendChart extends StatelessWidget {
  final Map<Language, List<SingleplayerGameRound>> languageGameMap;
  const StatsTrendChart({Key? key, required this.languageGameMap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<Language, List<SingleplayerGameRound>> _getChartData() {
      Map<Language, List<SingleplayerGameRound>> data = {};
      List<Language> keys = languageGameMap.keys.toList().reversed.toList();
      int totalGames = 20;
      for (Language lang in keys) {
        List<SingleplayerGameRound> rounds = languageGameMap[lang]!;
        if (rounds.length > 1 && lang.code != "global") {
          rounds.sort((a, b) => a.date.compareTo(b.date));
          rounds = rounds.sublist(max(0, rounds.length - totalGames));

          data.putIfAbsent(lang, () => rounds);
        }
      }

      return data;
    }

    Map<Language, List<SingleplayerGameRound>> data = _getChartData();
    return SizedBox(
      height: 180,
      width: 1000,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        title: ChartTitle(
          text: 'Performance Trend',
          textStyle: TextStyle(color: Colors.grey.shade100),
        ),
        primaryYAxis: NumericAxis(
            maximum: 102,
            minimum: -2,
            isVisible: false,
            axisLabelFormatter: (AxisLabelRenderDetails details) =>
                ChartAxisLabel(
                  details.value > 0 ? "Max" : "min",
                  TextStyle(
                    color: Colors.white,
                  ),
                ),
            maximumLabels: 2,
            majorGridLines: const MajorGridLines(width: 0)),
        legend: Legend(
            isVisible: true,
            textStyle: TextStyle(color: Colors.grey.shade400),
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.bottom),
        primaryXAxis: NumericAxis(
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 2,
            isVisible: false,
            majorGridLines: const MajorGridLines(width: 0)),
        series: <SplineSeries<SingleplayerGameRound, num>>[
          ...data.keys.toList().reversed.map((Language lang) {
            int index = data.keys.toList().indexOf(lang);
            List<SingleplayerGameRound> rounds = data[lang]!;
            return SplineSeries<SingleplayerGameRound, num>(
                animationDuration: 2500,
                dataSource: rounds,
                color: [
                  Colors.blue,
                  Colors.orange,
                  Colors.green,
                  Colors.purple,
                  Colors.yellow,
                  Colors.red,
                ][index],
                xValueMapper: (SingleplayerGameRound data, _) =>
                    rounds.indexOf(data),
                yValueMapper: (SingleplayerGameRound data, _) => data.points,
                width: 2,
                splineType: SplineType.monotonic,
                enableTooltip: false,
                xAxisName: "points",
                name: lang.name,
                markerSettings: const MarkerSettings(isVisible: false));
          }),
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }
}

// class StatsGuessesChart extends StatelessWidget {
//   final List<SingleplayerGameRound> games;
//   const StatsGuessesChart({Key? key, required this.games}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Map<int, int> guessesCounter = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
//     for (SingleplayerGameRound game in games) {
//       if (game.isWin) {
//         guessesCounter[game.winIndex] = guessesCounter[game.winIndex]! + 1;
//       }
//     }
//     return Container(
//       height: 150,
//       width: 1000,
//       child: SfCartesianChart(
//         plotAreaBorderWidth: 0,
//         title: ChartTitle(text: 'Tourism - Number of arrivals'),
//         legend: Legend(isVisible: false),
//         primaryXAxis: CategoryAxis(
//           majorGridLines: const MajorGridLines(width: 0),
//         ),
//         primaryYAxis: NumericAxis(
//             isVisible: true,
//             majorGridLines: const MajorGridLines(width: 0),
//             numberFormat: NumberFormat.compact()),
//         series: [
//           BarSeries<int, int>(
//               dataSource: guessesCounter.keys.toList(),
//               xValueMapper: (int data, _) => guessesCounter[data],
//               yValueMapper: (int data, _) => data,
//               dataLabelMapper: ((int a, int b) => "as"),

//               dataLabelSettings: DataLabelSettings(
//                   color: Colors.red, alignment: ChartAlignment.center),
//               name: '2015')
//         ],
//         tooltipBehavior: TooltipBehavior(enable: true),
//       ),
//     );
//   }
// }

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
  final Map<Language, List<SingleplayerGameRound>> gameMap;
  const BasicStats({Key? key, required this.gameMap}) : super(key: key);

  @override
  State<BasicStats> createState() => _BasicStatsState();
}

class _BasicStatsState extends State<BasicStats> {
  bool _autoPlay = true;
  Widget _buildStatsRow(
      {required Language language, List<SingleplayerGameRound>? games}) {
    if (games == null) return SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (language.code == "global")
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              language.name,
              style: TextStyle(
                color: Colors.grey.shade100,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Image.asset(
              "assets/img/${language.code}.png",
              height: 20,
              errorBuilder: (context, error, stackTrace) => Text(
                language.name,
                style: TextStyle(color: Colors.grey.shade100),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatsValueLabel(value: "${games.length}", label: "Played"),
            StatsValueLabel(
                value: games.isNotEmpty
                    ? NumberFormat.percentPattern("en").format(
                        games.where((g) => g.isWin).length / games.length)
                    : "-",
                label: "Success Rate"),
            StatsValueLabel(
                value: "${getTopStreak(games)}", label: "Top Streak"),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: CarouselSlider(
        options: CarouselOptions(
          onPageChanged: (int page, CarouselPageChangedReason reason) {
            if (reason == CarouselPageChangedReason.manual) {
              setState(() {
                _autoPlay = false;
              });
            }
          },
          height: 80.0,
          viewportFraction: 1.0,
          initialPage: widget.gameMap.length - 1,
          autoPlay: _autoPlay,
        ),
        items: widget.gameMap.keys.map((Language language) {
          return Builder(
            builder: (BuildContext context) {
              return _buildStatsRow(
                  language: language, games: widget.gameMap[language]);
            },
          );
        }).toList(),
      ),
    );
  }
}

class StatsValueLabel extends StatelessWidget {
  final String value;
  final String label;
  const StatsValueLabel({
    Key? key,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
