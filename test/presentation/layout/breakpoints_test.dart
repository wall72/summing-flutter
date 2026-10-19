import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/presentation/layout/breakpoints.dart';

/// 배치 클래스 판정 순서 (`design.md` §4): 저높이 가로 → expanded → medium → compact.
void main() {
  final cases = <Size, LayoutClass>{
    // compact
    const Size(320, 568): LayoutClass.compact,
    const Size(360, 780): LayoutClass.compact,
    const Size(599, 640): LayoutClass.compact,
    const Size(400, 400): LayoutClass.compact, // 폭·높이 모두 480 미만
    const Size(479, 320): LayoutClass.compact, // 폭 < 480이면 저높이 아님
    // medium
    const Size(600, 1000): LayoutClass.medium,
    const Size(700, 1000): LayoutClass.medium,
    const Size(839, 480): LayoutClass.medium,
    // expanded
    const Size(840, 480): LayoutClass.expanded,
    const Size(1280, 800): LayoutClass.expanded,
    const Size(1920, 1080): LayoutClass.expanded,
    // 저높이 가로 (먼저 맞는 규칙)
    const Size(480, 479): LayoutClass.lowHeightLandscape,
    const Size(480, 320): LayoutClass.lowHeightLandscape,
    const Size(568, 320): LayoutClass.lowHeightLandscape,
    const Size(740, 360): LayoutClass.lowHeightLandscape,
    const Size(700, 479): LayoutClass.lowHeightLandscape,
    const Size(1280, 400): LayoutClass.lowHeightLandscape,
  };

  for (final entry in cases.entries) {
    test('${entry.key.width}x${entry.key.height} -> ${entry.value.name}', () {
      expect(layoutClassFor(entry.key), entry.value);
    });
  }

  test('low-height landscape board side = min(h - 12, w - 224)', () {
    expect(lowHeightBoardSide(const Size(568, 320)), 308);
    expect(lowHeightBoardSide(const Size(740, 360)), 348);
    expect(lowHeightBoardSide(const Size(480, 320)), 256);
  });
}
