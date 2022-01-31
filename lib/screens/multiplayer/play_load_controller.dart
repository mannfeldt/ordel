import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/loader.dart';

class MultiplayerGameLoadController implements LoadController {
  final UserProvider userProvider;
  final MultiplayerProvider multiplayerProvider;

  MultiplayerGameLoadController(this.userProvider, this.multiplayerProvider);

  @override
  bool get isEmpty => false;

  @override
  bool get isInitialized =>
      userProvider.users != null && multiplayerProvider.games != null;

  @override
  Future load() async {
    if (userProvider.users == null) {
      await userProvider.getUsers();
    }
    if (!multiplayerProvider.initialized) {
      await multiplayerProvider.loadGames();
    }
  }

  @override
  void retry() {
    multiplayerProvider.resetGames();
  }
}
