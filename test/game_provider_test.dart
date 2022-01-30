import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ordel/firebase_client.dart';
import 'package:ordel/game_provider.dart';
import 'package:ordel/local_storage.dart';
import 'package:ordel/models/user_model.dart';
import 'package:ordel/models/game_round_model.dart';

import 'game_provider_test.mocks.dart';
import 'games_data.dart';

@GenerateMocks([FirebaseAnalyticsObserver, FirebaseClient, LocalStorage])
void main() {
  late MockFirebaseClient clientMock;
  late MockFirebaseAnalyticsObserver observer;
  late GameProvider sut;
  late MockLocalStorage localStorage;

  setUp(() async {
    clientMock = MockFirebaseClient();
    observer = MockFirebaseAnalyticsObserver();
    localStorage = MockLocalStorage();
  });

  test('myGames', () async {
    final List<GameRound> games = [
      createGame(user: "user1"),
      createGame(user: "user2"),
      createGame(user: "user3"),
      createGame(user: "user1"),
      createGame(user: "user2"),
    ];
    when(clientMock.getGames()).thenAnswer((_) async => games);
    when(clientMock.user).thenReturn(User.empty(uid: "user1"));
    sut = GameProvider(
        client: clientMock, localStorage: localStorage, observer: observer);

    await sut.loadGames();

    expect(sut.myGames, [games[0], games[3]]);
  });
  test('myStreaks', () async {
    final List<GameRound> games = [
      createGame(user: "user1", win: true),
      createGame(user: "user2", win: true),
      createGame(user: "user1", win: true),
      createGame(user: "user1"),
      createGame(user: "user1"),
      createGame(user: "user1", win: true, date: DateTime(2020, 1, 3)),
      createGame(user: "user1"),
      createGame(user: "user1", win: true, date: DateTime(2020, 1, 2)),
      createGame(user: "user1", win: true),
      createGame(user: "user1", win: true),
      createGame(user: "user1"),
      createGame(user: "user1", win: true, date: DateTime(2020, 1, 2)),
      createGame(user: "user1"),
      createGame(user: "user1", win: true, date: DateTime(2020, 1, 3)),
      createGame(user: "user1", win: true),
      createGame(user: "user1", win: true),
    ];
    when(clientMock.getGames()).thenAnswer((_) async => games);
    when(clientMock.user).thenReturn(User.empty(uid: "user1"));
    sut = GameProvider(
        client: clientMock, localStorage: localStorage, observer: observer);

    await sut.loadGames();
    expect(sut.getUserLeaderBoard("user1"), [
      [games[13], games[14], games[15]],
      [games[7], games[8], games[9]],
      [games[0], games[2]],
      [games[5]],
      [games[11]]
    ]);
  });
  test('getLeaderBoard', () async {
    final List<GameRound> games = [
      createGame(user: "user1", win: true),
      createGame(user: "user2", win: true, date: DateTime(2020, 1, 5)),
      createGame(user: "user1", win: true),
      createGame(user: "user1"),
      createGame(user: "user1"),
      createGame(user: "user1", win: true, date: DateTime(2020, 1, 3)),
      createGame(user: "user1"),
      createGame(user: "user1", win: true, date: DateTime(2020, 1, 2)),
      createGame(user: "user1", win: true),
      createGame(user: "user1", win: true),
      createGame(user: "user1"),
      createGame(user: "user1", win: true, date: DateTime(2020, 1, 2)),
      createGame(user: "user1"),
      createGame(user: "user1", win: true, date: DateTime(2020, 1, 3)),
      createGame(user: "user2", win: true),
      createGame(user: "user2", win: true),
      createGame(user: "user1", win: true),
      createGame(user: "user2", win: true),
      createGame(user: "user1", win: true),
      createGame(user: "user2"),
      createGame(user: "user2", win: true, date: DateTime(2019, 1, 3)),
      createGame(user: "user2", win: true),
    ];
    when(clientMock.getGames()).thenAnswer((_) async => games);
    when(clientMock.user).thenReturn(User.empty(uid: "user1"));
    sut = GameProvider(
        client: clientMock, localStorage: localStorage, observer: observer);

    await sut.loadGames();

    expect(sut.getLeaderBoard(), [
      [games[1], games[14], games[15], games[17]],
      [games[13], games[16], games[18]],
      [games[7], games[8], games[9]],
      [games[0], games[2]],
      [games[20], games[21]],
      [games[5]],
      [games[11]],
    ]);
  });
}
