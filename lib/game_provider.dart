import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

import 'package:ordel/firebase_client.dart';
import 'package:ordel/local_storage.dart';
import 'package:ordel/models/wordle_game_model.dart';

class GameProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  final FirebaseAnalyticsObserver _observer;
  String? _projectId;

  bool get isProd => _projectId == null || _projectId == "ordel-prod";

  List<WordleGame> _games = [];

  List<WordleGame> get allGames => _games;

  List<WordleGame> get myGames =>
      _games.where((g) => g.user == _client.user!.uid).toList();

  String get currentUserId => _client.user!.uid;

//TODO hämta upp de det bästa man gjort. visa upp det visuellt kanske.
//TODO snyggt med scrollbar lista där man kan se en avkortad variant av gameGrid för varje runda.
//TODO Men börja med att bara visa upp siffra för rekord i dialog på stats.
//TODO snyggast vore att mappa ihop omgångar så man kan se en trend över hur det går

//TODO tvådemsnionell lista då. lista med listor av WordleGame. kan ha en linjediagram över trend
//TODO se hur man förbättrar sig.
//TODO retunera bara de som är minst 2 vinster i rad.
  List<WordleGame> get myStreaks =>
      _games.where((g) => g.user == _client.user!.uid).toList();
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

  initSession(String projectId) async {
    _localStorage.storeLastLoggedInVersion();
    _games = await _client.getGames();
    _projectId = projectId;

    notifyListeners();
  }

  loadGames() async {
    _games = await _client.getGames();
    notifyListeners();
  }

  Future<void> createGame(
      {required String answer,
      required Duration duration,
      required List<String> guesses}) async {
    WordleGame game = WordleGame(
        answer: answer,
        guesses: guesses,
        duration: duration,
        language: "sv",
        user: currentUserId,
        date: DateTime.now());
    _games.add(game);
    await _client.createGame(game);
    notifyListeners();
  }

  clearLocalStorage() async {
    _localStorage.clearLastLoggedInVersion();
  }
}
