import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:ordel/game_provider.dart';
import 'package:ordel/home.dart';
import 'package:ordel/main_pages.dart';
import 'package:ordel/navigation/app_router.dart';
import 'package:ordel/providers.dart';
import 'package:ordel/session_provider.dart';
import 'package:ordel/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // await FirebaseCrashlytics.instance;
  // ignore: prefer_void_to_null
  unawaited(runZoned<Future<Null>>(() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final providers = await bootstrap();
//TODO kolla mot pelabs depricated?
    runApp(App(providers));
  }, onError: (error, stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }));
}
// problem att starta. få mer error logg? run med någon flagga för mer error loggs??
//en rad kan ha 3 states. inactive, active, used,
//en ruta kan ha 3 states. empty, focused, filled,
//
//lägg en grid 5 rutor per rad 6 rader. sen ett custom tangentbord. som jag kan syra alla knappar etc.
//kolla paket för det eller fixa det helt själv custom med knappar bäst kanske. ska kunna vara olika tangentbord per språk
//en tangentbordknapp har en bokstav kopplad till sig. layout är per språk.
//https://ordel.se/
//1. fixa helt offline att själva spelet fungerar. ta några manuellt handplockade ord https://doon.se/ordl%C3%A4ngd/5
//2. lägg till coola animationer. allt ska vara responsivt. höjden är det känsliga. behöver inte visa alla 6 rader samtidigt? om det blir tight.
//3. lägg till funktion för pågående streak, nollställs helt när man failar. inget sparas historiskt.
//2. lägg till möjlighet att loggain, se firebase fltuter 2.8 widgeten? då sparar man sina spel och kan se streaks etc.
//3. är man inte inloggad så kan man bara spela sessionsbasis. man kan kanske fortfarande se pågående streak men inte sina rekord osv.
//4. lägg till highscorelist/lite mer statistik om vilken rank man är, vilken procenttile man är av alla spelare.
//5. det är streak som gäller. man kan ha flera olika typer av steaks. 1. klarade ord 2. klarade ord på under x rader etc.
//6. Lägg till möjlighet till matchmaking/duel där man tävlar likt quizkampen. man får välja 1 av 3 ord till den andra spelaren
//   den ska då spela och sen väljer den tillbaka ett ord osv. bäst av 5 kanske. man får poäng beronde på hur få gissningar man behövde.
//   det kan bli lika? eller tiebreak är tiden? man har max 1 minut per omgång och den med mest tid kvar vinner om det blev lika.
//   Det kan vara auto matchmaking (ranked) eller casual (invite friend).

// todo
// lägg till responsivitet.
// lägg till streaks. skapa en gameResult model som innehåller all möjlig info.. hur många gissningar det tog åtminstone.

class App extends StatefulWidget {
  final List<SingleChildWidget> providers;

  const App(this.providers);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: widget.providers,
      child: const AppRoot(),
    );
  }

  // Widget _body() {}
}

class AppRoot extends StatefulWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    initRemoteConfig();

    super.initState();
  }

  Future<void> initRemoteConfig() async {
    RemoteConfig remoteConfig = RemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: kReleaseMode
            ? const Duration(hours: 12)
            : const Duration(seconds: 60),
      ),
    );
    await remoteConfig.setDefaults({
      "answers_en": "BEACH,PILOT",
      "answers_sv": "BJÖRK,AKTIE",
      "supported_languages": "en:English,sv:Svenska",
    });
    await remoteConfig.fetchAndActivate();
  }

  @override
  Widget build(BuildContext context) {
    const providerConfigs = [EmailProviderConfiguration()];

    return Consumer3<FirebaseAnalyticsObserver, UserProvider, SessionProvider>(
      builder:
          (context, analyticsObserver, userProvider, sessionProvider, child) =>
              MaterialApp(
        // initialRoute:
        //     FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
        onGenerateRoute: AppRouter.router?.generator,
        //TODO userProvider nollställs vid hotreload???
        home: userProvider.isLoggedIn
            ? sessionProvider.isProd
                ? const MainPages()
                : const Banner(
                    message: "DEV",
                    location: BannerLocation.bottomEnd,
                    child: MainPages(),
                  )
            : SignInScreen(
                providerConfigs: providerConfigs,
                footerBuilder: (context, action) => Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signInAnonymously();
                        await userProvider.initUser();
                      },
                      child: const Text("Anonym"),
                    ),
                    if (!sessionProvider.isProd) const Text("DEV ENVIRONMENT")
                  ],
                ),
                actions: [
                  AuthStateChangeAction<SignedIn>((context, state) {
                    userProvider.initUser();
                  }),
                ],
              ),
      ),
    );
  }
}
