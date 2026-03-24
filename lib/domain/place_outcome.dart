import 'game_state.dart';

/// Result of attempting to place the current queue digit on a cell.
sealed class PlaceOutcome {
  const PlaceOutcome();
}

final class PlaceSuccess extends PlaceOutcome {
  const PlaceSuccess(this.state, {this.wasMatch = false});
  final GameState state;
  final bool wasMatch;
}

final class PlaceFailure extends PlaceOutcome {
  const PlaceFailure(this.reason);
  final String reason;
}
