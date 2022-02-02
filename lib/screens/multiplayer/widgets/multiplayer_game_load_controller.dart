import 'package:flutter/cupertino.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/loader.dart';

class GameplayLoadController implements LoadController {
  final MultiplayerProvider multiplayerProvider;
  final UserProvider userProvider;
  final String gameId;
  final MediaQueryData mq;

  GameplayLoadController(
    this.multiplayerProvider,
    this.userProvider,
    this.gameId,
    this.mq,
  );

  @override
  bool get isEmpty => false;

  @override
  bool get isInitialized =>
      multiplayerProvider.activeGame != null &&
      multiplayerProvider.activeGame!.id == gameId;

  @override
  Future load() {
    return multiplayerProvider.initWithLiseners(
        gameId, mq, userProvider.activeUser!);
  }

  @override
  void retry() {
    multiplayerProvider.resetActiveGame();
  }
}
