import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// 게임 화면 배치 클래스 (`design.md` §4).
enum LayoutClass { lowHeightLandscape, expanded, medium, compact }

/// 폭 브레이크포인트는 Material 3 window size class(600 / 840),
/// 높이 기준은 Material 3 height class의 compact 경계(480)를 쓴다.
abstract final class Breakpoints {
  static const double mediumMinWidth = 600;
  static const double expandedMinWidth = 840;

  /// 이 높이 미만이면서 폭이 [lowHeightMinWidth] 이상이면 저높이 가로 배치.
  static const double lowHeightMaxHeight = 480;
  static const double lowHeightMinWidth = 480;
}

// @MX:NOTE: [AUTO] 배치 판정은 먼저 맞는 규칙 순서: 저높이 가로(높이 < 480, 폭 ≥ 480) → expanded(폭 ≥ 840) → medium(600–839) → compact. 순서를 바꾸면 1280×400 같은 넓고 낮은 창이 expanded로 잘못 분류된다
LayoutClass layoutClassFor(Size size) {
  if (size.height < Breakpoints.lowHeightMaxHeight &&
      size.width >= Breakpoints.lowHeightMinWidth) {
    return LayoutClass.lowHeightLandscape;
  }
  if (size.width >= Breakpoints.expandedMinWidth) return LayoutClass.expanded;
  if (size.width >= Breakpoints.mediumMinWidth) return LayoutClass.medium;
  return LayoutClass.compact;
}

/// 게임 화면 배치 수치 (`design.md` §2, §4). 디자인 토큰 소스(`spec.md` §D) 안에 둔다.
abstract final class GameLayout {
  // @MX:NOTE: [AUTO] compact 보드 좌우 여백 6은 360 폭에서 셀 36.44를 만드는 값이다. 8로 늘리면 셀이 정확히 36.00이 되어 여유가 없다 (design.md §4)
  static const double compactBoardMargin = 6;
  static const double mediumBoardMargin = 16;
  static const double expandedBoardMargin = 24;

  /// medium 보드 한 변 상한.
  static const double mediumBoardMaxSide = 560;

  /// expanded 보드 한 변 상한.
  static const double expandedBoardMaxSide = 640;

  /// expanded 사이드 패널 폭 (설계 범위 280–320 중 큐 한 줄이 들어가는 값).
  static const double expandedPanelWidth = 320;

  /// 보드와 사이드 패널 사이 간격.
  static const double paneGap = 12;

  /// 저높이 가로: 화면 가장자리 여백, 사이드 패널 최소 폭, 패널 안쪽 여백(상한 8).
  static const double lowHeightEdge = 6;
  static const double lowHeightPanelMinWidth = 200;
  static const double lowHeightPanelPadding = 6;

  /// 저높이 가로 큐 칸 폭 (나머지 배치는 [queueSlotSize]).
  static const double lowHeightQueueSlotSize = 40;
  static const double queueSlotSize = 44;

  /// 큐 칸 사이 간격과 `Next:` 라벨과 칸 사이 간격.
  static const double queueSlotGap = 8;
  static const double queueLabelGap = 12;
  static const double queueLabelGapAbove = 4;

  /// 세로로 쌓는 요소 사이 간격.
  static const double gapSmall = 8;
  static const double gapMedium = 12;
  static const double gapLarge = 16;
}

/// 메뉴·점수판 배치 수치 (`design.md` §4).
abstract final class ScreenLayout {
  /// compact·medium 메뉴의 가운데 카드 최대 폭.
  static const double menuCardMaxWidth = 440;

  /// 점수판 목록 최대 폭 (medium 이상에서 가운데 정렬).
  static const double listMaxWidth = 560;
}

/// 저높이 가로 보드 한 변 =min(높이 − 위아래 여백, 폭 − 왼쪽 여백 − 칸 사이 − 오른쪽 여백 − 패널 최소 폭).
double lowHeightBoardSide(Size size) {
  const edge = GameLayout.lowHeightEdge;
  final side = math.min(
    size.height - 2 * edge,
    size.width -
        edge -
        GameLayout.paneGap -
        edge -
        GameLayout.lowHeightPanelMinWidth,
  );
  return math.max(0.0, side);
}
