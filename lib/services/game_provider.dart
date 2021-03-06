import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/services/cache_manager.dart';
import 'package:ordel/services/firebase_client.dart';
import 'package:ordel/services/local_storage.dart';

class GameProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  final CacheManager _cacheManager;
  // ignore: unused_field
  final FirebaseAnalyticsObserver _observer;
  bool _fetchingGames = false;
  bool _initialized = false;

  bool get fetchingGames => _fetchingGames;
  bool get initialized => _initialized;

  List<SingleplayerGameRound> _games = [];
  List<List<SingleplayerGameRound>> _leaderboard = [];

  List<SingleplayerGameRound> get allGames => _games;
  List<List<SingleplayerGameRound>> get leaderboard => _leaderboard;

  List<SingleplayerGameRound> get myGames =>
      _games.where((g) => g.user == _client.user?.uid).toList();

  User? get currentUser => _client.user;

  List<List<SingleplayerGameRound>> get myStreaks {
    List<SingleplayerGameRound> games = myGames;
    List<List<SingleplayerGameRound>> streaks = [];
    int streakIndex = 0;
    for (int i = 0; i < games.length; i++) {
      SingleplayerGameRound g = games[i];
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

  List<List<SingleplayerGameRound>> getUserLeaderBoard(String userId) {
    return _leaderboard.where((streak) => streak.first.user == userId).toList();
  }

  List<List<SingleplayerGameRound>> getLeaderBoard() {
    List<SingleplayerGameRound> games = List.from(allGames);

    games.sort((a, b) => a.user.compareTo(b.user));
    List<List<SingleplayerGameRound>> streaks = [];
    int streakIndex = 0;
    SingleplayerGameRound? lastGame;
    for (int i = 0; i < games.length; i++) {
      SingleplayerGameRound g = games[i];
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

// statiskt ??ver top ord man klarar. ord man klarar minst.

// r??kna ut sin tank. eller en hel highscore kan det vara d??.. men beh??ver skapa users collection d??
//T??kna ut sin b??sta streak och j??mf??r med alla andra anv??ndare se var man rankar.
  int get rank => 1;

  GameProvider({
    required FirebaseClient client,
    required LocalStorage localStorage,
    required FirebaseAnalyticsObserver observer,
    required CacheManager cacheManager,
  })  : _client = client,
        _localStorage = localStorage,
        _observer = observer,
        _cacheManager = cacheManager;

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
    if (currentUser?.isAnonymous ?? true) {
      _games = await _localStorage.getAnonGames();
    } else {
      _games = await _cacheManager.getSingleplayerGames(currentUser!);
    }
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
    SingleplayerGameRound game = SingleplayerGameRound.fromGuesses(
      answer: answer,
      duration: duration,
      language: language,
      user: currentUser!.uid,
      date: DateTime.now(),
      guesses: guesses,
    );
    _games.add(game);
    _leaderboard = getLeaderBoard();

    if (currentUser!.isAnonymous) {
      await _localStorage.storeAnonGame(); //(game)
    } else {
      await _client.createGame(game);
      await _localStorage.storeSingleplayerGames(_games, currentUser!);
    }
    notifyListeners();
  }
}
