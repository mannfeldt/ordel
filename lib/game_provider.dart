import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';

import 'package:ordel/firebase_client.dart';
import 'package:ordel/local_storage.dart';
import 'package:ordel/models/game_round_model.dart';

import 'models/user_model.dart';

class GameProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  final FirebaseAnalyticsObserver _observer;
  String? _projectId;
  bool _fetchingGames = false;
  bool _initialized = false;

  bool get fetchingGames => _fetchingGames;
  bool get initialized => _initialized;

  bool get isProd => _projectId == null || _projectId == "ordel-prod";

  List<GameRound> _games = [];
  List<List<GameRound>> _leaderboard = [];

  List<GameRound> get allGames => _games;
  List<List<GameRound>> get leaderboard => _leaderboard;

  List<GameRound> get myGames =>
      _games.where((g) => g.user == _client.user?.uid).toList();

  User? get currentUser => _client.user;

//TODO hämta upp de det bästa man gjort. visa upp det visuellt kanske.
//TODO snyggt med scrollbar lista där man kan se en avkortad variant av gameGrid för varje runda.
//TODO Men börja med att bara visa upp siffra för rekord i dialog på stats.
//TODO snyggast vore att mappa ihop omgångar så man kan se en trend över hur det går

//TODO tvådemsnionell lista då. lista med listor av WordleGame. kan ha en linjediagram över trend
//TODO se hur man förbättrar sig.
//TODO retunera bara de som är minst 2 vinster i rad.
  List<List<GameRound>> get myStreaks {
    List<GameRound> games = myGames;
    List<List<GameRound>> streaks = [];
    int streakIndex = 0;
    for (int i = 0; i < games.length; i++) {
      GameRound g = games[i];
      if (g.isWin) {
        if (streaks.length <= streakIndex) {
          streaks.add([g]);
        } else {
          streaks[streakIndex].add(g);
        }
      } else {
        streakIndex = streaks.length;
      }
    }
    streaks.sort((a, b) {
      if (a.length != b.length) return b.length - a.length;
      return b.first.date.millisecondsSinceEpoch -
          a.first.date.millisecondsSinceEpoch;
    });
    return streaks;
  }

  List<List<GameRound>> getUserLeaderBoard(String userId) {
    return _leaderboard.where((streak) => streak.first.user == userId).toList();
  }

//TODO denna här kan vara väldigt tung. kanske ska göra den initalt. ha en laddad leaderboard variabel som kan hämtas..
  List<List<GameRound>> getLeaderBoard() {
    List<GameRound> games = List.from(allGames);

    games.sort((a, b) => a.user.compareTo(b.user));
    List<List<GameRound>> streaks = [];
    int streakIndex = 0;
    GameRound? lastGame;
    for (int i = 0; i < games.length; i++) {
      GameRound g = games[i];
      if (lastGame != null && g.user != lastGame.user) {
        streakIndex = streaks.length;
      }
      if (g.isWin) {
        if (streaks.length <= streakIndex) {
          streaks.add([g]);
        } else {
          streaks[streakIndex].add(g);
        }
      } else {
        streakIndex = streaks.length;
      }
      lastGame = g;
    }
    streaks.sort((a, b) {
      if (a.length != b.length) return b.length - a.length;
      return b.first.date.millisecondsSinceEpoch -
          a.first.date.millisecondsSinceEpoch;
    });
    return streaks;
  }

//TODO statiskt över top ord man klarar. ord man klarar minst.

//TODO räkna ut sin tank. eller en hel highscore kan det vara då.. men behöver skapa users collection då
//Täkna ut sin bästa streak och jämför med alla andra användare se var man rankar.
  int get rank => 1;

  GameProvider(
      {required FirebaseClient client,
      required LocalStorage localStorage,
      required FirebaseAnalyticsObserver observer})
      : _client = client,
        _localStorage = localStorage,
        _observer = observer;

  logOut() async {
    await auth.FirebaseAuth.instance.signOut();
  }

  initSession(String projectId) async {
    await _client.init();
    _localStorage.storeLastLoggedInVersion();

    // _games = await _client.getGames();
    _projectId = projectId;

    notifyListeners();
  }

  loadGames() async {
    if (!_fetchingGames) {
      try {
        await getGames();
        _leaderboard = getLeaderBoard();
        _fetchingGames = true;
      } finally {
        _initialized = true;
        _fetchingGames = false;
        notifyListeners();
      }
    }
  }

  Future<void> getGames() async {
    _games = await _client.getGames();
  }

  resetGames() {
    _games = [];
    notifyListeners();
  }

  Future<void> createGame(
      {required String answer,
      required Duration duration,
      required List<String> guesses,
      required String language}) async {
    GameRound game = GameRound.fromGuesses(
      answer: answer,
      duration: duration,
      language: language,
      user: currentUser!.uid,
      date: DateTime.now(),
      guesses: guesses,
    );
    _games.add(game);
    _leaderboard = getLeaderBoard();
    await _client.createGame(game);
    notifyListeners();
  }

  clearLocalStorage() async {
    _localStorage.clearLastLoggedInVersion();
  }
}
