import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

/// 색상 토큰 값과 대비 검사 (SPEC-UI-001 AC-UI-01 앞부분, `design.md` §1).
///
/// 대비는 WCAG 공식 `(L1 + 0.05) / (L2 + 0.05)`를 `Color.computeLuminance()`로
/// 직접 계산한다. 기대 비율을 하드코딩하지 않고 기준값(4.5 / 3.0)과만 비교한다.
void main() {
  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Material 상태 레이어 최악값: 전경색 10%를 배경에 덧칠한 색 (`design.md` §1.2).
  Color stateLayer(Color foreground, Color background) =>
      Color.alphaBlend(foreground.withValues(alpha: 0.1), background);

  /// (이름, 전경, 배경) 텍스트 쌍. 기준 4.5.
  List<(String, Color, Color)> textPairs(AppPalette c) => [
        ('digit / cellFilled', c.onSurface, c.cellFilled),
        ('digit / placeHighlight', c.onSurface, c.placeHighlight),
        ('digit / matchFlash', c.onSurface, c.matchFlash),
        ('onSurface / background', c.onSurface, c.background),
        ('onSurface / surfaceContainer', c.onSurface, c.surfaceContainer),
        ('onSurfaceVariant / background', c.onSurfaceVariant, c.background),
        (
          'onSurfaceVariant / surfaceContainer',
          c.onSurfaceVariant,
          c.surfaceContainer,
        ),
        ('onPrimary / primary', c.onPrimary, c.primary),
        (
          'onQueueHead / queueHeadContainer',
          c.onQueueHead,
          c.queueHeadContainer
        ),
        ('accentText / background', c.accentText, c.background),
        ('accentText / surfaceContainer', c.accentText, c.surfaceContainer),
        (
          'onInverseSurface / inverseSurface',
          c.onInverseSurface,
          c.inverseSurface,
        ),
        ('inversePrimary / inverseSurface', c.inversePrimary, c.inverseSurface),
        (
          'accentText / state layer on background',
          c.accentText,
          stateLayer(c.accentText, c.background),
        ),
        (
          'accentText / state layer on surfaceContainer',
          c.accentText,
          stateLayer(c.accentText, c.surfaceContainer),
        ),
        (
          'onPrimary / state layer on primary',
          c.onPrimary,
          stateLayer(c.onPrimary, c.primary),
        ),
        (
          'onQueueHead / state layer on queueHeadContainer',
          c.onQueueHead,
          stateLayer(c.onQueueHead, c.queueHeadContainer),
        ),
      ];

  /// (이름, 전경, 배경) 비텍스트 쌍. 기준 3.0.
  List<(String, Color, Color)> nonTextPairs(AppPalette c) => [
        ('focus / cellEmpty', c.focus, c.cellEmpty),
        ('focus / cellFilled', c.focus, c.cellFilled),
        ('focus / board frame', c.focus, c.surfaceContainer),
        ('cellOutline / surfaceContainer', c.cellOutline, c.surfaceContainer),
        ('cellOutline / background', c.cellOutline, c.background),
        ('switch on: thumb / track', c.onAccent, c.accentText),
        ('switch on: track / background', c.accentText, c.background),
        ('switch off: thumb / track', c.onSurfaceVariant, c.cellEmpty),
        ('progress indicator / background', c.accentText, c.background),
        ('queueHeadOutline / background', c.queueHeadOutline, c.background),
        (
          'queueHeadOutline / surfaceContainer',
          c.queueHeadOutline,
          c.surfaceContainer,
        ),
        (
          'queueHeadOutline / queueHeadContainer',
          c.queueHeadOutline,
          c.queueHeadContainer,
        ),
      ];

  final palettes = {'light': AppPalette.light, 'dark': AppPalette.dark};

  for (final MapEntry(key: name, value: colors) in palettes.entries) {
    group('AC-UI-01 $name palette', () {
      for (final (label, fg, bg) in textPairs(colors)) {
        test('text $label >= 4.5', () {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }
      for (final (label, fg, bg) in nonTextPairs(colors)) {
        test('non-text $label >= 3.0', () {
          expect(contrast(fg, bg), greaterThanOrEqualTo(3.0));
        });
      }
    });
  }

  group('token values follow design.md §1', () {
    test('light palette', () {
      final c = AppPalette.light;
      expect(c.background, const Color(0xFFFFF8F1));
      expect(c.surfaceContainer, const Color(0xFFFFFFFF));
      expect(c.onSurface, const Color(0xFF2E2A3A));
      expect(c.onSurfaceVariant, const Color(0xFF5E5670));
      expect(c.accentText, const Color(0xFF9C3358));
      expect(c.focus, const Color(0xFF9C3358));
      expect(c.onAccent, const Color(0xFFFFFFFF));
      expect(c.cellEmpty, const Color(0xFFCEC3EB));
      expect(c.cellFilled, const Color(0xFFFFFFFF));
      expect(c.cellOutline, const Color(0xFF8E80B8));
      expect(c.placeHighlight, const Color(0xFFFFE1C7));
      expect(c.matchFlash, const Color(0xFFC9EEDC));
      expect(c.primary, const Color(0xFFF6B7C4));
      expect(c.onPrimary, const Color(0xFF3B1F2B));
      expect(c.queueHeadContainer, const Color(0xFFFCD9E0));
      expect(c.onQueueHead, const Color(0xFF3B1F2B));
      expect(c.queueHeadOutline, const Color(0xFF9C3358));
      expect(c.inverseSurface, const Color(0xFF2E2A3A));
      expect(c.onInverseSurface, const Color(0xFFF4EFFF));
      expect(c.inversePrimary, const Color(0xFFF4B6C2));
      expect(c.scrim, c.onSurface.withValues(alpha: 0.4));
    });

    test('dark palette', () {
      final c = AppPalette.dark;
      expect(c.background, const Color(0xFF1C1924));
      expect(c.surfaceContainer, const Color(0xFF262230));
      expect(c.onSurface, const Color(0xFFF4EFFF));
      expect(c.onSurfaceVariant, const Color(0xFFCFC6E0));
      expect(c.accentText, const Color(0xFFF4B6C2));
      expect(c.focus, const Color(0xFFF4B6C2));
      expect(c.onAccent, const Color(0xFF3B1F2B));
      expect(c.cellEmpty, const Color(0xFF1F1C28));
      expect(c.cellFilled, const Color(0xFF4A4266));
      expect(c.cellOutline, const Color(0xFF9C90C8));
      expect(c.placeHighlight, const Color(0xFF6B4A33));
      expect(c.matchFlash, const Color(0xFF2E5A4B));
      expect(c.primary, const Color(0xFFF4B6C2));
      expect(c.onPrimary, const Color(0xFF3B1F2B));
      expect(c.queueHeadContainer, const Color(0xFF6A3A4C));
      expect(c.onQueueHead, const Color(0xFFFFE3EA));
      expect(c.queueHeadOutline, const Color(0xFFF4B6C2));
      expect(c.inverseSurface, const Color(0xFFF4EFFF));
      expect(c.onInverseSurface, const Color(0xFF2E2A3A));
      expect(c.inversePrimary, const Color(0xFF9C3358));
      expect(c.scrim, c.background.withValues(alpha: 0.7));
    });
  });

  test(
      'the contrast helper reproduces the WCAG reference value for black on white',
      () {
    expect(contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21.0, 0.001));
  });
}
