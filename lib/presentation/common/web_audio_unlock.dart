import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/port_providers.dart';

// @MX:NOTE: [AUTO] 브라우저는 첫 사용자 제스처 전까지 오디오 자동재생을 막는다. 운영 스위치는 lib/main.dart의 kIsWeb이며, 테스트는 같은 스위치를 직접 켜서 검사한다(kIsWeb는 flutter test에서 항상 false, AC-UI-22)
/// 화면 어디든 포인터가 눌리면 오디오 포트에 사용자 제스처를 알린다.
///
/// [enabled]가 false면 아무것도 감싸지 않고 [child]를 그대로 돌려준다.
/// 오디오 포트가 아직 준비 중이면 그 제스처는 조용히 건너뛴다.
class WebAudioUnlock extends ConsumerWidget {
  const WebAudioUnlock({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) return child;
    return Listener(
      // 자식의 제스처를 가로채지 않고 함께 받는다.
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) =>
          ref.read(gameAudioProvider).valueOrNull?.notifyUserGesture(),
      child: child,
    );
  }
}
