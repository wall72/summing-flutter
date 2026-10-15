---
name: table-cell-pipe-escape
description: Shell/grep commands inside markdown AC tables use \| escapes that silently break when copied raw; execute them against the current tree
type: project
metadata:
  type: project
---

SPECs in this project put verification commands inside acceptance.md table cells, escaping `|` as `\|`. Copied raw, a grep -E alternation `(a\|b)` becomes a literal pipe (SPEC-ARCH-001 AC-ARCH-01 returned 0 lines on a tree with 8 violations, GNU grep 3.11), and a shell pipe `\| grep` becomes a pathspec argument.

Recurred in SPEC-UI-001 AC-UI-16 (2026-10-15) with `grep -P` — in PCRE `\|` is also a literal pipe. Note: this shell's `grep` is ugrep.

**Why:** run-phase agents read the raw markdown, so an AC can pass vacuously before any work is done; spec-compact.md may carry the unescaped form, creating SSOT drift.
**How to apply:** for every boundary/grep AC, run the raw command against the pre-change tree and confirm it fails there; flag any `\|` inside a command in a table cell as blocking.
