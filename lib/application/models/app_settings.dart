import 'package:meta/meta.dart';

/// User toggles persisted locally (PRD §6.1 / §7.3).
///
/// application 계층 소유 값 타입. JSON 형식(`musicOn`, `soundOn`, 기본값 true)은
/// 저장 호환을 위해 바꾸지 않는다 (REQ-ARCH-004).
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
