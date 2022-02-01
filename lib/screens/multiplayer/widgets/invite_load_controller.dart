import 'package:ordel/services/user_provider.dart';
import 'package:ordel/widgets/loader.dart';

class InviteLoadController implements LoadController {
  final UserProvider userProvider;

  InviteLoadController(this.userProvider);

  @override
  bool get isEmpty => false;

  @override
  bool get isInitialized => userProvider.users != null;

  @override
  Future load() async {
    await userProvider.getUsers();
  }

  @override
  void retry() {
    userProvider.resetUsers();
  }
}
