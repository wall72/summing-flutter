import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// @MX:NOTE: [AUTO] 계층 규칙(presentation → application → domain)의 기계적 검사 지점. AC-ARCH-01 grep과 같은 패턴을 쓴다
/// `lib/application`, `lib/presentation`은 `lib/infrastructure`를 import 하지 않는다
/// (package import, 상대 경로 import 모두. REQ-ARCH-001).
final _infrastructureImport = RegExp(r'import .*infrastructure/');

List<String> _violations(String dir) {
  final violations = <String>[];
  final files = Directory(dir)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (_infrastructureImport.hasMatch(lines[i])) {
        violations.add('${file.path}:${i + 1}: ${lines[i]}');
      }
    }
  }
  return violations;
}

void main() {
  for (final dir in ['lib/application', 'lib/presentation']) {
    test('$dir does not import lib/infrastructure', () {
      expect(Directory(dir).existsSync(), isTrue, reason: 'run from root');
      expect(_violations(dir), isEmpty);
    });
  }

  test('the pattern catches package and relative infrastructure imports', () {
    expect(
      _infrastructureImport.hasMatch(
        "import 'package:summing_flutter/infrastructure/app_overrides.dart';",
      ),
      isTrue,
    );
    expect(
      _infrastructureImport
          .hasMatch("import '../infrastructure/persistence/x.dart';"),
      isTrue,
    );
    expect(
      _infrastructureImport
          .hasMatch("import 'package:summing_flutter/domain/board.dart';"),
      isFalse,
    );
  });
}
