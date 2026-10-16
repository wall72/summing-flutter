import 'package:flutter/material.dart';

/// 디자인 토큰 (`design.md` §1 색상, §2 형태와 간격, §3 타이포그래피).
///
/// 색, 반경, 간격, 글자 크기 리터럴은 이 폴더와 `lib/presentation/layout/`에만 둔다
/// (`spec.md` §D, AC-UI-16, 23). 위젯은 이 토큰을 거쳐 값을 읽는다.

// @MX:NOTE: [AUTO] 색상 쌍은 WCAG 대비 검증값이다(텍스트 4.5, 비텍스트 3.0, design.md §1 / research.md §3). 값을 바꾸면 test/presentation/theme/token_contrast_test.dart를 다시 실행해 대비를 확인해야 한다
/// 파스텔 팔레트. 라이트·다크 한 벌씩 있고 테마 확장으로 위젯에 전달된다.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surfaceContainer,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.accentText,
    required this.focus,
    required this.onAccent,
    required this.cellEmpty,
    required this.cellFilled,
    required this.cellOutline,
    required this.placeHighlight,
    required this.matchFlash,
    required this.primary,
    required this.onPrimary,
    required this.queueHeadContainer,
    required this.onQueueHead,
    required this.queueHeadOutline,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.scrim,
  });

  /// 화면 배경, 상단 바.
  final Color background;

  /// 카드, 대화상자, 시트, 보드 프레임.
  final Color surfaceContainer;

  /// 본문, 셀 숫자(digit), 목록 제목.
  final Color onSurface;

  /// 보조 문구, 목록 부제, Switch 꺼짐 thumb.
  final Color onSurfaceVariant;

  /// TextButton·OutlinedButton 전경, Switch 켜짐 트랙, 진행 표시기.
  final Color accentText;

  /// 키보드 포커스 링 (accentText와 같은 값).
  final Color focus;

  /// Switch 켜짐 thumb.
  final Color onAccent;

  /// 빈 칸 채움, Switch 꺼짐 트랙.
  final Color cellEmpty;

  /// 숫자가 있는 칸 채움.
  final Color cellFilled;

  /// 모든 칸의 외곽선, OutlinedButton 테두리, Switch 꺼짐 테두리, 시트 손잡이.
  final Color cellOutline;

  /// 배치 직후 강조.
  final Color placeHighlight;

  /// 매치로 지워지는 칸.
  final Color matchFlash;

  /// FilledButton 채움. 텍스트 전경으로는 쓰지 않는다 (배경 대비 1.60).
  final Color primary;

  /// FilledButton 문구.
  final Color onPrimary;

  /// 큐 첫 칸, tonal 버튼 채움, CircleAvatar 배경.
  final Color queueHeadContainer;

  /// 큐 첫 칸 숫자, tonal 버튼 문구, CircleAvatar 순위 숫자.
  final Color onQueueHead;

  /// 큐 첫 칸 2px 외곽선 (accentText와 같은 값).
  final Color queueHeadOutline;

  /// SnackBar 배경.
  final Color inverseSurface;

  /// SnackBar 문구.
  final Color onInverseSurface;

  /// SnackBar 액션.
  final Color inversePrimary;

  /// 종료 오버레이 배경 (라이트: onSurface 40%, 다크: background 70%).
  final Color scrim;

  static const _lightOnSurface = Color(0xFF2E2A3A);
  static const _lightAccent = Color(0xFF9C3358);
  static const _darkBackground = Color(0xFF1C1924);
  static const _darkAccent = Color(0xFFF4B6C2);

  static final AppPalette light = AppPalette(
    background: const Color(0xFFFFF8F1),
    surfaceContainer: const Color(0xFFFFFFFF),
    onSurface: _lightOnSurface,
    onSurfaceVariant: const Color(0xFF5E5670),
    accentText: _lightAccent,
    focus: _lightAccent,
    onAccent: const Color(0xFFFFFFFF),
    cellEmpty: const Color(0xFFCEC3EB),
    cellFilled: const Color(0xFFFFFFFF),
    cellOutline: const Color(0xFF8E80B8),
    placeHighlight: const Color(0xFFFFE1C7),
    matchFlash: const Color(0xFFC9EEDC),
    primary: const Color(0xFFF6B7C4),
    onPrimary: const Color(0xFF3B1F2B),
    queueHeadContainer: const Color(0xFFFCD9E0),
    onQueueHead: const Color(0xFF3B1F2B),
    queueHeadOutline: _lightAccent,
    inverseSurface: _lightOnSurface,
    onInverseSurface: const Color(0xFFF4EFFF),
    inversePrimary: const Color(0xFFF4B6C2),
    scrim: _lightOnSurface.withValues(alpha: 0.4),
  );

  static final AppPalette dark = AppPalette(
    background: _darkBackground,
    surfaceContainer: const Color(0xFF262230),
    onSurface: const Color(0xFFF4EFFF),
    onSurfaceVariant: const Color(0xFFCFC6E0),
    accentText: _darkAccent,
    focus: _darkAccent,
    onAccent: const Color(0xFF3B1F2B),
    cellEmpty: const Color(0xFF1F1C28),
    cellFilled: const Color(0xFF4A4266),
    cellOutline: const Color(0xFF9C90C8),
    placeHighlight: const Color(0xFF6B4A33),
    matchFlash: const Color(0xFF2E5A4B),
    primary: const Color(0xFFF4B6C2),
    onPrimary: const Color(0xFF3B1F2B),
    queueHeadContainer: const Color(0xFF6A3A4C),
    onQueueHead: const Color(0xFFFFE3EA),
    queueHeadOutline: _darkAccent,
    inverseSurface: const Color(0xFFF4EFFF),
    onInverseSurface: const Color(0xFF2E2A3A),
    inversePrimary: const Color(0xFF9C3358),
    scrim: _darkBackground.withValues(alpha: 0.7),
  );

  /// 현재 테마의 팔레트. 테마에 확장이 없으면(앱 테마를 쓰지 않는 테스트 등) 밝기에 맞는 기본 팔레트를 쓴다.
  static AppPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  AppPalette copyWith({
    Color? background,
    Color? surfaceContainer,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? accentText,
    Color? focus,
    Color? onAccent,
    Color? cellEmpty,
    Color? cellFilled,
    Color? cellOutline,
    Color? placeHighlight,
    Color? matchFlash,
    Color? primary,
    Color? onPrimary,
    Color? queueHeadContainer,
    Color? onQueueHead,
    Color? queueHeadOutline,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inversePrimary,
    Color? scrim,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      accentText: accentText ?? this.accentText,
      focus: focus ?? this.focus,
      onAccent: onAccent ?? this.onAccent,
      cellEmpty: cellEmpty ?? this.cellEmpty,
      cellFilled: cellFilled ?? this.cellFilled,
      cellOutline: cellOutline ?? this.cellOutline,
      placeHighlight: placeHighlight ?? this.placeHighlight,
      matchFlash: matchFlash ?? this.matchFlash,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      queueHeadContainer: queueHeadContainer ?? this.queueHeadContainer,
      onQueueHead: onQueueHead ?? this.onQueueHead,
      queueHeadOutline: queueHeadOutline ?? this.queueHeadOutline,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      scrim: scrim ?? this.scrim,
    );
  }

  /// 시스템 밝기 전환 중 테마 애니메이션(AnimatedTheme)이 부른다.
  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: mix(background, other.background),
      surfaceContainer: mix(surfaceContainer, other.surfaceContainer),
      onSurface: mix(onSurface, other.onSurface),
      onSurfaceVariant: mix(onSurfaceVariant, other.onSurfaceVariant),
      accentText: mix(accentText, other.accentText),
      focus: mix(focus, other.focus),
      onAccent: mix(onAccent, other.onAccent),
      cellEmpty: mix(cellEmpty, other.cellEmpty),
      cellFilled: mix(cellFilled, other.cellFilled),
      cellOutline: mix(cellOutline, other.cellOutline),
      placeHighlight: mix(placeHighlight, other.placeHighlight),
      matchFlash: mix(matchFlash, other.matchFlash),
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      queueHeadContainer: mix(queueHeadContainer, other.queueHeadContainer),
      onQueueHead: mix(onQueueHead, other.onQueueHead),
      queueHeadOutline: mix(queueHeadOutline, other.queueHeadOutline),
      inverseSurface: mix(inverseSurface, other.inverseSurface),
      onInverseSurface: mix(onInverseSurface, other.onInverseSurface),
      inversePrimary: mix(inversePrimary, other.inversePrimary),
      scrim: mix(scrim, other.scrim),
    );
  }
}

/// 모서리 반경 (`design.md` §2). 버튼은 stadium 모양이라 여기 없다.
abstract final class AppRadius {
  /// 셀.
  static const double xs = 6;

  /// 큐 칸.
  static const double sm = 10;

  /// 보드 프레임 = 셀 반경 6 + 프레임 안쪽 여백 2 (모서리 동심원).
  static const double frame = 8;

  /// 카드.
  static const double md = 16;

  /// 대화상자, 시트.
  static const double lg = 24;

  /// 위젯이 쓰는 모서리 모양. `Radius.circular` 호출은 토큰 폴더에만 둔다 (AC-UI-23).
  static const BorderRadius cell = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius queueSlot = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius boardFrame =
      BorderRadius.all(Radius.circular(frame));
}

/// 선 두께 (`design.md` §2, §5).
abstract final class AppStroke {
  /// 모든 셀 외곽선, 큐 나머지 칸 외곽선.
  static const double outline = 1;

  /// 셀 포커스 링, 큐 첫 칸 외곽선.
  static const double emphasis = 2;
}

/// 상태 덧칠 불투명도. 빈 칸은 hover·press 때 cellFilled를 덧칠해 살짝 밝아진다 (`design.md` §5).
abstract final class AppStateLayer {
  static const double hover = 0.35;
  static const double pressed = 0.55;
}

/// 4pt 간격 단계 (`design.md` §2). 이름에 숫자를 쓰지 않는다
/// (AC-UI-23 grep이 `EdgeInsets.all(<숫자 포함 이름>)`도 리터럴로 잡기 때문).
abstract final class AppSpacing {
  /// 셀 간격·프레임 여백 전용.
  static const double hairline = 2;
  static const double xxs = 4;

  /// compact 보드 여백, 저높이 가로 패널 여백 전용.
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// 글자 크기 (`design.md` §3). 굵기는 테마의 TextTheme이 정한다.
abstract final class AppTypeScale {
  /// 번들 글꼴 family. `pubspec.yaml`의 `fonts:`와 같은 이름이어야 한다.
  static const String fontFamily = 'Nunito';

  /// 앱 제목 "Summing".
  static const double appTitle = 40;

  /// 저높이 가로 사이드 패널의 앱 제목.
  static const double appTitleCompact = 20;

  /// 오버레이 제목.
  static const double headline = 28;

  /// 상단 바, 섹션 제목.
  static const double title = 20;
  static const double body = 16;

  /// 버튼 라벨.
  static const double label = 14;

  /// 큐 숫자 (저높이 가로에서는 [queueDigitCompact]).
  static const double queueDigit = 24;
  static const double queueDigitCompact = 20;

  /// 셀 숫자 = 셀 한 변 × 이 비율.
  static const double cellDigitRatio = 0.5;
}

/// 카드·대화상자 그림자 (`design.md` §2: blur 12, y 4, primary 12%).
abstract final class AppElevation {
  static const double card = 4;
  static const double shadowAlpha = 0.12;
}
