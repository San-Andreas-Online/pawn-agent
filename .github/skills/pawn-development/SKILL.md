---
name: pawn-development
description: "Develop, debug, refactor, and extend Pawn scripts for open.mp/SA-MP game servers. Triggered by mentions of Pawn, .pwn files, .inc files, open.mp, omp, SA-MP, gamemodes, filterscripts, pawncc, or requests to add features, fix bugs, refactor, or write Pawn code. Also covers indirect signals: callbacks (OnPlayerConnect, OnGameModeInit), native calls, dialogs, timers, sscanf, y_hooks, streamer, foreach, or .amx compilation. Consult this skill before editing any .pwn/.inc/.p files."
---

# Pawn Development Skill — open.mp / SA-MP

**Scope:** Reusable knowledge base for Pawn development across any project.

## Assumptions & Context

This skill assumes **open.mp** (modern, open-source SA-MP successor) or **SA-MP** unless told otherwise. open.mp is backward compatible with SA-MP's API (`a_samp.inc`).

**Default environment:**
- **Natives:** open.mp natives (with/without prefix like `GetPlayerVersion`, `NetStats_GetConnectedTime`) + SA-MP legacy natives
- **Common includes:** `<foreach>`, `<streamer>`, `<sscanf2>`/`<sscanf>`, `<YSI_*>` (y_hooks, y_iterate/foreach, y_timers), `<colandreas>`
- **Source files:** `.pwn` (gamemodes, filterscripts) or `.inc` (libraries)
- **Compiler:** `pawncc` (bundled in `qawno/` or `pawno/`), outputs `.amx`

**If the project differs** (pure SA-MP, MTA:SA, or generic Pawn), adapt to their specifics and flag differences.

## Starting a Task

Before making any changes:

1. **Explore the actual project structure.** Never assume — locate:
   - Source directories: `gamemodes/`, `filterscripts/`, `includes/` (or `pawno/include`, `qawno/include`)
   - Configuration: `server.cfg`, `config.json` (open.mp), `server.ini`
   - Build system: `tasks.json`, custom scripts, or compiler location
   - Dependencies: `YSI`, `sscanf`, `streamer`, MySQL, etc.

2. **Identify existing conventions** (indentation style, naming patterns, layout) by scanning existing code.
   - Consult `CONTRIBUTING.md` or equivalent documentation in the project.
   - Follow those conventions rather than imposing a new style.
   - See `references/style-guide.md` for Pawn best practices where the project lacks its own.

3. **Identify dependencies** used in the code (y_hooks, sscanf, streamer, MySQL, etc.).
   - Consult `references/openmp-api.md` for their patterns and idioms before editing.
   - Never refactor without understanding how a dependency is used.

## Workflow by Task Type

### Adding a Feature
1. Locate the relevant callback(s) or function(s) (`OnPlayerCommandText`, `OnDialogResponse`, `OnPlayerConnect`, etc.). If multiple scripts hook the same callback (often via `y_hooks` or `#if defined` (ALS method)), verify that an existing hook is not being overwritten — see `references/common-bugs.md#overwritten-hooks`.
2. Declare necessary variables respecting scope (global vs file-level `static` vs local) and realistic array sizes.
3. Write the logic following `references/language-reference.md` for correct syntax (tags, enumerations, strings).
4. If the feature requires a new dialog, timer, or command, follow the patterns in `references/openmp-api.md`.
5. Compile to verify (see the Compilation section below) before considering the task complete.

### Fixing a Bug
1. Ask about or identify the **observed vs expected behavior** and, if available, the compiler error/warning message or crash log (`crashdetect` plugin, `server_log.txt`).
2. Systematically check the classic pitfall list in `references/common-bugs.md` (array overflows, string buffers too small, uninitialized variables, `==`/`=` confusion, callbacks with wrong return values, etc.) — the vast majority of Pawn bugs fall into these categories.
3. Fix by changing the minimum necessary; do not refactor at the same time as fixing a bug unless explicitly requested.
4. Recompile and verify that the warning/error is gone without introducing new ones.

### Refactoring
1. Never change observable behavior without explicitly informing the user.
2. Prefer incremental refactoring (extracting a function, renaming, factoring out a repeated pattern) over a complete rewrite, unless explicitly requested.
3. Follow `references/style-guide.md` for naming conventions and organization (splitting into `.inc` files, include guards, etc.).
4. Pay special attention to refactoring that touches `forward`/`public`: if a `public` function name is renamed, verify that no other script or plugin depends on it (plugin natives sometimes call publics by name, e.g. some `streamer` or `MySQL` hooks via named callback).
5. Recompile after each significant change rather than at the end of a long series of modifications.

### Writing New Pawn Code
1. Start with the structure (includes at the top, defines/constants, forward declarations, global variables, then functions/callbacks).
2. Always use include guards in new `.inc` files (`#if defined _mylib_included` ... `#endif`).
3. Initialize all fixed-size arrays and check bounds (`MAX_PLAYERS`, string sizes — see `references/common-bugs.md`).
4. Document public functions with a brief comment above them (parameters, return value).

## Compilation & Verification

After any modification, **always attempt to compile**. Pawn has syntactic pitfalls (tags, operators) that a single approach easily misses. Use both compilation (when available) and manual review.

**Steps:**

1. **Attempt compilation (if compiler is available):**
   - Locate `pawncc` or `pawncc.exe` in the project (usually `compiler/`, `pawno/`, `qawno/`, or system `PATH`).
   - Check for VS Code tasks in `.vscode/tasks.json` — use those if available.
   - Or run `pawncc` directly with appropriate flags (`-i` for include paths, `-d2` for debug info, `-O1` for optimization, etc.).
   - Example (if a compile script exists):
     ```bash
     bash .github/skills/pawn-development/scripts/compile_check.sh path/to/file.pwn
     ```

2. **Interpret compiler output (if compilation ran):**
   - Success (exit code 0, no errors): Note this in the report.
   - Warnings: Review them — many are actionable (e.g., tag mismatches, unused variables).
   - Errors: Fix the issue before proceeding.
   - See `references/compiling.md` for details on common error messages.

3. **Report results clearly:**
   - State what changed and why.
   - Report compilation outcome (success/failure/unavailable).
   - List any issues found in manual review.
   - State any remaining risks or follow-ups.

## Reference Materials

**If available in the project,** consult these files from `.github/skills/pawn-development/references/`:

- **`language-reference.md`** — Pawn syntax (tags, enumerations, arrays, strings, operators, control flow, functions). Use for syntax doubts.
- **`openmp-api.md`** — open.mp/SA-MP specifics: callbacks, common natives, idioms (foreach, y_hooks, sscanf, dialogs, timers, streamer), SA-MP vs open.mp differences.
- **`common-bugs.md`** — Catalog of the most frequent Pawn bugs and how to identify/fix them (array overflows, buffer sizing, uninitialized variables, tag mismatches, callback return values, etc.).
- **`style-guide.md`** — Style conventions and refactoring patterns for readable, maintainable Pawn code.
- **`compiling.md`** — Using `pawncc`, reading error/warning messages, debug levels, flags.

**If these files are not available in the project,** you can still apply the knowledge from this skill:
- Use open.mp official documentation and SA-MP wiki for API reference.
- The workflows and common-bugs guidance above are language-agnostic and apply to any Pawn project.
