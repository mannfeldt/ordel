import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:ordel/models/game_round_model.dart';
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
  StreamSubscription<DocumentSnapshot>? _activeGameListener;
  MultiplayerGame? _activeGame;

  MultiplayerGame? get activeGame => _activeGame;
  bool get fetchingGames => _fetchingGames;
  bool get initialized => _initialized;
  bool get hasGames => _games != null && _games!.isNotEmpty;

  User? get currentUser => _client.user;

  List<MultiplayerGame>? _games;

  List<MultiplayerGame>? get games => _games;

  @override
  @mustCallSuper
  Future<void> dispose() async {
    await _activeGameListener?.cancel();
    super.dispose();
  }

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

  Future<void> initWithLiseners(
      String gameId, MediaQueryData mq, User activeUser) async {
    // if (gameId != _activeGame?.id) return;

    if (_activeGameListener != null) {
      await _activeGameListener?.cancel();
    }

    _activeGame = await _client.getMultiplayerGame(gameId);
    _activeGameListener = _client.subscribeToGame(gameId, _activeGameChanged);
  }

  void _activeGameChanged(MultiplayerGame game) {
    _activeGame = game;

    // this.ha
    notifyListeners();
  }

  void saveRound(List<String> guesses, Duration duration) {
    _activeGame!.activeGameRound.duration = duration;
    _activeGame!.activeGameRound.finalGuess =
        guesses.lastWhere((g) => g.isNotEmpty);
    _activeGame!.activeGameRound.winIndex =
        guesses.indexOf(_activeGame!.activeGameRound.answer);
    // forsätt härtyp
    //1. när man spelat sin runda så ser ligger den fortfarande under "my turn" innan man kör pull to refresh?
    // behöver vi synka _activegames till _games? saveRound följs av startNewRound som updaterar game

    //TODO alltså typ göra de här ändringarna på _games[activegame] istället?
    //TODO eller båda?

    // problemet jag ska ta tag i är här att när man spelat klart sin runda står den fortfarande under "my turn"
    // troligen synkas det inte tillräckligt bra..

    //2. just nu kan man öppna "active game" när det är någon annans tur.
    // ta bort den möjligheten eller anpassa multiplayer_gameplay för om det inte är min tur.
    //enklaste att byta ikon till arrow down etc och lås så man inte kan öppna.
    //3. testa kör hela flödet igen, bytt till mobil och spela mot en fysisk mobil.
    notifyListeners();
  }

  Future<void> startNewRound(String newAnswer) async {
    //TODO nytt game från fyfisk mobil. när jag spelat rundan på debug så
    //TODO går den vidare rätt men listan updateras inte utan en pulltorefresh?

//TODO blir ingen notis om myturn och mygames updateras inte utan pull to refresh..
    _activeGame!.rounds.add(GameRound(
        answer: newAnswer,
        user:
            _activeGame!.playerUids.firstWhere((p) => p != _client.user!.uid)));
    await updateGame();
    // notifyListeners();
    //TODO det är kanske denna som gör att det krävs pull to refresh? kör ju ladrig notifylistener..
  }

  Future<void> finishGame() async {
    _activeGame?.state = GameState.Finished;
    await updateGame();
  }

  Future<void> updateGame() async {
    await _client.updateGame(activeGame!);
  }

  void resetActiveGame() {
    _activeGame = null;
    notifyListeners();
  }

  Future<void> notifyGameHasEnded(List<User> users) async {
    await _client.notifyGameHasEnded(users, activeGame!);
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

  Future<MultiplayerGame> acceptGameInvite(
      MultiplayerGame game, User user, User? host) async {
    game.state = GameState.Playing;
    await _client.acceptGameInvite(game, user, host);
    notifyListeners();
    return game;
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

  Future<void> createNewGame(
      {required String language,
      required User invite,
      required String word}) async {
    User host = _client.user!;
    MultiplayerGame game = MultiplayerGame(
        id: "",
        state: GameState.Inviting,
        language: language,
        startTime: DateTime.now(),
        invitees: [invite.uid],
        playerUids: [host.uid],
        rounds: [
          GameRound(
            answer: word,
            user: invite.uid,
          )
        ],
        //TODO detta kan förenklas för duel när det alltid är 1v1 med att bara ha host och invitee som två strängar istället för invitees playerUids etc
        host: host.uid);

    MultiplayerGame neweGame =
        await _client.createMultiplayerGame(game, [invite], host);
    _games?.add(neweGame);
    notifyListeners();
  }

  Future<void> resetGames() async {
    _games = null;

    notifyListeners();
  }
}
