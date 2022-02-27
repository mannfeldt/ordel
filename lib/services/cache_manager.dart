import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/services/firebase_client.dart';
import 'package:ordel/services/local_storage.dart';
import 'package:pedantic/pedantic.dart';

class CacheManager {
  final FirebaseClient _client;
  final LocalStorage _localStorage;

//TODO ersätt med remoteconfig.
  final Duration usersLifeTime = Duration(days: 7);

  CacheManager(FirebaseClient client, LocalStorage localStorage)
      : _client = client,
        _localStorage = localStorage;

  Future<List<User>> getUsers() async {
    int usersCacheSeconds = RemoteConfig.instance.getInt("users_cache_seconds");
    DateTime now = DateTime.now().toUtc();
    CachedValue<List<User>>? cache = await _localStorage.getUsers();
    if (cache != null &&
        cache.timestamp.millisecondsSinceEpoch + usersCacheSeconds * 1000 >
            now.millisecondsSinceEpoch) {
      print("return cache getSchedule");
      return cache.value;
    }
    print("fetch api getSchedule");
    List<User> users = await _client.getUsers();
    unawaited(_localStorage.storeUsers(users));
    return users;
  }

  // Future<List<User>> getFollowers() async {
  //   int usersCacheSeconds = RemoteConfig.instance.getInt("users_cache_seconds");
  //   DateTime now = DateTime.now().toUtc();
  //   CachedValue<List<User>>? cache = await _localStorage.getFollowers();
  //   if (cache != null &&
  //       cache.timestamp.millisecondsSinceEpoch + usersCacheSeconds * 1000 >
  //           now.millisecondsSinceEpoch) {
  //     print("return cache getSchedule");
  //     return cache.value;
  //   }
  //   print("fetch api getSchedule");
  //   List<User> users = await _client.getFollowers();
  //   unawaited(_localStorage.storeFollowers(users));
  //   return users;
  // }
}
