import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

/// `web/manifest.json`의 색이 라이트 토큰과 같은지 확인한다 (SPEC-UI-001 M6).
/// 방향(`orientation`) 정책은 범위 밖이라 검사하지 않는다.
void main() {
  /// `#RRGGBB` 형식의 불투명 색 문자열.
  String hexOf(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  final manifest = jsonDecode(File('web/manifest.json').readAsStringSync())
      as Map<String, dynamic>;

  test('background_color is the cream background token', () {
    expect(
      (manifest['background_color'] as String).toUpperCase(),
      hexOf(AppPalette.light.background),
    );
  });

  test('theme_color is the pink primary token', () {
    expect(
      (manifest['theme_color'] as String).toUpperCase(),
      hexOf(AppPalette.light.primary),
    );
  });
}
