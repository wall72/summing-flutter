import 'board.dart';

/// Derived from the board after each move (PRD §5.5).
enum GamePhase {
  playing,
  complete,
  gameOver;

  static GamePhase fromBoard(Board board) {
    if (board.isComplete) return GamePhase.complete;
    if (board.isGameOver) return GamePhase.gameOver;
    return GamePhase.playing;
  }
}
