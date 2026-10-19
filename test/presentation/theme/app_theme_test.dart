import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/main.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';
import 'package:summing_flutter/presentation/game/widgets/end_overlay.dart';
import 'package:summing_flutter/presentation/menu/menu_page.dart';
import 'package:summing_flutter/presentation/theme/app_theme.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

import '../../support/test_overrides.dart';

/// 앱 테마 검사 (SPEC-UI-001 AC-UI-01 뒷부분, 02의 게임 화면, 19, 24, `design.md` §1.1·§1.2·§3).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const disabled = {WidgetState.disabled};
  const selected = {WidgetState.selected};
  const none = <WidgetState>{};

  final themes = {
    Brightness.light: (AppTheme.light, AppPalette.light),
    Brightness.dark: (AppTheme.dark, AppPalette.dark),
  };

  for (final MapEntry(key: brightness, value: (theme, c)) in themes.entries) {
    group('AC-UI-01 ${brightness.name} ColorScheme mapping (design.md §1.1)',
        () {
      final s = theme.colorScheme;

      test('brightness matches', () {
        expect(theme.brightness, brightness);
        expect(s.brightness, brightness);
      });

      test('primary family -> primary / onPrimary', () {
        expect(s.primary, c.primary);
        expect(s.onPrimary, c.onPrimary);
      });

      test('primaryContainer and secondaryContainer -> queue head tokens', () {
        expect(s.primaryContainer, c.queueHeadContainer);
        expect(s.onPrimaryContainer, c.onQueueHead);
        expect(s.secondaryContainer, c.queueHeadContainer);
        expect(s.onSecondaryContainer, c.onQueueHead);
      });

      test('surface roles -> background / onSurface / onSurfaceVariant', () {
        expect(s.surface, c.background);
        expect(s.onSurface, c.onSurface);
        expect(s.onSurfaceVariant, c.onSurfaceVariant);
      });

      test('surface containers -> surfaceContainer, highest -> cellEmpty', () {
        expect(s.surfaceContainerLowest, c.surfaceContainer);
        expect(s.surfaceContainerLow, c.surfaceContainer);
        expect(s.surfaceContainer, c.surfaceContainer);
        expect(s.surfaceContainerHigh, c.surfaceContainer);
        expect(s.surfaceContainerHighest, c.cellEmpty);
      });

      test('outline -> cellOutline, outlineVariant -> cellEmpty', () {
        expect(s.outline, c.cellOutline);
        expect(s.outlineVariant, c.cellEmpty);
      });

      test('inverse roles -> inverse tokens', () {
        expect(s.inverseSurface, c.inverseSurface);
        expect(s.onInverseSurface, c.onInverseSurface);
        expect(s.inversePrimary, c.inversePrimary);
      });

      test('surfaceTint is transparent', () {
        expect(s.surfaceTint, Colors.transparent);
      });

      test('error and tertiary keep the Material default', () {
        final material = ThemeData(brightness: brightness).colorScheme;
        expect(s.error, material.error);
        expect(s.onError, material.onError);
        expect(s.tertiary, material.tertiary);
        expect(s.onTertiary, material.onTertiary);
      });

      test('the token palette is reachable as a theme extension', () {
        expect(theme.extension<AppPalette>(), same(c));
      });
    });

    group('AC-UI-01 ${brightness.name} component themes (design.md §1.2)', () {
      test('TextButton foreground is accentText, disabled falls back', () {
        final style = theme.textButtonTheme.style!;
        expect(style.foregroundColor!.resolve(none), c.accentText);
        expect(style.foregroundColor!.resolve(disabled), isNull);
        // 상태 레이어는 전경색 10% (눌림). Material은 alpha를 8비트로 저장한다(0x1A = 0.102).
        final pressed = style.overlayColor!.resolve({WidgetState.pressed})!;
        expect(pressed.withValues(alpha: 1), c.accentText);
        expect(pressed.a, closeTo(0.1, 1 / 255));
      });

      test('OutlinedButton foreground accentText, border cellOutline', () {
        final style = theme.outlinedButtonTheme.style!;
        expect(style.foregroundColor!.resolve(none), c.accentText);
        expect(style.side!.resolve(none)?.color, c.cellOutline);
        expect(style.side!.resolve(disabled), isNull);
      });

      test('Switch on: track accentText, thumb onAccent', () {
        final t = theme.switchTheme;
        expect(t.trackColor!.resolve(selected), c.accentText);
        expect(t.thumbColor!.resolve(selected), c.onAccent);
      });

      test(
          'Switch off: track cellEmpty, outline cellOutline, thumb onSurfaceVariant',
          () {
        final t = theme.switchTheme;
        expect(t.trackColor!.resolve(none), c.cellEmpty);
        expect(t.trackOutlineColor!.resolve(none), c.cellOutline);
        expect(t.thumbColor!.resolve(none), c.onSurfaceVariant);
      });

      test('disabled Switch falls back to the Material default', () {
        final t = theme.switchTheme;
        expect(t.trackColor!.resolve({...disabled, ...selected}), isNull);
        expect(t.thumbColor!.resolve(disabled), isNull);
        expect(t.trackOutlineColor!.resolve(disabled), isNull);
      });

      test('progress indicator uses accentText', () {
        expect(theme.progressIndicatorTheme.color, c.accentText);
      });

      test('bottom sheet: surfaceContainer background, cellOutline handle', () {
        final t = theme.bottomSheetTheme;
        expect(t.backgroundColor, c.surfaceContainer);
        expect(t.modalBackgroundColor, c.surfaceContainer);
        expect(t.dragHandleColor, c.cellOutline);
        expect(t.surfaceTintColor, Colors.transparent);
      });

      test('dialog and card use surfaceContainer', () {
        expect(theme.dialogTheme.backgroundColor, c.surfaceContainer);
        expect(theme.cardTheme.color, c.surfaceContainer);
      });

      test('app bar uses background without tint', () {
        expect(theme.appBarTheme.backgroundColor, c.background);
        expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
      });
    });

    group('AC-UI-19 ${brightness.name} typography (design.md §3)', () {
      final t = theme.textTheme;

      test('every text style uses Nunito', () {
        for (final style in [
          t.displaySmall,
          t.headlineSmall,
          t.titleLarge,
          t.titleMedium,
          t.titleSmall,
          t.bodyLarge,
          t.bodyMedium,
          t.labelLarge,
        ]) {
          expect(style?.fontFamily, 'Nunito');
        }
      });

      test('sizes and weights follow the type scale', () {
        expect(t.displaySmall?.fontSize, 40);
        expect(t.displaySmall?.fontWeight, FontWeight.w800);
        expect(t.headlineSmall?.fontSize, 28);
        expect(t.headlineSmall?.fontWeight, FontWeight.w800);
        expect(t.titleLarge?.fontSize, 20);
        expect(t.titleLarge?.fontWeight, FontWeight.w700);
        expect(t.bodyLarge?.fontSize, 16);
        expect(t.bodyLarge?.fontWeight, FontWeight.w400);
        expect(t.bodyMedium?.fontSize, 16);
        expect(t.labelLarge?.fontSize, 14);
        expect(t.labelLarge?.fontWeight, FontWeight.w700);
      });
    });
  }

  group('AppPalette theme extension', () {
    final light = AppPalette.light;
    final dark = AppPalette.dark;

    test('lerp endpoints are the two palettes', () {
      expect(light.lerp(dark, 0).background, light.background);
      expect(light.lerp(dark, 1).background, dark.background);
      expect(light.lerp(dark, 1).scrim, dark.scrim);
      expect(light.lerp(null, 0.5), same(light));
    });

    test('lerp midpoint mixes every token', () {
      final mid = light.lerp(dark, 0.5);
      expect(mid.onSurface, Color.lerp(light.onSurface, dark.onSurface, 0.5));
      expect(mid.cellEmpty, Color.lerp(light.cellEmpty, dark.cellEmpty, 0.5));
      expect(mid.inversePrimary,
          Color.lerp(light.inversePrimary, dark.inversePrimary, 0.5));
    });

    test('copyWith replaces only the given token', () {
      final changed = light.copyWith(focus: dark.focus);
      expect(changed.focus, dark.focus);
      expect(changed.accentText, light.accentText);
      expect(changed.scrim, light.scrim);
      expect(light.copyWith().cellOutline, light.cellOutline);
    });

    testWidgets('of(context) falls back by brightness without the extension',
        (tester) async {
      late AppPalette lightFallback;
      late AppPalette darkFallback;
      await tester.pumpWidget(
        Column(
          children: [
            Theme(
              data: ThemeData(brightness: Brightness.light),
              child: Builder(builder: (context) {
                lightFallback = AppPalette.of(context);
                return const SizedBox.shrink();
              }),
            ),
            Theme(
              data: ThemeData(brightness: Brightness.dark),
              child: Builder(builder: (context) {
                darkFallback = AppPalette.of(context);
                return const SizedBox.shrink();
              }),
            ),
          ],
        ),
      );
      expect(lightFallback, same(AppPalette.light));
      expect(darkFallback, same(AppPalette.dark));
    });
  });

  testWidgets(
      'a rendered TextButton label uses accentText, not the pink primary',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TextButton(onPressed: () {}, child: const Text('Cancel')),
        ),
      ),
    );

    final label = tester.widget<RichText>(
      find.descendant(
          of: find.byType(TextButton), matching: find.byType(RichText)),
    );
    expect(label.text.style?.color, AppPalette.light.accentText);
  });

  group('reduced motion (D32, AC-UI-14 prerequisite)', () {
    Future<InteractiveInkFeatureFactory> splashUnder(
      WidgetTester tester, {
      required bool disableAnimations,
    }) async {
      late InteractiveInkFeatureFactory splash;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Theme(
            data: AppTheme.light,
            child: ReducedMotionTheme(
              child: Builder(
                builder: (context) {
                  splash = Theme.of(context).splashFactory;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      return splash;
    }

    testWidgets('disableAnimations switches ink splashes off', (tester) async {
      expect(
        await splashUnder(tester, disableAnimations: true),
        same(NoSplash.splashFactory),
      );
    });

    testWidgets('normal motion keeps the theme splash', (tester) async {
      expect(
        await splashUnder(tester, disableAnimations: false),
        same(AppTheme.light.splashFactory),
      );
      expect(AppTheme.light.splashFactory, isNot(same(NoSplash.splashFactory)));
    });
  });

  group('SummingApp wiring', () {
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: FakePorts().overrides(),
          child: const SummingApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('AC-UI-24 themeMode follows the system, no in-app theme switch',
        (tester) async {
      await pumpApp(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.system);
      expect(app.theme, same(AppTheme.light));
      expect(app.darkTheme, same(AppTheme.dark));

      expect(find.byType(SwitchListTile), findsNWidgets(2));
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Sound effects'), findsOneWidget);
      expect(
        find.textContaining(RegExp('theme|dark mode', caseSensitive: false)),
        findsNothing,
      );
    });

    testWidgets('AC-UI-24 platform brightness dark switches the theme',
        (tester) async {
      await pumpApp(tester);
      expect(
        Theme.of(tester.element(find.byType(MenuPage))).brightness,
        Brightness.light,
      );

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpAndSettle();

      expect(
        Theme.of(tester.element(find.byType(MenuPage))).brightness,
        Brightness.dark,
      );
    });

    testWidgets('platform reduced motion reaches the app theme',
        (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await pumpApp(tester);

      expect(
        Theme.of(tester.element(find.byType(MenuPage))).splashFactory,
        same(NoSplash.splashFactory),
      );
    });

    testWidgets('AC-UI-19 MenuPage renders with the bundled font',
        (tester) async {
      await pumpApp(tester);
      expect(find.text('New Game'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(MenuPage)))
            .textTheme
            .bodyMedium
            ?.fontFamily,
        'Nunito',
      );
    });
  });

  test('AC-UI-19 pubspec declares Nunito 400 and 800 and the files exist', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('fonts:'));
    expect(pubspec, contains('- family: Nunito'));
    expect(pubspec, contains('- asset: assets/fonts/Nunito-Regular.ttf'));
    expect(pubspec, contains('- asset: assets/fonts/Nunito-ExtraBold.ttf'));
    expect(RegExp(r'weight: 800').hasMatch(pubspec), isTrue);

    for (final path in [
      'assets/fonts/Nunito-Regular.ttf',
      'assets/fonts/Nunito-ExtraBold.ttf',
      'assets/fonts/OFL.txt',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });

  group('AC-UI-02 game screens meet text contrast', () {
    GameState playingAtTurn3() {
      final cells =
          List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
      cells[40] = const SummingCell.filled(7);
      return GameState(
        board: Board.fromCells(cells),
        queue: NextQueue(const [1, 2, 3, 4]),
        turnCount: 3,
      );
    }

    /// 칸 40에 7을 놓으면 이웃(41의 7)이 매치로 지워져 complete가 되는 상태.
    GameState oneMoveFromComplete() {
      final cells =
          List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
      cells[41] = const SummingCell.filled(7);
      return GameState(
        board: Board.fromCells(cells),
        queue: NextQueue(const [7, 1, 2, 3]),
        turnCount: 5,
      );
    }

    Future<void> pumpGame(
      WidgetTester tester,
      GameState state,
      ThemeMode mode,
    ) async {
      final fakes = FakePorts();
      fakes.gameSave.stored = state;
      final container = ProviderContainer(overrides: fakes.overrides());
      addTearDown(container.dispose);
      await container.read(gameAudioProvider.future);
      await container.read(gameSessionProvider.notifier).resumeGame();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            home: const GamePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('${mode.name}: known playing state', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpGame(tester, playingAtTurn3(), mode);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('${mode.name}: restart dialog open', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpGame(tester, playingAtTurn3(), mode);
        await tester.tap(find.text('Restart'));
        await tester.pumpAndSettle();
        expect(find.text('Restart game?'), findsOneWidget);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('${mode.name}: end overlay on the scrim token',
          (tester) async {
        final handle = tester.ensureSemantics();
        await pumpGame(tester, oneMoveFromComplete(), mode);
        await tester.tap(find.byKey(const ValueKey('cell.40')));
        await tester.pumpAndSettle();
        expect(find.text('Complete!'), findsOneWidget);

        final colors =
            mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
        final scrim = tester.widget<ColoredBox>(
          find
              .descendant(
                of: find.byType(EndOverlay),
                matching: find.byType(ColoredBox),
              )
              .first,
        );
        expect(scrim.color, colors.scrim);

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  });
}
