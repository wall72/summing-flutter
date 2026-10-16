# SPEC-ARCH-001 진행 기록

## §E.1 Plan-phase Audit-Ready Signal

- plan_complete_at: 2026-10-15T10:21:18+09:00
- plan_status: audit-ready
- tier: M
- artifacts: spec.md, plan.md, acceptance.md, spec-compact.md, interview.md, progress.md
- base_commit: 6a695b2
- baseline_verification: not-run (`flutter` not on PATH in the plan-phase shell) — run-phase first step must execute `flutter analyze && flutter test`
- plan_audit_iter1: FAIL 0.72 (`.moai/reports/plan-audit/SPEC-ARCH-001-review-1.md`) — revised to spec 0.2.0 (D1-D12 addressed), awaiting iteration 2
- ac01_discrimination_baseline: `grep -rnE "import .*infrastructure/" lib/application lib/presentation` → 8 lines at 6a695b2 (plan-phase measurement)

## §E.2 Run-phase Evidence

- cycle_type: ddd (ANALYZE-PRESERVE-IMPROVE), Flutter 3.47.7 stable (`flutter --version`)
- 작업 위치: L1 worktree `.claude/worktrees/agent-aea9dbcb03413cb25` (브랜치 `worktree-agent-aea9dbcb03413cb25`, 기준 HEAD `8edb186`). push 없음
- 기준선(오케스트레이터 실측, 재실행 안 함): `flutter analyze` exit 0, `flutter test` exit 0 (29 tests)

### 오케스트레이터 사전 점검과 독립 재검증 (session 88ea0d23)

- 기준선 (HEAD `8edb186`): `flutter analyze` exit 0 "No issues found!", `flutter test` exit 0 "+29: All tests passed!", Flutter 3.47.7 / Dart 3.13.5 (`~/flutter/bin`, PATH 밖). 증거: `.moai/state/verify/88ea0d23/baseline-{version,analyze,test}.txt`
- plan-audit: PASS 0.91 (Tier M 기준 0.80), 감사 이후 plan 산출물 변경 없음 → 재감사 생략
- 독립 재검증 (worktree 브랜치 HEAD `0c60011`): AC-01 0줄 / AC-02 diff exit 0·porcelain 0 / AC-11 `11`·`0` / AC-14 `4`·app_overrides 1개·`overrides: appOverrides`·구현체 4개 / `flutter analyze` exit 0 / `flutter test --coverage` exit 0 `+75` / pubspec diff 0줄. 증거: `.moai/state/verify/88ea0d23/post-{analyze,test}.txt`
- 독립 재검증 Gap: AC-03~10·13·15·16 개별 명령 미실행(전체 테스트 통과로 갈음), 커버리지 수치는 보고 값
- 통합: `main`은 `8edb186`이었고 사용자 승인 후 `git merge --ff-only worktree-agent-aea9dbcb03413cb25`로 `0c60011`까지 fast-forward (push 안 함)

## §F Phase 4 Mode Selection

- Input: tier M, scope ~30 files, domains 1 (Flutter/Dart), file language mix 100% Dart, concurrency benefit LOW (coding-heavy)
- Mode evaluation: direct = not selected (non-trivial); serial = selected; fanout = not selected (coding-heavy); sweep = not selected (not uniform mechanical)
- Decision: serial
- Justification: 마일스톤 간 의존이 있는 동작 보존 리팩토링이라 순차 manager-develop 단일 spawn (coding-task parallelism caveat)
- Kickoff 선택: cycle_type=ddd, main에 커밋만(push 없음), 진행 방식=자율

### §E.2.1 AC 판정과 검증 기록

증거 기준: 아래 명령은 모두 이 실행에서 이 트리(lib는 `b1507cd`, test는 `b1507cd` + M5 테스트 2개 미커밋 상태)에 대해 실행한 결과입니다.

**E8 리팩토링 전 증거 (RED 대응)**

- AC-ARCH-01 판별력 (HEAD `8edb186`, 코드 변경 전): `grep -rnE "import .*infrastructure/" lib/application lib/presentation` → 8줄 (`game_session_notifier.dart:8,9`, `scores_page.dart:3`, `menu_page.dart:5,6,7,8`, `game_lifecycle_listener.dart:7`)
- M1 동작 고정 테스트 7개 파일을 리팩토링 전 코드(HEAD `8edb186`)에서 실행:
  `flutter test test/application/game_session_notifier_test.dart test/application/app_settings_json_test.dart test/infrastructure/save_compat_fixture_test.dart test/presentation/menu/menu_page_test.dart test/presentation/scores/scores_page_test.dart test/presentation/common/lifecycle_audio_test.dart test/presentation/game/game_page_characterization_test.dart` → exit 0, 마지막 줄 `00:02 +27: All tests passed!`
- AC-ARCH-08 순서 검사 판별력(변이 탐침): `SettingsController`의 `await settings.save(next)`를 `settings.save(next)`로 임시 변경 → `menu_page_test` `Music off saves first...` FAIL (`Actual: ['applySettingsAndSyncBgm', 'save(AppSettings(musicOn: false, soundOn: true))']`), `app_queries_test` 2건 FAIL. 원복 후 전체 통과

**E1 AC 매트릭스**

| AC | 상태 | 검증 | 실제 출력 |
|---|---|---|---|
| AC-ARCH-01 | PASS | `grep -rnE "import .*infrastructure/" lib/application lib/presentation` + `test/architecture/layer_boundary_test.dart` | 0줄 (grep exit 1), layer_boundary_test 3개 통과 |
| AC-ARCH-02 | PASS | `git diff --exit-code 6a695b2 -- lib/domain test/domain lib/infrastructure/persistence/persistence_keys.dart lib/infrastructure/persistence/save_game_codec.dart` / `git status --porcelain -- lib/domain test/domain` | exit 0, 출력 없음 / 0줄 |
| AC-ARCH-03 | PASS | `test/infrastructure/save_compat_fixture_test.dart` (리팩토링 전 코덱 출력 fixture를 `GameSaveRepository`로 load) | turnCount 17, 81칸, 큐 `[3,1,4,1]` 일치, 2개 통과 |
| AC-ARCH-04 | PASS | `game_session_notifier_test.dart` AC-ARCH-04 그룹 | `['playTap','save']`, `['playMatch','save']` |
| AC-ARCH-05 | PASS | 같은 파일 AC-ARCH-05 | `recordCompletedGame(6)` 1회, `clear` 1회, `save` 0회 |
| AC-ARCH-06 | PASS | 같은 파일 AC-ARCH-06 | `clear` 1회, 기록·save 0회 |
| AC-ARCH-07 | PASS | 같은 파일 AC-ARCH-07 (a) Completer, (b) error | 두 경우 `completes`, turnCount 5→6, `save` 1회 |
| AC-ARCH-08 | PASS | `test/presentation/menu/menu_page_test.dart` settings 그룹 | Music: `[save(AppSettings(musicOn: false, soundOn: true)), applySettingsAndSyncBgm]`, Sound: `[save(AppSettings(musicOn: true, soundOn: false))]` |
| AC-ARCH-09 | PASS | 같은 파일 resume 그룹 | `Resume Game (3 turns)` 활성, `Resume Game` 비활성, New Game→Quit 후 `Resume Game (0 turns)` 활성 |
| AC-ARCH-10 | PASS | `test/presentation/scores/scores_page_test.dart` | `12 turns`가 `15 turns` 위, 빈 목록 안내 표시 |
| AC-ARCH-11 | PASS | `git ls-tree -r --name-only 6a695b2 -- test \| wc -l` / `git diff 6a695b2 --diff-filter=M -- test/ \| grep -cE "^[-+].*expect\("` / `flutter test` | `11` / `0` / 기존 11개 파일 포함 전체 통과 |
| AC-ARCH-12 | PASS | `flutter analyze` 후 `flutter test --coverage` | `No issues found! (ran in 0.6s)` exit 0 / `00:06 +75: All tests passed!` exit 0 |
| AC-ARCH-13 | PASS | `test/application/app_settings_json_test.dart` | 키 집합 `{musicOn, soundOn}`, `{}` → 둘 다 true, 설정 포트 load = `AppSettings(musicOn: false, soundOn: true)` |
| AC-ARCH-14 | PASS | acceptance.md AC-ARCH-14 grep 4개 | (1) `4` (2) `lib/infrastructure/app_overrides.dart` (3) `15:      overrides: appOverrides,` (4) `game_audio_service.dart`, `settings_store.dart`, `high_scores_store.dart`, `game_save_store.dart` |
| AC-ARCH-15 | PASS | `test/presentation/common/lifecycle_audio_test.dart` | inactive 후 suspend 없음, paused→resumed 후 `['suspend','resume']` |
| AC-ARCH-16 | PASS | `test/presentation/game/game_page_characterization_test.dart` | AlertDialog 0개, turnCount 0, `0 turns` 표시, save 1회(새 상태 turnCount 0) |

**E3 커버리지** — `flutter test --coverage` 후 `coverage/lcov.info`의 LH/LF

| 파일 | LH/LF | 비율 |
|---|---|---|
| `lib/application/game_session_notifier.dart` | 37/37 | 100.0% |
| `lib/application/app_queries.dart` | 24/24 | 100.0% |
| `lib/application/port_providers.dart` | 9/9 | 100.0% |
| `lib/application/models/app_settings.dart` | 18/18 | 100.0% |
| `lib/application/ports.dart`, `lib/application/application.dart` | 실행 줄 없음 (lcov 미기재) | — |
| 참고: `lib/infrastructure/app_overrides.dart` / `menu_page.dart` / `scores_page.dart` / `game_lifecycle_listener.dart` / `main.dart` | 10/10, 47/59, 17/18, 22/22, 8/18 | 100.0%, 79.7%, 94.4%, 100.0%, 44.4% |

**E5 정적 분석** — `flutter analyze` → `No issues found!`, exit 0 (기준선 0건 대비 신규 0건)

**E6 커밋** (push 안 함): M1 `9a4f75a`, M2 `84930d1`, M3 `a3f7ef3`, M4 `b1507cd`, M5 이 기록을 담은 커밋(§E.3 참조)

**DoD 보조**: `git diff 6a695b2 -- pubspec.yaml | wc -l` → `0` (새 패키지 없음)

**미검증(Gap)**
- 실제 기기·웹에서의 오디오 재생, 첫 제스처 BGM 해제(`main.dart` web 분기)는 수동 실행으로 확인하지 않았습니다. `main.dart` 커버리지 44.4%가 이 분기입니다.
- 메뉴의 저장소 로딩 실패 화면(`Load error:`)과 점수판 오류 화면은 테스트로 고정하지 않았습니다.

**잔여 위험**
- pre-commit 훅(`moai gate`)이 linked worktree에서 실행될 때 git이 넘기는 `GIT_DIR` 때문에 Flutter SDK가 자기 버전을 `0.0.0-unknown`으로 읽어 실패했습니다. `build/hookshim/`(gitignore)에 해당 변수를 지운 뒤 `$HOME/flutter/bin/flutter`를 실행하는 shim을 PATH 앞에 두고 커밋했으며, 훅 자체는 우회하지 않았습니다.
- `highScoresProvider`는 autoDispose라 점수판을 열 때마다 다시 읽지만, `resumableGameProvider`는 메뉴가 게임 화면에서 돌아올 때만 invalidate 합니다(리팩토링 전 메뉴의 `setState` 재조회와 같은 시점).

## §E.3 Run-phase Audit-Ready Signal

```yaml
run_complete_at: 2026-10-16T08:36:03+09:00
run_commit_sha: 0c60011  # M5 커밋 SHA 후속 backfill (placeholder 완료, SPEC 본문 아님)
run_status: audit-ready
ac_pass_count: 16
ac_fail_count: 0
preserve_list_post_run_count: 0  # AC-ARCH-02 diff 출력 0줄
l44_pre_commit_fetch: not-run  # 커밋만, push 없음 (오케스트레이터 지시)
l44_post_push_fetch: not-applicable
new_warnings_or_lints_introduced: 0
cross_platform_build:
  flutter_analyze: pass
  flutter_test: pass (75 tests)
  device_builds: not-run
total_run_phase_files: 30  # git diff --stat 6a695b2 b1507cd -- lib test (M5 테스트 2개 별도)
m1_to_mN_commit_strategy: one-commit-per-milestone (M1-M5), no push
```

## §E.4 Sync-phase Audit-Ready Signal

```yaml
sync_complete_at: 2026-10-16
sync_commit_sha: pending-backfill  # 커밋은 자기 SHA를 알 수 없음; 후속 backfill
sync_status: audit-ready
docs_updated:
  - README.md
  - .moai/project/structure.md
  - .moai/project/product.md
  - .moai/project/codemaps/{overview,modules,dependencies,entry-points,data-flow}.md
  - .moai/specs/SPEC-ARCH-001/spec.md  # frontmatter status: in-progress -> completed 만
  - .moai/specs/SPEC-ARCH-001/progress.md  # §E.4
frontmatter_status_transitions:
  spec_md: in-progress -> completed
verification_evidence:
  head: 2880710
  flutter_analyze: "exit 0, 'No issues found!' (.moai/state/verify/dcd15635/sync-analyze.txt)"
  flutter_test: "exit 0, '+75: All tests passed!' (.moai/state/verify/dcd15635/sync-test.txt)"
  lib_coverage: "479/635 = 75.4% (목표 85% 미달; main.dart 44.4%, menu_page.dart 79.7%)"
  pubspec_diff_vs_6a695b2: 0 lines
gaps:
  - 기기·웹에서 실제 오디오 재생 확인 안 함
  - MX P1/P2 스캐너 미실행
  - 보안 스캔(Phase 8) 생략 — 인증·네트워크 파일 변경 없음, 영속 저장소는 포트 구현만 변경했고 오케스트레이터가 개별 diff 검토하지 않음
  - lib 커버리지 75.4% < 85% 목표
  - plan.md 등 SPEC 본문은 수정하지 않음 (plan에 없는 변경 파일은 본 문서에 반영하지 않음)
residual_risk:
  - 커버리지 미달 구간(main.dart, menu_page.dart)의 회귀는 테스트로 잡히지 않을 수 있음
  - 포트 provider를 override에서 빠뜨리면 런타임에 UnimplementedError (appOverrides 테스트로만 방어)
```

- plan_complete_at: 2026-10-15T14:45:09+09:00
- plan_status: audit-ready
- plan_audit: PASS (0.91, iteration 2) — .moai/reports/plan-audit/SPEC-ARCH-001-review-2.md
