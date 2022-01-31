import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:ordel/models/multiplayer_game_model.dart';

import 'package:ordel/models/user_model.dart';
import 'package:ordel/services/firebase_client.dart';
import 'package:ordel/services/local_storage.dart';

class MultiplayerProvider with ChangeNotifier {
  final FirebaseClient _client;
  final LocalStorage _localStorage;
  // ignore: unused_field
  final FirebaseAnalyticsObserver _observer;
  bool _fetchingGames = false;
  bool _initialized = false;

  bool get fetchingGames => _fetchingGames;
  bool get initialized => _initialized;
  bool get hasGames => _games != null && _games!.isNotEmpty;

  User? get currentUser => _client.user;

  List<MultiplayerGame>? _games;

  List<MultiplayerGame>? get games => _games;

  MultiplayerProvider(
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
        _fetchingGames = true;
      } finally {
        _initialized = true;
        _fetchingGames = false;
        notifyListeners();
      }
    }
  }

  Future<List<MultiplayerGame>> getGames() async {
    _games = await _client.getMultiplayerGames();

    notifyListeners();
    return _games!;
  }

  Future<void> handleGameUpdated(String gameId,
      {MultiplayerGame? newGameUpdate}) async {
    if (_games == null) return;

    MultiplayerGame oldGame = _games!.firstWhere(
      (g) => g.id == gameId,
      orElse: () => MultiplayerGame.empty(),
    );
    MultiplayerGame? newGame =
        newGameUpdate ?? await _client.getMultiplayerGame(gameId);
    if (newGame == null) return;
    if (oldGame.id != "-1") {
      _games!.insert(_games!.indexOf(oldGame), newGame);
      _games!.remove(oldGame);
    } else {
      _games!.add(newGame);
    }
    notifyListeners();
  }

  Future<void> handleGameDeleted(String gameId) async {
    _games?.removeWhere((g) => g.id == gameId);
    notifyListeners();
  }

  Future<void> acceptGameInvite(
      MultiplayerGame game, User user, User? host) async {
    await _client.acceptGameInvite(game, user, host);
    notifyListeners();
  }

  Future<void> declineGameInvite(
      MultiplayerGame game, User user, User? host) async {
    await _client.declineGameInvite(game, user, host);
    _games?.remove(game);
    notifyListeners();
  }

  Future<void> deleteGame(MultiplayerGame game) async {
    await _client.deleteGame(game);

    _games?.removeWhere((g) => g.id == game.id);
    notifyListeners();
  }

  Future<void> startGame(MultiplayerGame game) async {
    game.currentPlayerUid = game.host;
    game.invitees.clear();
    game.state = GameState.Playing;
    await _client.startGame(game);
    notifyListeners();
  }

  Future<void> createNewGame(
      MultiplayerGame game, List<User> invitedUsers, User host) async {
    MultiplayerGame neweGame =
        await _client.createMultiplayerGame(game, invitedUsers, host);
    _games?.add(neweGame);
    notifyListeners();
  }

  Future<void> resetGames() async {
    _games = null;

    notifyListeners();
  }
}
