import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/app_queries.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/presentation/common/app_page_route.dart';
import 'package:summing_flutter/presentation/common/how_to_play_sheet.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';
import 'package:summing_flutter/presentation/layout/breakpoints.dart';
import 'package:summing_flutter/presentation/scores/scores_page.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  Future<void> _openGame(Future<void> Function() prepare) async {
    await prepare();
    if (!mounted) return;
    final game = ref.read(gameSessionProvider);
    if (game == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start or load the game.')),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      AppPageRoute<void>(builder: (_) => const GamePage()),
    );
    // Refresh Resume visibility / savegame state after returning from game.
    if (mounted) ref.invalidate(resumableGameProvider);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final resumableAsync = ref.watch(resumableGameProvider);

    final error = settingsAsync.error ?? resumableAsync.error;
    if (error != null) {
      return Scaffold(
        body: Center(child: Text('Load error: $error')),
      );
    }
    if (!settingsAsync.hasValue || !resumableAsync.hasValue) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final s = settingsAsync.requireValue;
    final savedGame = resumableAsync.requireValue;
    final canResume = savedGame != null;
    final settings = ref.read(settingsControllerProvider.notifier);

    // 시작 버튼 묶음: 제목, 설명, New Game, Resume Game, Scores.
    final start = <Widget>[
      Text(
        'Summing',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        'Clear the board in as few turns as possible.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppPalette.of(context).onSurfaceVariant,
            ),
      ),
      const SizedBox(height: AppSpacing.xxl),
      FilledButton(
        onPressed: () => _openGame(
          () => ref.read(gameSessionProvider.notifier).startNewGame(),
        ),
        child: const Text('New Game'),
      ),
      const SizedBox(height: AppSpacing.md),
      FilledButton.tonal(
        onPressed: canResume
            ? () => _openGame(
                  () => ref.read(gameSessionProvider.notifier).resumeGame(),
                )
            : null,
        child: Text(
          canResume
              ? 'Resume Game (${savedGame.turnCount} turns)'
              : 'Resume Game',
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      OutlinedButton(
        onPressed: () {
          Navigator.of(context).push<void>(
            AppPageRoute<void>(builder: (_) => const ScoresPage()),
          );
        },
        child: const Text('Scores'),
      ),
    ];

    final howToPlay = OutlinedButton(
      onPressed: () => showHowToPlaySheet(context),
      child: const Text('How to Play'),
    );
    final switches = <Widget>[
      SwitchListTile(
        title: const Text('Music'),
        value: s.musicOn,
        onChanged: settings.setMusicOn,
      ),
      SwitchListTile(
        title: const Text('Sound effects'),
        value: s.soundOn,
        onChanged: settings.setSoundOn,
      ),
    ];

    final layout = layoutClassFor(MediaQuery.sizeOf(context));
    final Widget body = switch (layout) {
      LayoutClass.compact || LayoutClass.medium => _SingleCardMenu(
          margin: layout == LayoutClass.compact
              ? AppSpacing.lg
              : AppSpacing.xxl,
          children: [
            ...start,
            const SizedBox(height: AppSpacing.md),
            howToPlay,
            const SizedBox(height: AppSpacing.xxl),
            ...switches,
          ],
        ),
      LayoutClass.expanded || LayoutClass.lowHeightLandscape => _TwoCardMenu(
          scrollEachCard: layout == LayoutClass.lowHeightLandscape,
          start: start,
          settings: [
            howToPlay,
            const SizedBox(height: AppSpacing.lg),
            ...switches,
          ],
        ),
    };

    return Scaffold(body: SafeArea(child: body));
  }
}

/// 버튼을 세로로 쌓은 메뉴 카드. 카드 모양은 테마의 `cardTheme`(radius md)를 쓴다.
class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.children,
    required this.padding,
    this.scrollable = false,
  });

  final List<Widget> children;
  final double padding;

  /// true면 카드 안에서 세로 스크롤한다 (저높이 가로, `design.md` §4).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: scrollable
          ? SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: content,
            )
          : Padding(padding: EdgeInsets.all(padding), child: content),
    );
  }
}

/// 높이가 모자라면 바깥이 세로 스크롤하고, 남으면 [child]를 가운데에 둔다.
class _CenteredScroll extends StatelessWidget {
  const _CenteredScroll({required this.margin, required this.child});

  final double margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.all(margin),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(0.0, constraints.maxHeight - 2 * margin),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// compact·medium: 가운데 카드 하나(최대 폭 440), 버튼 세로 배치, 높이가 모자라면 세로 스크롤.
class _SingleCardMenu extends StatelessWidget {
  const _SingleCardMenu({required this.margin, required this.children});

  final double margin;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _CenteredScroll(
      margin: margin,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: ScreenLayout.menuCardMaxWidth),
        child: _MenuCard(padding: AppSpacing.xl, children: children),
      ),
    );
  }
}

/// expanded·저높이 가로: 시작 버튼 카드 + 설정·How to Play 카드를 나란히 둔다.
/// 저높이 가로에서는 카드가 화면 높이를 채우고 카드마다 세로 스크롤한다.
class _TwoCardMenu extends StatelessWidget {
  const _TwoCardMenu({
    required this.scrollEachCard,
    required this.start,
    required this.settings,
  });

  final bool scrollEachCard;
  final List<Widget> start;
  final List<Widget> settings;

  @override
  Widget build(BuildContext context) {
    const maxWidth = 2 * ScreenLayout.menuCardMaxWidth + AppSpacing.lg;
    final padding = scrollEachCard ? AppSpacing.lg : AppSpacing.xl;

    final row = Row(
      crossAxisAlignment: scrollEachCard
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MenuCard(
            padding: padding,
            scrollable: scrollEachCard,
            children: start,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _MenuCard(
            padding: padding,
            scrollable: scrollEachCard,
            children: settings,
          ),
        ),
      ],
    );

    if (scrollEachCard) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: row,
          ),
        ),
      );
    }
    return _CenteredScroll(
      margin: AppSpacing.xl,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: row,
      ),
    );
  }
}
