---
name: recompute-design-numbers
description: Flutter UI SPECs here carry design arithmetic and contrast pairs that omit gaps, adjacent surfaces, and Material default role mappings
type: project
metadata:
  type: project
---

SPEC-UI-001 iter1: the cell-size calc ignored the 2px cell gap (35.56 < 36 bound), contrast was measured against the page background rather than the adjacent surface, and no token covered TextButton foreground (Material default = colorScheme.primary; pastel pink gave 1.68:1). The dark empty cell measured 1.08:1 against the board frame.
iter2: the TextButton fix was applied only to the screens the REQs named; MenuPage `FilledButton.tonal` (secondaryContainer) and ScoresPage `CircleAvatar` (primaryContainer) still had no token role. Landscape 568x320 gave a 60px board because the fixed vertical region was sized for portrait.

iter3: the landscape fix checked the side panel's vertical budget only; at 480x320 the panel min width (200) cannot hold the inline "Next:" label + 4 queue slots (~230). Also a shared "easeOutBack / easeOutCubic" motion row left the queue curve open; Flutter easeOutBack(0.5)=1.0676 overshoots and breaks strict-bound ACs.

**Why:** research.md values reproduced exactly, but each one answered the wrong question, so the SPEC looked verified when it was not. Fixes tend to be local to the screen the auditor cited.
**How to apply:** recompute layout bounds with every spacing token included, at every named viewport including landscape; grep every in-scope file for Material widgets (tonal, CircleAvatar, Switch, OutlinedButton) and check which colorScheme role each uses by default; measure interactive surfaces against their neighbours, not only against the background. For every new layout region, check BOTH axes against its content at the smallest viewport the design names; when an AC asserts a mid-animation value, confirm which curve applies and compute it.
