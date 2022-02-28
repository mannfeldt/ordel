import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

import 'package:ordel/models/game_round_model.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/services/firebase_client.dart';
import 'package:ordel/services/local_storage.dart';

class GameProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
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

//TODO hämta upp de det bästa man gjort. visa upp det visuellt kanske.
//TODO snyggt med scrollbar lista där man kan se en avkortad variant av gameGrid för varje runda.
//TODO Men börja med att bara visa upp siffra för rekord i dialog på stats.
//TODO snyggast vore att mappa ihop omgångar så man kan se en trend över hur det går

//TODO tvådemsnionell lista då. lista med listor av WordleGame. kan ha en linjediagram över trend
//TODO se hur man förbättrar sig.
//TODO retunera bara de som är minst 2 vinster i rad.
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

//TODO denna här kan vara väldigt tung. kanske ska göra den initalt. ha en laddad leaderboard variabel som kan hämtas..
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
    //wtf dett görs ju fortfarande...
    if (currentUser?.isAnonymous ?? true) {
      _games = await _localStorage.getAnonGames();
    } else {
      //TODO detta är väldigt onödit. används bara för leadboard som vi inte visar just nu..

      //TODO fast vill ju kunna se streak även som inloggad... vilket försvinner här då..
      //TODO så fixa till detta men med cache då...
      _games = [];
      fixa här med cahe. och även då i createGame så ska vi lägga till gamet i localstorage...

      //kan vara rätt mycket lägnre cache lifetime här. då egna games alltid är upp to date och andras singleplayer games är inte så viktigt.
      //kan sätta 24h initallt och sen öka i remoteconfig... dev så sätt den till 1-2min
      // _games = await _client.getSingleplayerGames();
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
      await _localStorage.storeAnonGame(game);
    } else {
      //TODO lägg också till i localstorage för cachningsyfte..
      await _client.createGame(game);
    }
    notifyListeners();
  }
}
