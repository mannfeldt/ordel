import 'package:ordel/game_provider.dart';
import 'package:ordel/loader.dart';

class ScoreLoadingController implements LoadController {
  final GameProvider provider;
  ScoreLoadingController(this.provider);

  @override
  bool get isEmpty => provider.myGames.isEmpty;

  @override
  bool get isInitialized => provider.initialized;

  @override
  Future load() async {
    await provider.loadGames();
  }

  @override
  void retry() {
    provider.resetGames();
  }
}
