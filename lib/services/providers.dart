import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/navigation/routes.dart';
import 'package:ordel/services/cache_manager.dart';
import 'package:ordel/services/firebase_client.dart';
import 'package:ordel/services/game_provider.dart';
import 'package:ordel/services/local_storage.dart';
import 'package:ordel/services/multiplayer_provider.dart';
import 'package:ordel/services/session_provider.dart';
import 'package:ordel/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<List<SingleChildWidget>> bootstrap() async {
  final analyticsObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  final localStorage = LocalStorage();
  await analyticsObserver.analytics.setAnalyticsCollectionEnabled(kReleaseMode);

  FirebaseApp inst = Firebase.app();

  FirebaseOptions options = inst.options;

  final firebaseClient = FirebaseClient(analyticsObserver, localStorage);
  await localStorage.init();
  await firebaseClient.init(localStorage.activeUser);

  RemoteConfig remoteConfig = RemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 30),
      minimumFetchInterval:
          kReleaseMode ? const Duration(hours: 1) : const Duration(seconds: 60),
    ),
  );
  await remoteConfig.setDefaults({
    "answers_en": "BEACH,PILOT",
    "answers_sv": "BJÖRK,AKTIE",
    "supported_languages": "en:English,sv:Svenska",
    "users_cache_seconds": 30,
    "singleplayer_games_cache_seconds": 30,
  });
  await remoteConfig.fetchAndActivate();

  final router = FluroRouter();
  Routes.configureRoutes(router);
  AppRouter.router = router;
  final CacheManager cacheManager = CacheManager(firebaseClient, localStorage);

  // Responsive.init(ScreenType.small);
  return [
    ...buildServiceProviders(
        firebaseClient, analyticsObserver, localStorage, cacheManager),
    ...buildModelProviders(firebaseClient, analyticsObserver, localStorage,
        cacheManager, options.projectId)
  ];
}

List<SingleChildWidget> buildModelProviders(
    FirebaseClient client,
    FirebaseAnalyticsObserver observer,
    LocalStorage storage,
    CacheManager cacheManager,
    String projectId) {
  return [
    ChangeNotifierProxyProvider3<FirebaseClient, FirebaseAnalyticsObserver,
        LocalStorage, SessionProvider>(
      update: (context, client, analyticsObserver, localStorage, gameProvider) {
        var provider = SessionProvider(
          client: client,
          localStorage: localStorage,
          observer: analyticsObserver,
        );
        provider.initSession(
          projectId,
          localStorage.languageCode,
        );
        return provider;
      },
      create: (context) {
        return SessionProvider(
            client: client, localStorage: storage, observer: observer);
      },
    ),
    ChangeNotifierProxyProvider3<FirebaseClient, FirebaseAnalyticsObserver,
        LocalStorage, GameProvider>(
      update: (context, client, analyticsObserver, localStorage, provider) {
        var provider = GameProvider(
          client: client,
          localStorage: localStorage,
          observer: analyticsObserver,
          cacheManager: cacheManager,
        );
        if (client.user != null) {
          provider.loadGames();
        }
        return provider;
      },
      create: (context) {
        return GameProvider(
          client: client,
          localStorage: storage,
          observer: observer,
          cacheManager: cacheManager,
        );
      },
    ),
    ChangeNotifierProxyProvider3<FirebaseClient, FirebaseAnalyticsObserver,
        LocalStorage, MultiplayerProvider>(
      update: (context, client, analyticsObserver, localStorage, provider) {
        var provider = MultiplayerProvider(
          client: client,
          localStorage: localStorage,
          observer: analyticsObserver,
        );
        return provider;
      },
      create: (context) {
        return MultiplayerProvider(
            client: client, localStorage: storage, observer: observer);
      },
    ),
    ChangeNotifierProxyProvider3<FirebaseClient, FirebaseAnalyticsObserver,
        LocalStorage, UserProvider>(
      update: (context, client, analyticsObserver, localStorage, provider) {
        // ska cachemanager vara del av ChangeNotifierProxyProvider3? som i F1?
        var provider = UserProvider(
          client: client,
          localStorage: localStorage,
          observer: analyticsObserver,
          cacheManager: cacheManager,
        );

        return provider;
      },
      create: (context) {
        return UserProvider(
            client: client,
            localStorage: storage,
            observer: observer,
            cacheManager: cacheManager);
      },
    ),
  ];
}

List<SingleChildWidget> buildServiceProviders(
    FirebaseClient firebaseClient,
    FirebaseAnalyticsObserver analyticsObserver,
    LocalStorage localStorage,
    CacheManager cacheManager) {
  return [
    Provider<FirebaseClient>.value(value: firebaseClient),
    Provider<FirebaseAnalyticsObserver>.value(value: analyticsObserver),
    Provider<LocalStorage>.value(value: localStorage),
    Provider<CacheManager>.value(value: cacheManager),
  ];
}
