# SPEC Review Report: SPEC-UI-001
Iteration: 4/3 (user-approved extra pass beyond the cap; scope: D23/D24 + D25-D27 regression + D1-D22 regression)
Verdict: FAIL
Overall Score: 0.90 (Tier L threshold 0.85; iter1 0.70 → iter2 0.84 → iter3 0.88 → iter4 0.90, no regression, no STOP)

Reasoning context ignored per M1 Context Isolation. Inputs read (Tier L, 5 artifacts): spec.md (0.3.1), plan.md, acceptance.md, design.md, research.md, plus spec-compact.md for parity. Code cross-checked on HEAD 6a695b2 (`lib/presentation/game/widgets/next_queue_row.dart`, `board_grid.dart`, `game_page.dart`).
Cross-model: not re-run (iter1 `audit_multi` returned `inconclusive` for both backends; environment unchanged).

D23 and D24 are resolved, D25-D27 are resolved without regressions, and D1-D22 show no regressions. The FAIL rests on one new blocking defect, D28. It sits in AC-UI-15 text that earlier iterations accepted: as literally written, the test samples the frame where the queue animation starts (t = 0), so a correct implementation fails the strict `x < x₀ + pitch` check. The fix is one phrase.

## Must-Pass Results
- [PASS] MP-1 REQ number consistency: 24 entries REQ-UI-001..024 in order (spec.md:L62-L97), no gaps or duplicates, 3-digit padding. spec-compact.md REQ lines are identical (diff empty).
- [PASS] MP-2 GEARS (requirement layer, spec.md §C only; ACs graded under Group 4): ubiquitous (L62, L64, L72, L93, L95, L96), ubiquitous + `shall not` (L63, L65, L86, L89), `While` (L69-L71, L73, L79, L97), compound `While … when` (L77), `When` (L78, L83-L85, L87), `Where` (L88, L94). REQ text has not changed since 0.3.0.
- [PASS] MP-3 frontmatter: 12 canonical fields at spec.md:L2-L13; `version: "0.3.1"` quoted (L4); `created`/`updated` 2026-10-15; `priority: P1`; `phase: "v1.1.0 target"`; `lifecycle: spec-anchored`; `tags` comma string; no rejected aliases. Optional fields: `tier: L`, `depends_on: [SPEC-ARCH-001]`.
- [N/A] MP-4: single-language (Flutter/Dart) SPEC.
- [PASS] MP-5 D7: the only external reference is SPEC-ARCH-001, which exists with `status: draft` (not retired/superseded/archived). Run-gate note unchanged: depends_on stays unfulfilled until ARCH-001 is `completed` (spec.md:L55, plan.md:L24).
- [PASS] MP-6 D8: `syscall` count is 0 in all 8 files of the SPEC directory.
- [PASS] MP-7: `grep -rn '\[NEEDS CLARIFICATION' plan.md research.md` → no match (exit 1).

## Category Scores
| Dimension | Score | Rubric Band | Evidence |
|-----------|-------|-------------|----------|
| Clarity | 0.90 | 0.75-1.0 | Queue curve is now unambiguous ("배치 팝: easeOutBack, 큐 이동: easeOutCubic", design.md:L169). Low-height label placement is stated (design.md:L125, L156). Remaining: the inline-overflow range is worded "480~531" (D29), and the panel's inner padding is unspecified (D30) |
| Completeness | 0.92 | 0.75-1.0 | All sections and 4 `### Out of Scope —` H3s (spec.md:L127-L147). The queue-head outline now has a token (design.md:L25). Both axes are budgeted for the low-height panel (design.md:L124-L132) |
| Testability | 0.85 | 0.75-1.0 | AC-UI-16 gives 4 lines and AC-UI-23 gives 25 on 6a695b2 (re-run). AC-UI-25 now checks the title and label stacking (acceptance.md:L153). AC-UI-15's pump sequence samples t = 0 (D28); AC-UI-20's "이동 후" carries the same ambiguity |
| Traceability | 0.95 | 0.75-1.0 | Every REQ has ≥1 AC (acceptance.md:L159-L183). The clauses iter3 left unchecked now have checks: REQ-UI-008 at 480×320 (L49), the REQ-UI-024 title (L153), and the REQ-UI-003 state layers (L29) |

Aggregate (harmonic mean): 4 / (1/0.90 + 1/0.92 + 1/0.85 + 1/0.95) = 0.90.

## Defects Found (structured defect-list)
D28. AC15-FRAME-START — acceptance.md:L85 (and L123) — AC-UI-15 prescribes "빈 칸을 탭하고 `tester.pump(const Duration(milliseconds: 100))`" and expects `x₀ < x < x₀ + pitch`. `tester.tap` does not pump a frame. The placement notifies the provider synchronously (`board_grid.dart:54`, `game_page.dart:71`), so the rebuild that starts the queue's implicit animation happens inside that one `pump(100ms)` frame. A controller started during a frame takes that frame's timestamp as its start time (`Ticker.start` sets `_startTime = currentFrameTimeStamp` when the phase is between idle and postFrameCallbacks) and paints its begin value. The slot therefore renders at x₀ + pitch exactly, the strict upper bound fails, and only a later pump reaches t = 0.5. No standard implicit or explicit animation passes the check as written. The usual Flutter test idiom is `tap → pump() → pump(Δ)`. AC-UI-20 (L123) says "이동 후 `tester.pump(160ms)`". If "이동" is read as the tap alone, the route's first tick is also at elapsed 0 (opacity 0, not 0.875), and the same applies to the end overlay at 150 ms. This is not a regression from 0.3.1: the text predates it, and iter3 marked D16 resolved without catching the frame semantics. — Severity: minor — Class: blocking (the stated criterion fails for a correct implementation) — Required fix: in AC-UI-15 write "빈 칸을 탭하고 `tester.pump()`로 연출을 시작한 뒤 `tester.pump(const Duration(milliseconds: 100))`"; in AC-UI-20 write "이동(탭 후 `tester.pump()` 한 번으로 전환 시작) 후 `tester.pump(160ms)`" and the same for the overlay clause. Mirror both edits into spec-compact.md between the AC-BODY markers. The expected values (0.125 × pitch, 0.875, 0.995) do not change.
D29. INLINE-RANGE-WORDING — design.md:L78, L125; spec.md:L27 — These lines say the inline label overflows "폭 480~531". Recomputed at height 320: the panel is exactly 200 for widths 480-532 (design.md:L124 and acceptance.md:L193 say 480~532, correct), and the panel stays below 230 up to width 561 (561 → 229, 562 → 230). The inline label therefore overflows across 480-561, not 480-531. The text only explains a rejected layout, and the chosen stacked layout fits at every width (184 ≤ 200). — Severity: minor — Class: optional — Fix: "폭 480~561에서 넘침" (or drop the range).
D30. PANEL-PADDING-UNSPECIFIED — design.md:L124-L125, L155 — The horizontal budget leaves 16 px of slack (200 − 184) at widths 480-532, and no inner padding is given for the side panel. Any panel padding above 8 px per side overflows. AC-UI-06 at 480×320 (acceptance.md:L49) would catch this in the run phase, so the gap is detectable, not silent. — Severity: minor — Class: optional — Fix: state "저높이 가로 사이드 패널 좌우 안쪽 여백 ≤ 8 (토큰 8)" in design.md §4 or §5.
D31. PLAN-XREF-STALE — plan.md:L136 — §H lists only review-1 and review-2. spec.md:L155 and plan.md:L3 cite review-3. — Severity: minor — Class: optional — Fix: add `SPEC-UI-001-review-3.md` (and review-4).

## Regression Check (Iteration 4)
In-scope defects from iteration 3:
- D23 LOW-HEIGHT-PANEL-WIDTH — RESOLVED. design.md:L125 puts `Next:` on its own line above the four slots, with required width 4 × 40 + 3 × 8 = 184 and required height 28+8+24+8+20+4+40+12+40+8+40 = 232. Recomputed (`python3 -I`): 480×320 board 256 / panel 200 × 308; 531×320 307 / 200 × 308; 532×320 308 / 200 × 308; 568×320 308 / 236 × 308; 740×360 348 / 368 × 348; 1280×400 388 / 868 × 388. All satisfy 184 wide and 232 high, and they match design.md:L127-L132 and research.md:L146-L153. AC-UI-06 now includes 480×320 (acceptance.md:L49). AC-UI-25 asserts that the `Next:` label's bottom y ≤ `queue.slot.0` top y (L153). That check discriminates at 568×320, where the inline layout would also fit (236 ≥ 230). The queue spec is consistent (design.md:L156; plan.md:L84, L112).
- D24 QUEUE-CURVE — RESOLVED. design.md:L169 reads "배치 팝: easeOutBack, 큐 이동: easeOutCubic", with the rationale that easeOutBack(0.5) = 1.0676 overshoots. Also stated in plan.md:L84 and research.md:L155. Recomputed easeOutCubic(0.5) = 0.875, so x = x₀ + 0.125 × pitch at t = 0.5. The pitch "칸 폭 + 8" matches the current code (44 + 2 × 4 padding = 52, next_queue_row.dart:24-27). The frame-start issue in the same AC is the separate defect D28.

Optional defects from iteration 3 (edits checked for regressions):
- D25 QUEUE-HEAD-OUTLINE-TOKEN — RESOLVED, no regression. `queueHeadOutline` is `#9C3358` / `#F4B6C2` (design.md:L25). Recomputed 6.59 / 10.15 against background, 6.94 / 9.10 against surfaceContainer, and 5.33 / 5.30 against queueHeadContainer; all match research.md:L84-L86 and are above 3.0. The token is added to the AC-UI-01 non-text list (acceptance.md:L28), and the old value is recorded in design.md:L77 and research.md:L117.
- D26 STATE-LAYER-UNVERIFIED — RESOLVED, no regression. AC-UI-01 row L29 adds the 10% pressed pairs. Recomputed TextButton 5.64 / 5.94 (L) and 8.20 / 7.26 (D), FilledButton 7.44 / 7.35, tonal 9.48 / 5.86; all match research.md:L94-L97. Residual, not a defect: the SnackBar action and ListTile pressed states are not in the table. I computed them at 6.51 / 5.29 and 10.97 / 11.74, all ≥ 4.5.
- D27 AC25-TITLE — RESOLVED. AC-UI-25 checks `find.descendant(of: game.sidePanel, matching: find.text('Summing'))` (acceptance.md:L153). The title's size in the low-height panel, 20/800, is defined in design.md:L97 and fits the 28 px title row in the vertical budget.

Defects D1-D22 — no regressions:
- D1 / D8 / D17: re-ran on HEAD 6a695b2. The AC-UI-16 command gives 4 lines and the AC-UI-23 command gives 25, matching acceptance.md:L95 and L145. Both still exclude `theme/` + `layout/` (spec.md:L101).
- D7: `grep kIsWeb` gives `lib/main.dart:40`.
- D2 / D19 / D20 / D22: compact and medium values recompute unchanged (360 → 348 / 36.44, 599×640 → 380 / 40.00, 320×568 → 308 / 32.00, 700×1000 → 560 / 60.00). REQ-UI-024 still guarantees ≥ 304 / ≥ 31.5 at 568×320 and ≥ 344 / ≥ 36 at 740×360.
- D3 / D4 / D13 / D15: contrast tokens are unchanged from 0.3.0.
- D18: AC-UI-20 values are unchanged (320 ms, 0.875 ± 0.01, 0.995 ± 0.001). The pump-sequence ambiguity is part of D28.
- D9-D12, D14, D16, D21: text unchanged.
- spec-compact.md: the AC body between the markers is byte-identical to acceptance.md (diff empty), and the REQ lines are identical. Counts: REQ 24 ≤ 25, AC 25 ≤ 25. Plan milestones M1-M6 still map all 25 ACs.

Escalation history:
- iter1 (0.70): D1-D14 — resolved by iter2.
- iter2 (0.84): D15-D22 — resolved by iter3.
- iter3 (0.88): D23 (blocking), D24-D27 (optional) — all resolved by iter4.
- iter4 (0.90): D28 (blocking, minor), D29-D31 (optional).
- Stagnation: none. No defect has recurred across iterations. The one-axis layout-arithmetic class (D2 → D19 → D23) is closed: both axes are now checked across the full 480-1280 low-height range. D28 is a new class: AC timing written without Flutter test frame semantics.

## Recommendation
FAIL, held by one blocking defect (D28). The must-pass firewall passes, and the aggregate (0.90) is above the Tier L threshold of 0.85 and improves on iter3. This pass is already beyond the 3-iteration cap, so the orchestrator should escalate to the user rather than iterate automatically. Suggested framing:
1. Apply the D28 fix (acceptance.md:L85: insert `tester.pump()` before `pump(100ms)`; acceptance.md:L123: the same start-pump wording for the route and overlay clauses; mirror into spec-compact.md). Then accept as PASS-with-debt, or authorize a delta check limited to those two sentences. The check is mechanical: the expected values do not change.
2. PASS-with-debt without the edit: record D28 as residual risk. The run-phase engineer will hit a deterministic RED on AC-UI-15 with a correct implementation and will have to add `pump()`, which departs from the AC text.
3. D29-D31 are optional. D30 (panel inner padding ≤ 8) is the most worthwhile. It is a single clause and prevents an AC-UI-06 failure at 480×320.
