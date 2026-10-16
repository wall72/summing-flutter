import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/presentation/theme/app_motion.dart';

/// 모션 토큰과 감속 모드 (`design.md` §6, REQ-UI-018).
void main() {
  test('motion durations and curves follow design.md §6', () {
    expect(AppMotion.fast, const Duration(milliseconds: 120));
    expect(AppMotion.base, const Duration(milliseconds: 200));
    expect(AppMotion.emphasized, const Duration(milliseconds: 300));
    expect(AppMotion.page, const Duration(milliseconds: 320));
    expect(AppMotion.placeCurve, Curves.easeOutBack);
    expect(AppMotion.queueShiftCurve, Curves.easeOutCubic);
    expect(AppMotion.emphasizedCurve, Curves.easeOutCubic);
    expect(AppMotion.pageCurve, Curves.easeOutCubic);
    expect(AppMotion.placeStartScale, 0.85);
    // 큐 이동에 easeOutBack을 쓰면 절반 시점에 제자리를 지나친다 (AC-UI-15).
    // Curves.easeOutCubic은 3차 베지어 근사라 0.875에서 약 0.0001 벗어난다.
    expect(AppMotion.queueShiftCurve.transform(0.5), closeTo(0.875, 0.001));
  });

  Future<Duration> resolveUnder(
    WidgetTester tester,
    Duration duration, {
    bool? disableAnimations,
  }) async {
    late Duration resolved;
    final probe = Builder(
      builder: (context) {
        resolved = AppMotion.of(context, duration);
        return const SizedBox.shrink();
      },
    );
    await tester.pumpWidget(
      disableAnimations == null
          ? probe
          : MediaQuery(
              data: MediaQueryData(disableAnimations: disableAnimations),
              child: probe,
            ),
    );
    return resolved;
  }

  testWidgets('normal motion keeps the duration', (tester) async {
    expect(
      await resolveUnder(tester, AppMotion.base, disableAnimations: false),
      AppMotion.base,
    );
  });

  testWidgets('reduced motion resolves every duration to zero', (tester) async {
    for (final d in [
      AppMotion.fast,
      AppMotion.base,
      AppMotion.emphasized,
      AppMotion.page,
    ]) {
      expect(
        await resolveUnder(tester, d, disableAnimations: true),
        Duration.zero,
      );
    }
  });

  testWidgets('no MediaQuery above → normal motion', (tester) async {
    expect(await resolveUnder(tester, AppMotion.base), AppMotion.base);
  });
}
