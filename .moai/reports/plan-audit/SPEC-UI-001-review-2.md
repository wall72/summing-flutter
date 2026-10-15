# SPEC Review Report: SPEC-UI-001
Iteration: 2/3
Verdict: FAIL
Overall Score: 0.84 (Tier L threshold 0.85; iter1 0.70 → iter2 0.84, no regression, no STOP)

Reasoning context ignored per M1 Context Isolation. Inputs read (Tier L, 5 artifacts): spec.md, plan.md, acceptance.md, design.md, research.md (+ spec-compact.md for parity). Scope: delta re-audit over iter1 D1-D14 plus regression check, plus new findings surfaced while verifying the fixes.
Cross-model: not re-run (iter1 `audit_multi` returned `inconclusive` for both backends — codex binary and GLM key absent; environment unchanged). Claude verdict stands.

## Must-Pass Results
- [PASS] MP-1 REQ number consistency: REQ-UI-001..023 sequential in document order (spec.md:L59-L93), REQ-UI-023 moved to the end (L93), no gaps/duplicates, 3-digit padding.
- [PASS] MP-2 GEARS (REQ layer, spec.md §C only; ACs graded under Group 4): ubiquitous (L59, L61, L69, L86, L90, L92, L93), ubiquitous+`shall not` (L60, L62, L83), `While` (L66-L68, L70, L76), compound `While…when` (L74), `When` (L75, L80-L82, L84), `Where` (L85, L91). REQ-UI-011 (L75) and REQ-UI-014 (L81) chain two `When` clauses — legal compound.
- [PASS] MP-3 frontmatter: 12 canonical fields at spec.md:L2-L13, `version: "0.2.0"` quoted, `phase: "v1.1.0 target"`, `tags` comma string, no rejected aliases; optional `tier: L`, `depends_on: [SPEC-ARCH-001]`.
- [N/A] MP-4: single-language (Flutter/Dart) SPEC.
- [PASS] MP-5 D7: only cross-ref SPEC-ARCH-001 exists, `status: draft` (not retired/superseded/archived). Run-gate note unchanged: depends_on unfulfilled until ARCH-001 is `completed` (now correctly stated at spec.md:L52, plan.md:L23).
- [PASS] MP-6 D8: `syscall` count 0 in all six artifacts.
- [PASS] MP-7: `grep -rn '\[NEEDS CLARIFICATION' plan.md research.md` → no match (exit 1).

## Category Scores
| Dimension | Score | Rubric Band | Evidence |
|-----------|-------|-------------|----------|
| Clarity | 0.85 | 0.75-1.0 | iter1 ambiguities fixed (AC-UI-09 four paths L55, AC-UI-18 per-file L101, design.md §2 padding single values L46-L49). Remaining: "design-token source" never defined vs two exempt dirs (D17); AC-UI-03/04 heights unstated (D22) |
| Completeness | 0.80 | 0.75 band | All sections + 4 `### Out of Scope —` H3s (spec.md:L121-L140). Token table still lacks the roles Material uses for `FilledButton.tonal` and `CircleAvatar`, both present in in-scope files (D15) |
| Testability | 0.85 | 0.75-1.0 | All shell commands fenced and unescaped; AC-UI-16 (4 lines) and AC-UI-23 (25 lines) discrimination claims reproduce exactly on 6a695b2. AC-UI-15 queue check not attributable (D16); AC-UI-20 discrimination vs platform default transition unverified (D18) |
| Traceability | 0.85 | 0.75-1.0 | Every REQ has ≥1 AC (acceptance.md:L149-L172); REQ-UI-001/002/017/020/021 now directly verified (AC-23/24/20/21/22). REQ-UI-015 only nominally covered (D16) |

Aggregate (harmonic mean): 0.84.

## Defects Found (structured defect-list)
D15. TONAL-AVATAR-ROLES — design.md:L5-L24, L100; lib/presentation/menu/menu_page.dart:109; lib/presentation/scores/scores_page.dart:39; acceptance.md:L27 — Same defect class as iter1 D3, on other in-scope screens. design.md §5 names a "tonal" button and MenuPage uses `FilledButton.tonal` today (Material default: `secondaryContainer` / `onSecondaryContainer`); ScoresPage uses `CircleAvatar` (default `primaryContainer` / `onPrimaryContainer`). None of these four roles is in the §1 token table, research.md §3 has no measurement, and AC-UI-02 runs `textContrastGuideline` on GamePage only. Both files are in §E MODIFY. Result: the rank digits and the tonal button label get colors from Material derivation, not the token source (REQ-UI-001, spec.md:L59), with no contrast check against the Goal "숫자와 문구의 대비는 WCAG AA" (spec.md:L35). — Severity: major — Class: blocking — Required fix: in design.md §1 either map tonal and avatar to existing roles (e.g. tonal = queueHeadContainer + onQueueHead, 11.39 / 7.50; avatar = same pair) or add the four roles with values; add the measured pairs to research.md §3 and AC-UI-01's pair list; extend AC-UI-02 to MenuPage and ScoresPage (with ≥1 score row) in both themes. Optionally state the Switch track (Material default `primary`, `#F6B7C4` vs background 1.60) as accepted or tokenized.
D16. REQ015-NOT-ATTRIBUTABLE — acceptance.md:L79, L174 — AC-UI-15's only queue check is `tester.hasRunningAnimations` true, which the placement animation alone satisfies; nothing ties it to the queue row. acceptance.md:L174 claims every REQ is directly verified. — Severity: minor — Class: blocking — Required fix: add a check scoped to `NextQueueRow`, e.g. a keyed shift animation (`queue.shift`) present at t = base/2 and absent after `pumpAndSettle()`, or the head slot's offset strictly between start and end at t = 100 ms.
D17. TOKEN-SOURCE-UNDEFINED — spec.md:L59, L62; acceptance.md:L136; plan.md:L39 — REQ-UI-001/004 say "one design-token source"; AC-UI-23 exempts `lib/presentation/theme/` and `lib/presentation/layout/`, AC-UI-16 only `theme/`. The AC is explicit, so engineers will converge. — Severity: minor — Class: optional — Fix: define "design-token source" in spec.md §D as `lib/presentation/theme/` + `lib/presentation/layout/`.
D18. AC20-DISCRIMINATION — acceptance.md:L117 — The "opacity strictly in (0,1), scale strictly in (0.96,1.0)" window at t = 160 ms has not been shown to fail on the platform-default `MaterialPageRoute` transition (flutter not on PATH; unverified either way). — Severity: minor — Class: optional — Fix: assert the token curve value (easeOutCubic(0.5) = 0.875 → opacity 0.875 ± 0.01, scale 0.995 ± 0.001) or assert the route type, and add AC-UI-20 to plan.md §C step 3's pre-change discrimination run.
D19. LANDSCAPE-BOARD-SIZE — design.md:L78-L80, L87; acceptance.md:L43, L181; spec.md:L69 — With a 260 px compact vertical region, 568×320 yields board min(552, 60) = 60 px and cells (60 − 16)/9 = 4.9 px; a medium landscape phone such as 740×360 yields a ≤ 100 px board in the single-column layout. REQ-UI-008 only requires no overflow, so no stated criterion fails, but the board is unplayable at sizes the SPEC names. — Severity: major — Class: optional — Fix (orchestrator should surface as a user decision): either add a rule (e.g. two-pane or header-beside-board layout when height < 480) or record landscape phone as accepted-unplayable in §G.
D20. FRAME-RADIUS — design.md:L44, L47 — Board frame radius lg 24 with inner padding 0: the radius either clips the corner cells (36 px cells, radius 6) or is invisible. — Severity: minor — Class: optional — Fix: drop the frame radius, or give the frame inner padding ≥ the radius difference and recompute §4.
D21. AC14-COVERAGE — acceptance.md:L75; spec.md:L85 — REQ-UI-018 says every animation; AC-UI-14 exercises placement, navigation, overlay, not a match flash. — Severity: minor — Class: optional — Fix: add a matching placement to AC-UI-14's When list.
D22. AC03-04-HEIGHT — acceptance.md:L31, L35 — Viewport height not stated for AC-UI-03 (360) and AC-UI-04 (700), while §D preamble says physicalSize sets both. — Severity: minor — Class: optional — Fix: 360×780 and 700×1000 (or any explicit height).

## Regression Check (Iteration 2)
- D1 AC16-PIPE-ESCAPE — RESOLVED: command fenced and unescaped (acceptance.md:L85-L87); spec-compact.md AC section (L35-L169) is byte-identical to acceptance.md (diff empty); executed on 6a695b2 → exactly the 4 claimed lines (main.dart:24, board_grid.dart:25, :27, game_page.dart:106).
- D2 CELL-SIZE-ARITH — RESOLVED: compact padding 8, frame padding 0, gap counted (design.md:L46-L48, L79, L84-L89); (360 − 16 − 16)/9 = 36.44 and (380 − 16)/9 = 40.44 recomputed; AC-UI-07 states gap exclusion (L47).
- D3 TEXTBUTTON-CONTRAST — RESOLVED for GamePage/dialog: accentText role (design.md:L13), theme override in plan.md:L66, L120; recomputed 6.59 / 6.94 / 10.15 / 9.10. Same class recurs on Menu/Scores → D15.
- D4 DARK-EMPTY-CELL-INVISIBLE — RESOLVED: cellOutline on all cells (design.md:L17, L99); recomputed outline vs frame 3.54 / 5.35; judgment criterion explicit (L29).
- D5 REQ017-UNCOVERED — RESOLVED: AC-UI-20 (L117), strength caveat D18.
- D6 REQ020-UNCOVERED — RESOLVED: AC-UI-21 (L121); labels and button flag match board_grid.dart:87-88 (`'${cell.value}'` / `'Empty cell'`, `button: onTap != null`).
- D7 REQ021-MISTRACE — RESOLVED: AC-UI-19 no longer claims REQ-UI-021; AC-UI-22 (L125) with injected switch; `grep kIsWeb` returns main.dart:40 today.
- D8 REQ001-002-PARTIAL — RESOLVED: AC-UI-23 (25 lines on 6a695b2, reproduced) and AC-UI-24 (`ThemeMode.system`, exactly 2 `SwitchListTile`s matching menu_page.dart:140, :148).
- D9 MATCH-CLASSIFICATION — RESOLVED: design.md:L117-L124, REQ-UI-014 (spec.md:L81), AC-UI-12 third case (L67); verified against summing_rules.dart (match ⇒ `afterMatchClear`, no digit recorded, turnCount + 1) and board.dart `afterMatchClear`.
- D10 AC12-NO-WHEN — RESOLVED (L67). D11 DEPENDS-STATUS — RESOLVED (plan.md:L23). D12 REQ-ORDER — RESOLVED (spec.md:L93). D13 FOCUS-PAIR — RESOLVED (research.md:L66-L68, AC-UI-01 L22; recomputed 4.17 / 9.81 / 6.94 / 5.44). D14 AC09-EACH — RESOLVED (L55).

Verified non-defects: all research.md §3 values recomputed with the WCAG formula and match; extra adjacent pairs measured (focus vs placeHighlight 5.56 / 4.64, vs matchFlash 5.53 / 4.60 — pass). REQ text in spec-compact.md identical to spec.md. Plan milestones M1-M6 map all 24 ACs. REQ 23 ≤ 25, AC 24 ≤ 25.

## Recommendation
FAIL. Must-pass firewall passes; the verdict is driven by blocking D15 (major) and D16 (minor) and an aggregate of 0.84 below the Tier L 0.85 threshold. Both fixes are small. For manager-spec, iteration 3 (final):
1. D15 — define (or map) the tonal-button and CircleAvatar color roles in design.md §1, measure them in research.md §3, add them to AC-UI-01, and extend AC-UI-02 to MenuPage and ScoresPage.
2. D16 — give REQ-UI-015 a queue-row-scoped check in AC-UI-15.
3. D19 — the orchestrator should ask the user whether landscape phones need a playable layout; record the answer as a rule or an exclusion.
4. Optional D17, D18, D20-D22 at manager-spec's discretion.
Iteration 3 will be scoped to D15-D22 plus a regression check of D1-D14.
