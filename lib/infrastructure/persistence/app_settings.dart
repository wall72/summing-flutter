import 'package:meta/meta.dart';

/// User toggles persisted locally (PRD §6.1 / §7.3).
@immutable
class AppSettings {
  const AppSettings({
    this.musicOn = true,
    this.soundOn = true,
  });

  final bool musicOn;
  final bool soundOn;

  AppSettings copyWith({
    bool? musicOn,
    bool? soundOn,
  }) {
    return AppSettings(
      musicOn: musicOn ?? this.musicOn,
      soundOn: soundOn ?? this.soundOn,
    );
  }

  Map<String, dynamic> toJson() => {
    'musicOn': musicOn,
    'soundOn': soundOn,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      musicOn: json['musicOn'] as bool? ?? true,
      soundOn: json['soundOn'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.musicOn == musicOn &&
      other.soundOn == soundOn;

  @override
  int get hashCode => Object.hash(musicOn, soundOn);
}
