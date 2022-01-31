import 'package:ordel/models/game_round_model.dart';

enum GameState { Waiting, Playing, Finished, Inviting }

GameState stateFromString(String value) {
  switch (value) {
    case 'playing':
      return GameState.Playing;
    case 'waiting':
      return GameState.Waiting;
    case 'finished':
      return GameState.Finished;
    case 'inviting':
      return GameState.Inviting;
    default:
      throw FormatException("Unrecognized value for GameState");
  }
}

const Map<GameState, String> GAME_STATE_NAMES = {
  GameState.Playing: "playing",
  GameState.Waiting: "waiting",
  GameState.Finished: "finished",
  GameState.Inviting: "inviting",
};

class MultiplayerGame {
  String id;
  String? currentPlayerUid;
  final List<String> playerUids;
  GameState state;
  final DateTime startTime;
  final String host;
  final List<String> invitees;
  final List<GameRound> rounds;
  //lägg till en lista med GameRounds eller liknande.
  //grejen är att varje gameround måste var kopplad till en spelare men de är det ju?
  //enda är att lagnuage inte behövs. kan vi ha här istället kanske?
  //och även date.

  MultiplayerGame({
    required this.id,
    this.currentPlayerUid,
    required this.state,
    required this.startTime,
    required this.host,
    playerUids,
    invitees,
    rounds,
  })  : invitees = invitees ?? <String>[],
        rounds = rounds ?? <GameRound>[],
        playerUids = playerUids ?? <String>[];

  factory MultiplayerGame.empty() {
    return MultiplayerGame(
        id: "-1",
        state: GameState.Finished,
        startTime: DateTime.now(),
        host: "-1");
  }

  factory MultiplayerGame.fromJson(dynamic json) {
    String id = json[ID_FIELD];
    String currentPlayer = json[CURRENT_PLAYER_FIELD];
    String stateData = json[STATE_FIELD];
    int millisecondsSinceEpoch = json[START_FIELD];
    String host = json[HOST_FIELD];
    List<dynamic> inviteesData = json[INVITEES_FIELD] ?? [];
    List<String> invitees = inviteesData.map((i) => i.toString()).toList();
    List<dynamic> playerUidsData = json[PLAYER_UIDS_FIELD];
    List<String> playerUids = playerUidsData.map((p) => p.toString()).toList();
    List<dynamic> roundsData = json[ROUNDS_FIELD];
    List<GameRound> rounds =
        roundsData.map((r) => GameRound.fromJson(r)).toList();

    return MultiplayerGame(
      id: id,
      currentPlayerUid: currentPlayer,
      state: stateFromString(stateData),
      startTime: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
      host: host,
      invitees: invitees,
      playerUids: playerUids,
      rounds: rounds,
    );
  }

  MultiplayerGame copy() => MultiplayerGame.fromJson(toJson());

  bool get hasUnansweredInvites => invitees.isNotEmpty;

  bool get isFinished => state == GameState.Finished;

  bool canStart(String uid) =>
      playerUids.length > 1 && state == GameState.Inviting && host == uid;

  Map<String, dynamic> toJson() {
    return {
      ID_FIELD: id,
      if (state != GameState.Inviting) CURRENT_PLAYER_FIELD: currentPlayerUid,
      STATE_FIELD: GAME_STATE_NAMES[state],
      HOST_FIELD: host,
      INVITEES_FIELD: invitees,
      START_FIELD: startTime.millisecondsSinceEpoch,
      PLAYER_UIDS_FIELD: playerUids,
      if (state != GameState.Inviting)
        ROUNDS_FIELD: rounds.map((r) => r.toJson()).toList(),
    };
  }

  static const String ID_FIELD = 'id';
  static const String CURRENT_PLAYER_FIELD = 'currentPlayer';
  static const String STATE_FIELD = 'state';
  static const String HOST_FIELD = 'host';
  static const String INVITEES_FIELD = 'invitees';
  static const String PLAYER_UIDS_FIELD = 'player_uids';
  static const String START_FIELD = 'start';
  static const String ROUNDS_FIELD = 'rounds';
}
