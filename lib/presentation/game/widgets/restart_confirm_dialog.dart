import 'package:flutter/material.dart';

/// 진행 중인 판을 다시 시작하기 전에 묻는 확인 대화상자 (`design.md` §5).
class RestartConfirmDialog extends StatelessWidget {
  const RestartConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restart game?'),
      content: Text(
        'Your current progress will be lost.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Restart'),
        ),
      ],
    );
  }
}

// @MX:NOTE: [AUTO] 확인하면 true, Cancel·배리어 탭·Esc·시스템 뒤로 가기로 닫으면 false. 호출처는 GamePage의 재시작 guard 하나뿐이다(상단 바와 사이드 패널이 같은 guard를 공유)
/// 재시작 확인 대화상자를 띄우고, 사용자가 확인했을 때만 true를 돌려준다.
Future<bool> showRestartConfirmDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => const RestartConfirmDialog(),
  );
  return confirmed ?? false;
}
