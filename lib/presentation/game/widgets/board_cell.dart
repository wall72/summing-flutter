import 'package:flutter/material.dart';
import 'package:summing_flutter/domain/summing_cell.dart';
import 'package:summing_flutter/presentation/theme/app_motion.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

/// 셀 하나에 붙는 연출 종류 (`design.md` §7).
enum CellEffectKind { place, match }

/// 직전 보드와 비교해 셀 하나에 정해진 연출.
@immutable
class CellEffect {
  const CellEffect.place()
      : kind = CellEffectKind.place,
        digit = null;

  const CellEffect.match(int this.digit) : kind = CellEffectKind.match;

  final CellEffectKind kind;

  /// 매치로 지워지기 전 숫자. [CellEffectKind.match]일 때만 있다.
  final int? digit;
}

/// 보드 칸 하나 (`design.md` §5 보드 셀).
///
/// 모든 칸에 cellOutline 1px 외곽선을 그리고, 그림자는 쓰지 않는다. 연출은 implicit
/// 애니메이션(TweenAnimationBuilder)만 쓰며 [effect]가 있는 칸에만 붙는다 (웹 성능).
/// 연출 키 `cell.<i>.place`, `cell.<i>.match`, `cell.<i>.focusRing`으로 테스트가 판정한다.
class BoardCell extends StatefulWidget {
  const BoardCell({
    super.key,
    required this.index,
    required this.cell,
    required this.digitSize,
    this.effect,
    this.onTap,
  });

  /// 보드 위 선형 위치 (0~80). 연출 키에 쓴다.
  final int index;
  final SummingCell cell;

  /// 셀 숫자 크기 = 셀 한 변 × [AppTypeScale.cellDigitRatio].
  final double digitSize;

  /// 직전 수가 이 칸에 정한 연출. 규칙상 같은 칸이 두 턴 연속 같은 연출을 받는 일은 없어
  /// 연출 위젯은 연출이 바뀔 때마다 새로 만들어지고 처음부터 재생된다.
  final CellEffect? effect;

  /// null이면 탭할 수 없는 칸 (숫자 칸, 또는 플레이 중이 아님).
  final VoidCallback? onTap;

  @override
  State<BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<BoardCell> {
  bool _focused = false;

  void _onFocusChange(bool focused) {
    if (mounted) setState(() => _focused = focused);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final cell = widget.cell;
    final effect = widget.effect;
    final onTap = widget.onTap;
    final index = widget.index;
    final placing = effect?.kind == CellEffectKind.place;

    final digitStyle = TextStyle(
      fontSize: widget.digitSize,
      fontWeight: FontWeight.w800,
      color: palette.onSurface,
    );
    Widget digit(int value) => Center(child: Text('$value', style: digitStyle));

    final outline = Border.all(
      color: palette.cellOutline,
      width: AppStroke.outline,
    );

    // 배치 팝 동안 바닥은 빈 칸이고, 그 위에서 채운 칸이 커지며 나타난다.
    final fill =
        cell.isAssigned && !placing ? palette.cellFilled : palette.cellEmpty;

    final Widget? effectLayer = switch (effect?.kind) {
      null => null,
      CellEffectKind.place => TweenAnimationBuilder<double>(
          key: ValueKey('cell.$index.place'),
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.of(context, AppMotion.base),
          curve: AppMotion.placeCurve,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.placeHighlight,
              borderRadius: AppRadius.cell,
              border: outline,
            ),
            child: digit(cell.value),
          ),
          builder: (context, t, child) => Opacity(
            // easeOutBack은 끝에서 1을 살짝 넘으므로 불투명도만 0~1로 자른다.
            opacity: t.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: AppMotion.placeStartScale +
                  (1 - AppMotion.placeStartScale) * t,
              child: child,
            ),
          ),
        ),
      CellEffectKind.match => TweenAnimationBuilder<double>(
          key: ValueKey('cell.$index.match'),
          tween: Tween(begin: 1, end: 0),
          duration: AppMotion.of(context, AppMotion.emphasized),
          curve: AppMotion.emphasizedCurve,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.matchFlash,
              borderRadius: AppRadius.cell,
              border: outline,
            ),
            child: digit(effect!.digit!),
          ),
          builder: (context, t, child) => Opacity(opacity: t, child: child),
        ),
    };

    return Semantics(
      // 숫자·연출 위젯의 의미 정보는 빼고, 칸 하나가 버튼 하나로 읽히게 한다 (AC-UI-21).
      container: true,
      excludeSemantics: true,
      label: cell.isAssigned ? '${cell.value}' : 'Empty cell',
      button: onTap != null,
      onTap: onTap,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.cell,
            border: outline,
          ),
          child: InkWell(
            onTap: onTap,
            onFocusChange: _onFocusChange,
            borderRadius: AppRadius.cell,
            // 빈 칸은 hover·press 때 cellFilled를 덧칠해 살짝 밝아진다 (design.md §5).
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return palette.cellFilled
                    .withValues(alpha: AppStateLayer.pressed);
              }
              if (states.contains(WidgetState.hovered)) {
                return palette.cellFilled
                    .withValues(alpha: AppStateLayer.hover);
              }
              // 포커스는 덧칠 대신 아래 링으로 보인다.
              return Colors.transparent;
            }),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cell.isAssigned && !placing) digit(cell.value),
                if (effectLayer != null) effectLayer,
                // 포커스된 빈 칸이 채워지면 포커스 해제 알림보다 먼저 같은 프레임에서 링을 뺀다.
                if (_focused && onTap != null)
                  DecoratedBox(
                    key: ValueKey('cell.$index.focusRing'),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.cell,
                      border: Border.all(
                        color: palette.focus,
                        width: AppStroke.emphasis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
