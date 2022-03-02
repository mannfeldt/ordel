import 'package:ordel/services/game_provider.dart';
import 'package:ordel/widgets/loader.dart';

class SingleplayerLoadingController implements LoadController {
  final GameProvider provider;
  SingleplayerLoadingController(this.provider);

  @override
  bool get isEmpty => false;

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
