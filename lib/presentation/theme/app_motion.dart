import 'package:flutter/widgets.dart';

/// 모션 토큰 (`design.md` §6). 시간과 커브 리터럴은 이 파일에만 둔다 (AC-UI-23).
///
/// 위젯은 시간을 [AppMotion.of]로 읽는다. 무한 반복 애니메이션은 쓰지 않는다 (REQ-UI-019).
abstract final class AppMotion {
  /// 탭 반응, hover.
  static const Duration fast = Duration(milliseconds: 120);

  /// 배치 팝, 큐 이동.
  static const Duration base = Duration(milliseconds: 200);

  /// 매치 소거, 종료 오버레이 진입.
  static const Duration emphasized = Duration(milliseconds: 300);

  /// 화면 전환.
  static const Duration page = Duration(milliseconds: 320);

  /// 배치 팝 (scale [placeStartScale] → 1.0 + fade). 끝에서 살짝 넘쳤다 돌아온다.
  static const Curve placeCurve = Curves.easeOutBack;

  /// 큐 이동. easeOutBack은 절반 시점 값이 1.0676으로 제자리를 지나쳐 쓰지 않는다 (AC-UI-15).
  static const Curve queueShiftCurve = Curves.easeOutCubic;

  /// 매치 소거(민트 flash → fade out), 종료 오버레이 진입.
  static const Curve emphasizedCurve = Curves.easeOutCubic;
  static const Curve pageCurve = Curves.easeOutCubic;

  /// 배치 팝 시작 크기.
  static const double placeStartScale = 0.85;

  // @MX:NOTE: [AUTO] 감속 모드(MediaQuery.disableAnimations)에서는 모든 시간을 0으로 돌려 연출이 첫 프레임에 끝나게 한다(REQ-UI-018, AC-UI-14). 애니메이션 시간은 반드시 이 함수를 거쳐야 하며, 상수를 위젯에 직접 넘기면 감속 모드가 적용되지 않는다
  /// [duration]을 현재 모션 설정에 맞춰 돌려준다. 감속 모드면 [Duration.zero].
  static Duration of(BuildContext context, Duration duration) {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return reduced ? Duration.zero : duration;
  }
}
