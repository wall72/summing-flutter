---
name: flutter-ac-frame-timing
description: Flutter widget-test ACs that tap/navigate then pump(Δ) sample animation t=0; check for a start pump() before timed pumps
type: project
---

When auditing Flutter SPEC ACs that assert mid-animation values, check the pump sequence: `tester.tap` does not pump, so the first `pump(Δ)` is the build frame where the implicit/route animation starts (Ticker start time = current frame) and paints its begin value. A strict mid-value check after `tap → pump(Δ)` fails for any correct implementation; the correct idiom is `tap → pump() → pump(Δ)`.

**Why:** Found in SPEC-UI-001 iter4 (AC-UI-15 queue slide, AC-UI-20 route fade). Three prior iterations accepted the wording because they verified curve math only, not frame semantics.
**How to apply:** For every animation AC in this project, verify (1) curve value at the sampled fraction and (2) that a frame starting the animation precedes the timed pump. Also recurring class in this SPEC: layout budgets checked on one axis only — always recompute width AND height across the whole breakpoint range.

Probe-verified (iter5, Flutter 3.47.7, scratch package with `flutter pub get --offline` works): tap→pump(100ms) paints begin value; tap→pump()→pump(100ms) paints t=0.5. Reduced-motion ACs asserting `tester.hasRunningAnimations == false` after a tap FAIL with the default M3 InkWell splash (InkSparkle) even when all token durations are 0; `NoSplash.splashFactory` makes it false. Check that the design names the splash handling whenever such an AC taps an InkWell.
