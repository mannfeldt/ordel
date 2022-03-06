import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/loader.dart';

class RankLoadController implements LoadController {
  final UserProvider userProvider;

  RankLoadController(this.userProvider);

  @override
  bool get isEmpty => userProvider.users?.isEmpty ?? true;

  @override
  bool get isInitialized => userProvider.users != null;

  @override
  Future load() => userProvider.getUsers();

//borde heta reset?
  @override
  void retry() => userProvider.resetUsers();
}
