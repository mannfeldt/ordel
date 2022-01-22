import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

import 'package:ordel/firebase_client.dart';
import 'package:ordel/local_storage.dart';
import 'package:ordel/models/wordle_game_model.dart';

class GameProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  final FirebaseAnalyticsObserver _observer;

  List<WordleGame> _games = [];

  List<WordleGame> get allGames => _games;

  List<WordleGame> get myGames =>
      _games.where((g) => g.user == _client.user!.uid).toList();

  String get currentUserId => _client.user!.uid;

  GameProvider(
      {required FirebaseClient client,
      required LocalStorage localStorage,
      required FirebaseAnalyticsObserver observer})
      : _client = client,
        _localStorage = localStorage,
        _observer = observer;

  initSession() async {
    _localStorage.storeLastLoggedInVersion();
    _games = await _client.getGames();

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
