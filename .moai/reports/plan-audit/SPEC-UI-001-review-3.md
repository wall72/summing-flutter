# SPEC Review Report: SPEC-UI-001
Iteration: 3/3 (final — escalation report)
Verdict: FAIL
Overall Score: 0.88 (Tier L threshold 0.85; iter1 0.70 → iter2 0.84 → iter3 0.88, no regression, no STOP)

Reasoning context ignored per M1 Context Isolation. Inputs read (Tier L, 5 artifacts): spec.md, plan.md, acceptance.md, design.md, research.md (+ spec-compact.md for parity, interview.md, progress.md). Scope: delta re-audit over iter2 D15-D22, regression check of D1-D14, and the content added in 0.3.0 (REQ-UI-024, AC-UI-25, spec.md §D token-source definition, §1.1 ColorScheme mapping).
Cross-model: not re-run (iter1 `audit_multi` returned `inconclusive` for both backends; environment unchanged). Claude verdict stands.

The aggregate score clears the threshold and every must-pass criterion passes. The FAIL rests on one blocking defect (D23, minor): the design's own numbers make the queue row overflow the low-height side panel at 480×320, a viewport the SPEC names as "no overflow required", and no AC checks that viewport.

## Must-Pass Results
- [PASS] MP-1 REQ number consistency: REQ-UI-001..024 sequential in document order (spec.md:L61-L96), REQ-UI-024 appended at the end (L96), no gaps or duplicates, 3-digit padding. Counted 24 entries; spec-compact.md REQ lines identical (diff empty).
- [PASS] MP-2 GEARS (requirement layer, spec.md §C only; ACs graded under Group 4): ubiquitous (L61, L63, L71, L92, L94, L95), ubiquitous + `shall not` (L62, L64, L85, L88), `While` (L68-L70, L72, L78, L96), compound `While … when` (L76), `When` (L77, L82-L84, L86), `Where` (L87, L93). New REQ-UI-024 (L96) is `While [height < 480 and width ≥ 480], the game page shall …`.
- [PASS] MP-3 frontmatter: 12 canonical fields at spec.md:L2-L13, `version: "0.3.0"` quoted, `created`/`updated` 2026-10-15, `priority: P1`, `phase: "v1.1.0 target"`, `lifecycle: spec-anchored`, `tags` comma string, no rejected aliases; optional `tier: L`, `depends_on: [SPEC-ARCH-001]`.
- [N/A] MP-4: single-language (Flutter/Dart) SPEC.
- [PASS] MP-5 D7: only cross-ref SPEC-ARCH-001 exists, `status: draft` (not retired/superseded/archived). Run-gate note unchanged: depends_on is unfulfilled until ARCH-001 is `completed` (spec.md:L54, plan.md:L24).
- [PASS] MP-6 D8: `syscall` count 0 in all eight files of the SPEC directory.
- [PASS] MP-7: `grep -rn '\[NEEDS CLARIFICATION' plan.md research.md` → no match (exit 1).

## Category Scores
| Dimension | Score | Rubric Band | Evidence |
|-----------|-------|-------------|----------|
| Clarity | 0.88 | 0.75-1.0 | "design-token source" now defined (spec.md:L100); padding/radius single values (design.md:L80-L85). Remaining: queue-shift curve (design.md:L157, D24) and queue-label placement in the low-height panel (design.md:L111, L144, D23) |
| Completeness | 0.88 | 0.75-1.0 | All sections and 4 `### Out of Scope —` H3s (spec.md:L126-L146). Every Material role the in-scope widgets read is mapped (design.md:L34-L47; grep of lib/presentation found no widget outside the research.md:L29 list). Gaps: no horizontal budget for the low-height panel (D23); queue-head outline has no token (D25) |
| Testability | 0.88 | 0.75-1.0 | AC-UI-16 (4 lines) and AC-UI-23 (25 lines) reproduce on 6a695b2; AC-UI-15/20 now assert values tied to the queue row and the token curve. AC-UI-15's strict lower bound depends on an unstated curve (D24) |
| Traceability | 0.90 | 0.75-1.0 | Every REQ has ≥1 AC (acceptance.md:L157-L181); AC-UI-25 → REQ-UI-024. Clauses with no AC: REQ-UI-008 at 480×320 (D23), REQ-UI-024 "title" (D27), REQ-UI-003 "every enabled visual state" (D26) |

Aggregate (harmonic mean): 0.88.

## Defects Found (structured defect-list)
D23. LOW-HEIGHT-PANEL-WIDTH — design.md:L111, L120, L132, L144; spec.md:L71; acceptance.md:L47 — The low-height side panel's minimum width is 200 ("폭 200 이상", L111), and at 480×320 the panel gets exactly that: board = min(320 − 12, 480 − 224) = 256, panel = 480 − 24 − 256 = 200. Same for every width from 480 to 531 at height 320. The vertical budget at L120 ("큐 칸 40", about 212 total) counts the queue as one 40 px line, so the "Next:" label (kept, L144) sits beside the slots, as it does today (next_queue_row.dart:13-20, a Row with `Next:` + SizedBox 12 + 4 slots). That row is 4 × 40 + 3 × 8 = 184 for the slots plus the label (about 34 at 14 px) plus a gap, so 218-230 px. It does not fit in 200. design.md:L132 lists 480×320 as "넘침 없음만" (no overflow required), and REQ-UI-008 (spec.md:L71) requires no overflow at every landscape phone size, but AC-UI-06's viewport list (acceptance.md:L47) leaves 480×320 out, so the run phase will not catch it. At 568×320 (AC-UI-25) the panel is 236, about 6 px of slack with no panel padding. Same defect class as iter1 D2 and iter2 D19: layout arithmetic checked on one axis only. — Severity: minor — Class: blocking — Required fix: in design.md §5 (L144), state that in the low-height panel the "Next:" label sits on its own line above the slots (184 ≤ 200; the vertical budget grows to about 232, still ≤ 308), or raise the panel minimum to ≥ 232 and recompute the 480×320 row at L132. Add 480×320 to AC-UI-06's viewport list (no AC count change).
D24. QUEUE-CURVE — design.md:L157; acceptance.md:L83 — The base motion row lists "easeOutBack (팝) / easeOutCubic" for both the placement pop and the queue shift, without saying which curve the queue uses. Flutter's `Curves.easeOutBack` (Cubic 0.175, 0.885, 0.32, 1.275) gives 1.0676 at t = 0.5, so a correct easeOutBack queue slide is past x₀ at 100 ms and fails AC-UI-15's strict `x > x₀`. easeOutCubic gives 0.875 (x = x₀ + 0.125 × pitch, passes). Most engineers would read "(팝)" as binding easeOutBack to the pop. — Severity: minor — Class: optional — Fix: write "큐 이동: easeOutCubic" in the base row.
D25. QUEUE-HEAD-OUTLINE-TOKEN — design.md:L144, L63 — The queue head has a "굵은 외곽선" (thick outline) with no token. The current code draws it with `scheme.primary` (next_queue_row.dart:36), which after §1.1 is `#F6B7C4`, 1.60 against background, below the "상태 표시 3:1" criterion at L63. Head fill against background is 1.24 (light). Position already marks the head, so this is not a WCAG failure by itself. — Severity: minor — Class: optional — Fix: name the outline token (e.g. accentText, 6.59 / 10.15 vs background) and add it to AC-UI-01's non-text list.
D26. STATE-LAYER-UNVERIFIED — spec.md:L63; acceptance.md:L13-L31 — REQ-UI-003 says "every enabled visual state", but AC-UI-01/02 measure only token pairs and the default rendered state. I computed the 10% pressed state layers: TextButton 5.64 / 5.94 (light, on background / surface), 8.20 / 7.26 (dark); FilledButton 7.44 / 7.35; tonal 9.48 / 5.86. All pass 4.5, so the requirement holds. Only the verification is missing. — Severity: minor — Class: optional — Fix: add the pressed pairs to AC-UI-01's table, or narrow the REQ wording to the states the ACs measure.
D27. AC25-TITLE — spec.md:L96; acceptance.md:L151 — REQ-UI-024 puts the title in the low-height panel; AC-UI-25 checks turn count, queue, Restart, Quit but not the title. — Severity: minor — Class: optional — Fix: add `find.text('Summing')` inside `game.sidePanel` to AC-UI-25.

## Regression Check (Iteration 3)
Defects from iteration 2:
- D15 TONAL-AVATAR-ROLES — RESOLVED: tonal → secondaryContainer / onSecondaryContainer and CircleAvatar → primaryContainer / onPrimaryContainer, both mapped to queueHeadContainer / onQueueHead (design.md:L37-L38, L23-L24); Switch, SnackBar, progress indicator, sheet handle, surfaceTint covered (L41-L57); measured in research.md:L65-L83; added to AC-UI-01 (acceptance.md:L20-L27); AC-UI-02 now covers MenuPage (Resume enabled, SnackBar, sheet) and ScoresPage with ≥1 row (L31). Recomputed: 11.39 / 7.50, 12.36 / 12.36, 8.17 / 6.15, 6.94 / 8.69, 4.15 / 10.20, 3.36 / 5.96 — all match. A grep of lib/presentation for Material widgets and direct `colorScheme.*` reads found nothing outside the mapped set.
- D16 REQ015-NOT-ATTRIBUTABLE — RESOLVED: AC-UI-15 (acceptance.md:L83) checks `queue.slot.0` inside `NextQueueRow` strictly between x₀ and x₀ + pitch at 100 ms and back at x₀ after settle. Without animation x = x₀, so the check discriminates. Curve caveat → D24.
- D17 TOKEN-SOURCE-UNDEFINED — RESOLVED: spec.md:L100 defines the source as `theme/` + `layout/`; AC-UI-16/23 both exclude both folders (acceptance.md:L90, L140); plan.md:L40.
- D18 AC20-DISCRIMINATION — RESOLVED: asserts `transitionDuration` 320 ms (MaterialPageRoute default 300 fails), opacity 0.875 ± 0.01, scale 0.995 ± 0.001 (acceptance.md:L121; recomputed easeOutCubic(0.5) = 0.8751); RED run added to plan.md:L25 and DoD acceptance.md:L220.
- D19 LANDSCAPE-BOARD-SIZE — RESOLVED by user decision (interview.md:L28-L32): REQ-UI-024 + AC-UI-25. Recomputed 568×320 → 308 / 32.00, 740×360 → 348 / 36.44, 812×375 → 363 / 38.11, 1280×400 → 388; guarantees ≥ 304 / ≥ 31.5 and ≥ 344 / ≥ 36 hold. The horizontal budget in the same area is the new D23.
- D20 FRAME-RADIUS — RESOLVED: frame padding 2, clip radius 8 = cell radius 6 + 2 (design.md:L80, L83-L84); cell formula (side − 20) / 9 used everywhere (L118, acceptance.md:L51).
- D21 AC14-COVERAGE — RESOLVED: match case added (acceptance.md:L79).
- D22 AC03-04-HEIGHT — RESOLVED: 360×780 and 700×1000 (acceptance.md:L35, L39).

Defects from iteration 1 (D1-D14) — no regressions: D1 commands still fenced and unescaped, AC-UI-16 run on 6a695b2 gives exactly 4 lines (board_grid.dart:25, :27, main.dart:24, game_page.dart:106); D8 AC-UI-23 gives 25 lines; D7 `grep kIsWeb` gives main.dart:40; D2 recomputed with the 0.3.0 values (360 → 36.44, 599×640 → 40.00); D3/D4/D13 contrast values recomputed and match; D9-D12, D14 text unchanged and correct. spec-compact.md AC body matches acceptance.md between the markers (only the marker comment lines differ, which point at each other). REQ 24 ≤ 25, AC 25 ≤ 25. Plan milestones M1-M6 map all 25 ACs.

Escalation history (full defect record across iterations):
- iter1 (0.70): D1-D14 — all resolved by iter2.
- iter2 (0.84): D15-D22 — all resolved by iter3.
- iter3 (0.88): D23 (blocking, minor), D24-D27 (optional).
- Stagnation: none. No defect appeared in all three iterations. The one recurring class is layout arithmetic checked on one axis only (iter1 D2 cell gap, iter2 D19 landscape height, iter3 D23 panel width). Each fix was correct for the case cited, and the next gap sat on the other axis.

## Recommendation
FAIL at the 3-iteration cap. The must-pass firewall passes and the aggregate (0.88) is above the Tier L 0.85 threshold. The verdict is held by one blocking defect, D23. Per the Retry Loop Contract, the orchestrator escalates to the user. Suggested framing for that question:
1. Apply the D23 fix (one sentence in design.md §5 L144 putting the low-height "Next:" label above the slots, plus 480×320 in AC-UI-06's viewport list). Then either accept as PASS-with-debt, or have the user explicitly authorize an iter4 scoped only to D23. That delta check is mechanical: 184 ≤ 200 horizontally, about 232 ≤ 308 vertically.
2. PASS-with-debt without the edit: record D23 as residual risk for the run phase. AC-UI-25 at 568×320 will likely expose it if the panel has any horizontal padding; nothing will catch it at 480×320.
3. D24-D27 are optional. D24 (one word: easeOutCubic for the queue) is cheap and protects AC-UI-15 from a false failure. It is the most worthwhile of the four.
