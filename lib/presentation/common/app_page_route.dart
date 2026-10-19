import 'package:flutter/widgets.dart';
import 'package:summing_flutter/presentation/theme/app_motion.dart';

/// 앱 화면 전환 route: fade + scale(0.96 → 1.0), page 320ms, easeOutCubic (`design.md` §6, REQ-UI-017).
///
/// 패키지 없이 [PageRoute]만으로 구현한다. 감속 모드에서는 전환 시간이 0이다 (REQ-UI-018).
class AppPageRoute<T> extends PageRoute<T> {
  AppPageRoute({required this.builder, super.settings});

  final WidgetBuilder builder;

  // @MX:NOTE: [AUTO] 전환 시간은 route가 AnimationController를 만들 때(install) 한 번 읽힌다. 감속 모드는 Navigator 위 MediaQuery에서 의존 등록 없이 읽어 0으로 만든다. 위젯의 AppMotion.of와 같은 규칙이다(AC-UI-14, AC-UI-20)
  @override
  Duration get transitionDuration {
    final media =
        navigator?.context.getInheritedWidgetOfExactType<MediaQuery>();
    final reduced = media?.data.disableAnimations ?? false;
    return reduced ? Duration.zero : AppMotion.page;
  }

  @override
  bool get opaque => true;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = CurveTween(curve: AppMotion.pageCurve);
    return FadeTransition(
      opacity: animation.drive(curve),
      child: ScaleTransition(
        scale: animation.drive(
          Tween<double>(begin: AppMotion.enterStartScale, end: 1.0)
              .chain(curve),
        ),
        child: child,
      ),
    );
  }
}
