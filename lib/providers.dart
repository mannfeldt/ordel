import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ordel/firebase_client.dart';
import 'package:ordel/game_provider.dart';
import 'package:ordel/local_storage.dart';
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
  await firebaseClient.init();
  await localStorage.init();

  // final router = FluroRouter();
  // Routes.configureRoutes(router);
  // AppRouter.router = router;

  // Responsive.init(ScreenType.small);
  return [
    ...buildServiceProviders(firebaseClient, analyticsObserver, localStorage),
    ...buildModelProviders(
        firebaseClient, analyticsObserver, localStorage, options.projectId)
  ];
}

List<SingleChildWidget> buildModelProviders(
    FirebaseClient client,
    FirebaseAnalyticsObserver observer,
    LocalStorage storage,
    String projectId) {
  return [
    ChangeNotifierProxyProvider3<FirebaseClient, FirebaseAnalyticsObserver,
        LocalStorage, GameProvider>(
      update: (context, client, analyticsObserver, localStorage, gameProvider) {
        var provider = GameProvider(
          client: client,
          localStorage: localStorage,
          observer: analyticsObserver,
        );
        provider.initSession(projectId);
        return provider;
      },
      create: (context) {
        //TODO jämför med pe_labs hur gör vi här. vad returneras?
        return GameProvider(
            client: client, localStorage: storage, observer: observer);
      },
    ),
  ];
}

List<SingleChildWidget> buildServiceProviders(FirebaseClient firebaseClient,
    FirebaseAnalyticsObserver analyticsObserver, LocalStorage localStorage) {
  return [
    Provider<FirebaseClient>.value(value: firebaseClient),
    Provider<FirebaseAnalyticsObserver>.value(value: analyticsObserver),
    Provider<LocalStorage>.value(value: localStorage),
  ];
}
