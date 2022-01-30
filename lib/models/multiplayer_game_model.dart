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
      break;
    case 'waiting':
      return GameState.Waiting;
      break;
    case 'finished':
      return GameState.Finished;
      break;
    case 'inviting':
      return GameState.Inviting;
      break;
    default:
      throw FormatException("Unrecognized value for GameState");
  }
}
