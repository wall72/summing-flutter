import 'package:flutter/material.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

/// 앱 테마 (`design.md` §1.1 ColorScheme 역할 매핑, §1.2 컴포넌트 테마, §3 타이포그래피).
abstract final class AppTheme {
  static final ThemeData light = _build(AppPalette.light, Brightness.light);
  static final ThemeData dark = _build(AppPalette.dark, Brightness.dark);

  // @MX:NOTE: [AUTO] 범위 내 Material 위젯이 기본값으로 읽는 ColorScheme 역할을 모두 토큰으로 채운다(design.md §1.1). 역할 하나라도 빼면 Material 기본/시드 파생값으로 돌아가 대비가 떨어진다(TextButton 1.68, Switch 켜짐 트랙 1.60). 매핑은 app_theme_test.dart(AC-UI-01)가 역할별로 검사한다
  static ThemeData _build(AppPalette c, Brightness brightness) {
    // error·tertiary 계열은 Material 기본값을 유지한다 (범위 내 위젯이 쓰지 않음).
    final scheme = ThemeData(brightness: brightness).colorScheme.copyWith(
          primary: c.primary,
          onPrimary: c.onPrimary,
          primaryContainer: c.queueHeadContainer,
          onPrimaryContainer: c.onQueueHead,
          secondaryContainer: c.queueHeadContainer,
          onSecondaryContainer: c.onQueueHead,
          surface: c.background,
          onSurface: c.onSurface,
          onSurfaceVariant: c.onSurfaceVariant,
          surfaceContainerLowest: c.surfaceContainer,
          surfaceContainerLow: c.surfaceContainer,
          surfaceContainer: c.surfaceContainer,
          surfaceContainerHigh: c.surfaceContainer,
          surfaceContainerHighest: c.cellEmpty,
          outline: c.cellOutline,
          outlineVariant: c.cellEmpty,
          inverseSurface: c.inverseSurface,
          onInverseSurface: c.onInverseSurface,
          inversePrimary: c.inversePrimary,
          // 높이에 따른 색 덧칠과 스크롤 시 AppBar 색 변화를 끈다.
          surfaceTint: Colors.transparent,
        );

    // 비활성 상태는 null을 돌려 Material 기본 비활성 색(onSurface 38% / 12%)으로 넘긴다.
    Color? enabledOnly(Set<WidgetState> states, Color color) =>
        states.contains(WidgetState.disabled) ? null : color;

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    final shadow = c.primary.withValues(alpha: AppElevation.shadowAlpha);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: AppTypeScale.fontFamily,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: AppTypeScale.appTitle,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          fontSize: AppTypeScale.headline,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          fontSize: AppTypeScale.title,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTypeScale.body,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTypeScale.body,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontSize: AppTypeScale.label,
          fontWeight: FontWeight.w700,
        ),
      ),
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      // 전경색을 styleFrom으로 주면 상태 레이어도 전경색 8% / 10% / 10%가 된다 (design.md §1.2).
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.accentText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(foregroundColor: c.accentText).copyWith(
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? null
                : BorderSide(color: c.cellOutline),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => enabledOnly(
            states,
            states.contains(WidgetState.selected) ? c.accentText : c.cellEmpty,
          ),
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => enabledOnly(
            states,
            states.contains(WidgetState.selected)
                ? c.onAccent
                : c.onSurfaceVariant,
          ),
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => enabledOnly(
            states,
            // 켜짐 상태 테두리는 트랙과 같은 색으로 둔다.
            states.contains(WidgetState.selected)
                ? c.accentText
                : c.cellOutline,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accentText),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceContainer,
        modalBackgroundColor: c.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: c.cellOutline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shadowColor: shadow,
        elevation: AppElevation.card,
        shape: cardShape,
      ),
    );
  }
}

/// 감속 모드(`MediaQuery.disableAnimations`)에서 잉크 물결을 끈다.
///
/// 물결 연출이 남아 있으면 탭 직후 `hasRunningAnimations`가 true로 남아
/// AC-UI-14(감속 모드에서 두 프레임 안에 연출 종료)를 만족할 수 없다.
class ReducedMotionTheme extends StatelessWidget {
  const ReducedMotionTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!MediaQuery.disableAnimationsOf(context)) return child;
    return Theme(
      data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
      child: child,
    );
  }
}
