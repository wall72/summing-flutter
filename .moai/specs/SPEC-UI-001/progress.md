# SPEC-UI-001 진행 기록

## §E.1 Plan-phase Audit-Ready Signal

- plan_complete_at: 2026-10-15T10:21:18+09:00
- plan_status: audit-ready
- tier: L
- depends_on: SPEC-ARCH-001 (must be completed before run-phase entry)
- artifacts: spec.md, plan.md, acceptance.md, design.md, research.md, spec-compact.md, interview.md, progress.md
- base_commit: 6a695b2
- baseline_verification: not-run (`flutter` not on PATH in the plan-phase shell) — run-phase first step must execute `flutter analyze && flutter test`
- plan_audit_iter1: FAIL 0.70 (`.moai/reports/plan-audit/SPEC-UI-001-review-1.md`) — revised to spec 0.2.0 (D1-D14 addressed), awaiting iteration 2
- ac16_discrimination_baseline: 4 lines at 6a695b2 (game_page.dart:106, board_grid.dart:25, board_grid.dart:27, main.dart:24)
- ac23_discrimination_baseline: 25 lines at 6a695b2
- plan_audit_iter2: FAIL 0.84 (`.moai/reports/plan-audit/SPEC-UI-001-review-2.md`) — revised to spec 0.3.0 (D15-D22 addressed; D19 resolved by user decision: low-height landscape two-pane rule REQ-UI-024 / AC-UI-25); REQ 24/25, AC 25/25; awaiting iteration 3 (final)
- ac16_discrimination_baseline_v030: 4 lines at 6a695b2 with both token folders (`theme/`, `layout/`) excluded
- plan_audit_iter3: FAIL 0.88 (`.moai/reports/plan-audit/SPEC-UI-001-review-3.md`, blocking D23 low-height panel width) — user approved a 4th audit scoped to D23/D24; revised to spec 0.3.1 (D23, D24 fixed; optional D25, D26, D27 folded into existing AC text, no new AC/REQ); REQ 24/25, AC 25/25
- plan_audit_iter4: FAIL 0.90 (`.moai/reports/plan-audit/SPEC-UI-001-review-4.md`, blocking D28 animation start-frame timing in AC-UI-15/20) — user decision: fix D28 + D29-D31, then orchestrator verifies by diff + lint, PASS-with-debt, no 5th audit; revised to spec 0.3.2; REQ 24/25, AC 25/25
- plan_audit_iter5: PASS 0.93 (`.moai/reports/plan-audit/SPEC-UI-001-review-5.md`, delta audit scoped to D28-D31 + regression, run-phase Plan Audit Gate) — D28-D31 resolved (D28 confirmed by a temporary Flutter probe); new optional defects D32 (reduced-motion InkWell splash must be disabled for AC-UI-14, pass to run-prompt Section B), D33 (design.md:L126 fused bullet), D34 (spec.md main.dart line refs are 6a695b2-based); the earlier note "no 5th audit" in the iter4 line and spec.md:L28 is historical and superseded by this entry
- audit_verdict: PASS
- audit_report: .moai/reports/plan-audit/SPEC-UI-001-review-5.md
- audit_at: 2026-10-16
- auditor_version: plan-auditor (opus, effort high), iteration 5
- low_height_panel_padding: 6 per side (cap 8); content width min 188 vs need 184; height need 244 vs 308
- low_height_panel_check: 480x320 / 531x320 panel width 200 vs need 184 (label on its own line), height 308 vs need 232; 568x320 236/308; 740x360 368/348
- landscape_board_design_values: 568x320 side 308 / cell 32.00 (guaranteed >= 304 / >= 31.5); 740x360 side 348 / cell 36.44 (guaranteed >= 344 / >= 36)

## §E.2 Run-phase Evidence

### Baseline (this run, HEAD 8090c04, before any run-phase change)

- command: `/home/wall72/flutter/bin/flutter analyze` → exit 0, `No issues found! (ran in 1.5s)` (full output: `.moai/state/verify/c31e2948/baseline-analyze.txt`)
- command: `/home/wall72/flutter/bin/flutter test` → exit 0, `00:03 +75: All tests passed!` (full output: `.moai/state/verify/c31e2948/baseline-test.txt`)
- flutter: absolute path used because `flutter` is not on PATH in this shell (Flutter 3.47.7 stable)
- depends_on SPEC-ARCH-001: `status: completed` (verified by plan-auditor iter5 and at session start); ARCH_SHA = HEAD 8090c04
- plan_audit_gate: PASS 0.93 (iter5), user kickoff approval granted 2026-10-16; progression mode: autonomous; branch: main direct (Route A)

### M1 — UX flow and layout skeleton (manager-develop, cycle_type=tdd)

- base_head: 8090c04 (worktree branch `worktree-agent-ac42244eb3f386b21`, same commit as main)
- flutter_version: Flutter 3.47.7 • channel stable
- preflight_baseline: `flutter analyze` → `No issues found!`; `flutter test` → exit 0, `+75: All tests passed!`
- depends_on: SPEC-ARCH-001 `status: completed` (ARCH_SHA for AC-UI-17/19 = 8090c04 tree)
- ac16_preflight: 4 lines; ac23_preflight: 25 lines (matches plan-phase discrimination baseline)
- red_evidence: `flutter test test/presentation/game test/presentation/layout` → `00:06 +5 -18: Some tests failed.` — breakpoints_test compile error (`Error when reading 'lib/presentation/layout/breakpoints.dart'`), AC-UI-08 `Found 0 widgets with type "AlertDialog"`, AC-UI-03/04/05/25 missing `game.board` / `game.sidePanel` keys, changed characterization test failing on missing dialog. The 5 passes were AC-UI-11 ×4 and Quit (pre-existing behavior, REQ-UI-012 [EXISTING])
- green_evidence: same command → `00:03 +39: All tests passed!`; `flutter analyze` → `No issues found!`
- full_suite: `flutter test --coverage` → exit 0, `+113: All tests passed!`
- coverage (LH/LF): breakpoints.dart 13/13 100%, game_page.dart 103/105 98.1%, board_grid.dart 39/40 97.5%, end_overlay.dart 20/21 95.2%, game_side_panel.dart 21/21 100%, next_queue_row.dart 34/34 100%, restart_confirm_dialog.dart 13/13 100%
- ac16_after_m1: 4 lines (game_page.dart:106 `Colors.black54` moved to end_overlay.dart:23; M2/M6 replaces with scrim token)
- ac23_after_m1: 18 lines (game_page.dart literals moved to layout/breakpoints.dart `GameLayout`; remaining: end_overlay ×5, next_queue_row radius ×1, menu/scores/how_to_play — M3/M6)
- ac17_invariant: `git diff --exit-code 8090c04 -- lib/domain lib/infrastructure/persistence/persistence_keys.dart lib/infrastructure/persistence/save_game_codec.dart lib/application pubspec.yaml` → exit 0

| AC | Status | Test |
|---|---|---|
| AC-UI-03 | PASS | game_page_test `AC-UI-03 compact 360x780` |
| AC-UI-04 | PASS | game_page_test `AC-UI-04 medium 700x1000` |
| AC-UI-05 | PASS | game_page_test `AC-UI-05 expanded 1280x800` |
| AC-UI-08 | PASS | restart_dialog_test `AC-UI-08` group (+ double-tap edge case, side-panel Restart) |
| AC-UI-09 | PASS | restart_dialog_test `AC-UI-09` group (Cancel, barrier, Escape, handlePopRoute) |
| AC-UI-10 | PASS | restart_dialog_test `AC-UI-10`, characterization test (intentionally changed) |
| AC-UI-11 | PASS | restart_dialog_test `AC-UI-11` group (complete/gameOver × Play again/Restart) |
| AC-UI-25 | PASS (layout part) | game_page_test `AC-UI-25` group (568x320 / 740x360 asserted board ≥ 304 / ≥ 344 and cell ≥ 31.5 / ≥ 36; breakpoints_test observes board side 308 / 348; cell ≈ side / 9 with the pre-M4 gapless grid, computed not measured; 1280x400). M3 re-verifies with AC-UI-06, M4 restyles cells (frame 2 + gap 2) and the design values become 32.00 / 36.44 |

- scope_cascades (attributable to AC-UI-25): `board_grid.dart` cell keys `cell.<i>` only; `next_queue_row.dart` slot keys `queue.slot.<i>`, `labelAbove` / `slotSize` parameters, slot gap without outer padding (M4 restyles the row)
- intentional_change: `game_page_characterization_test.dart` AC-ARCH-16 assertion replaced by the confirm-dialog flow (SPEC-ARCH-001 acceptance §D.2, SPEC-UI-001 acceptance §D.2)
- note_for_m2 (D32): reduced-motion (`MediaQuery.disableAnimations`) — Material InkWell splash on board cells can leave running animations; theme should set `splashFactory: NoSplash.splashFactory` (or equivalent) so AC-UI-14 `hasRunningAnimations == false` holds. M1 adds no dependency on it
- not_done_in_m1: `status: draft → in-progress` frontmatter transition on spec/plan/acceptance was not applied (orchestrator instruction: no SPEC artifact edits besides this section)

### M2 — Design tokens and theme (manager-develop, cycle_type=tdd; integrated to main as 1ea1228 from worktree commit b904772)

- spec.md status: draft → in-progress (applied in the M2 commit, frontmatter only)
- verification (orchestrator, main @ 1ea1228): `flutter analyze` → `No issues found!`; `flutter test` → `+240: All tests passed!` (M1 baseline +113)
- agent evidence files: `.moai/state/verify/c31e2948/m2_*.txt` (RED m2_red.txt/m2_red2.txt, final m2_test_final.txt)
- ACs: AC-UI-01 PASS, AC-UI-19 PASS, AC-UI-22 PASS, AC-UI-24 PASS, AC-UI-02 PARTIAL (GamePage screens only; menu/scores/sheet in M3; game screens re-check after M4 restyle)
- grep counts after M2: AC-UI-16 = 2 (board_grid.dart:25,:27 → M4), AC-UI-23 = 13 (menu 7, how_to_play 3, scores 2 → M3; next_queue_row.dart:91 radius → M4)
- D32 handled: splashFactory NoSplash under MediaQuery.disableAnimations (ReducedMotionTheme)
- fonts: Nunito 3.602 OFL 1.1 from fonts.gstatic.com (Regular 132,200 B, ExtraBold 132,068 B) + OFL.txt from googlefonts/nunito; Nunito has no `tnum` feature → tabular figures not applied (research.md §5 open item answered)
- design.md values not exactly reproducible: card/dialog shadow blur 12/y 4 approximated via shadowColor primary 12% + elevation 4 (ThemeData has no blur/offset)
- note: palette class named AppPalette (not AppColors) to avoid AC-UI-16 grep false positives
- main.dart coverage 64.3% (untouched `main()` entry; outside AC-UI-18 scope)

## §F Phase 4 Mode Selection

- Input params: tier L; milestones M1-M6 (6); files ≈ 30+ (lib/presentation + tests + assets + pubspec); domains: 1 (Flutter presentation layer, with theme/asset sub-areas); development_mode tdd; user flag: none (`--team`/`--solo` absent)
- Mode evaluation:

| Mode | Fit | Reason |
|------|-----|--------|
| serial | selected | Coding-heavy TDD; milestones depend on each other (M1 layout skeleton → M2 tokens → M3..M5 build on them); shared files (game_page.dart, board_grid.dart) across milestones |
| fanout | no | Applies to read-only investigation; research already done in plan phase |
| agent-team | no | Explicit-request experimental only; not requested |
| sweep | no | Not a high-volume mechanical transformation |

- manager-lead check: ≥3 milestones AND ≥10 files met, but not cross-domain (single presentation domain) → not used
- Decision: serial
- Justification: Tier L coding-heavy work defaults to sequential sub-agents; no concurrent write-capable agents; one manager-develop per milestone group with milestone commits on main by explicit pathspec.

## §E.3 Run-phase Audit-Ready Signal

_<pending run-phase>_

## §E.4 Sync-phase Audit-Ready Signal

_<pending sync-phase>_

- plan_complete_at: 2026-10-15T14:45:09+09:00
- plan_status: audit-ready (PASS-with-debt)
- plan_audit: FAIL 0.90 at iteration 4 (blocking D28, minor); user decided fix + orchestrator diff/lint verification, no 5th audit — .moai/reports/plan-audit/SPEC-UI-001-review-4.md
- verification_after_fix: moai spec lint clean; REQ=24 AC=25; D28 fixes confirmed by grep (start-frame pump() rule present); NOT re-audited independently
