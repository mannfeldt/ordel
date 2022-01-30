enum GameState { Waiting, Playing, Finished, Inviting }
enum GameType {
  Classic,
  Wild,
  Bingo,
  Battleship,
}

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
