import 'package:meta/meta.dart';

/// One board cell: empty (playable) or filled with a digit `0…9`.
@immutable
class SummingCell {
  const SummingCell._({required this.isAssigned, required this.value});

  /// Empty cell — no digit; player may place here when game is in progress.
  static const SummingCell empty = SummingCell._(isAssigned: false, value: 0);

  const SummingCell.filled(this.value)
    : isAssigned = true,
      assert(value >= 0 && value <= 9);

  final bool isAssigned;
  final int value;

  @override
  bool operator ==(Object other) =>
      other is SummingCell &&
      other.isAssigned == isAssigned &&
      other.value == value;

  @override
  int get hashCode => Object.hash(isAssigned, value);

  @override
  String toString() =>
      isAssigned ? 'SummingCell($value)' : 'SummingCell.empty';
}
