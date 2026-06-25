---
name: pawn-development
description: "Develop, debug, refactor, and extend Pawn scripts for open.mp game servers (retrocompatible with SA-MP/SA:MP). Use this skill whenever the user mentions Pawn, .pwn files, .inc files, open.mp, omp, SA-MP, gamemodes, filterscripts, pawncc, or asks to add a feature, fix a bug, refactor, or write new code in a Pawn codebase. Also trigger on indirect signals even if 'Pawn' isn't said explicitly, such as callbacks like OnPlayerConnect/OnGameModeInit, native function calls, dialogs, timers, sscanf, y_hooks, streamer plugin, foreach, or references to compiling .amx files -- these are strong open.mp/Pawn signals. Make sure to consult this skill before writing or editing any .pwn/.inc/.p file."
---

# Pawn Development (open.mp / SA-MP)

## Project Context

This skill targets Pawn development for **open.mp** (the modern, open-source successor to SA-MP), which remains **backward compatible** with the classic SA-MP API (`a_samp.inc`). Unless the user specifies otherwise, assume that:

- `open.mp` natives (prefixed or not, e.g. `GetPlayerVersion`, `Player_GetVersionName`) are available in addition to legacy SA-MP natives.
- Common includes: `<a_samp>`, `<a_mysql>` or `<a_mysql>`/`MySQL` plugin (R41-4 or later), `<streamer>`, `<sscanf2>` or `<sscanf>`, `<YSI_*>` (y_hooks, y_iterate/foreach, y_timers), `<a_npc>`.
- Source files have the `.pwn` extension (gamemodes/filterscripts) or `.inc` (libraries/includes).
- The compiler is `pawncc` (often bundled with open.mp in `qawno/` or `pawno/`), targeting an `.amx` file.

If the user's project deviates from these assumptions (pure SA-MP without open.mp, MTA:SA, or generic non-game Pawn), adapt to what they describe and point out relevant differences rather than imposing open.mp conventions.

## Before Any Action

1. **Explore the actual project.** Never assume the structure: use `view`/`bash` to list files (`gamemodes/`, `filterscripts/`, `includes/` or `pawno/include`, `qawno/include`), locate `server.cfg`/`config.json` (open.mp uses `config.json`), and identify third-party plugins present.
2. **Identify existing conventions** (indentation, function prefixes, variable naming style — see `references/style-guide.md`) and follow them rather than imposing a different style on already consistent code.
3. **Identify dependencies**: if the code uses `y_hooks`, `sscanf`, `streamer`, MySQL, etc., consult `references/openmp-api.md` for their specific idioms before modifying code that uses them.

## Workflow by Task Type

### Adding a Feature
1. Locate the relevant callback(s) or function(s) (`OnPlayerCommandText`, `OnDialogResponse`, `OnPlayerConnect`, etc.). If multiple scripts hook the same callback (often via `y_hooks` or `#if defined` (ALS method)), verify that an existing hook is not being overwritten — see `references/common-bugs.md#overwritten-hooks`.
2. Declare necessary variables respecting scope (global vs file-level `static` vs local) and realistic array sizes for `MAX_PLAYERS`.
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

## Compilation and Verification

After a modification, **always try to compile** when possible rather than relying solely on manual review — Pawn has syntactic pitfalls (tags, operators) that a manual review easily misses.

Use `scripts/compile_check.sh` to locate `pawncc` in the project and compile a file:

```bash
bash /mnt/skills/.../pawn-development/scripts/compile_check.sh path/to/file.pwn
```

If you can find a compiling configuration in `tasks.json` or such, use that  or its information instead. If the user has a custom build script, ask them to run it and provide the output.

If `pawncc` cannot be found in the environment (no binary available on this system), clearly state this to the user instead of pretending to have verified compilation — instead, propose a targeted manual review of the points in `references/common-bugs.md`.

See `references/compiling.md` for interpreting common `pawncc` errors/warnings.

## Reference Files

- `references/language-reference.md` — Pawn syntax (tags, enumerations, arrays, strings, operators, control flow, native/public/stock functions). Consult for any syntax doubt.
- `references/openmp-api.md` — open.mp/SA-MP specifics: main callbacks, common natives, idioms (foreach, y_hooks, sscanf, dialogs, timers, streamer), differences between open.mp and legacy SA-MP.
- `references/common-bugs.md` — Catalog of the most frequent Pawn bugs and how to identify/fix them.
- `references/style-guide.md` — Style conventions and refactoring patterns for readable and maintainable Pawn code.
- `references/compiling.md` — Using `pawncc`, reading error/warning messages, debug levels.

Load these files on demand based on the task (no need to read all of them for a small bug fix, for example — `common-bugs.md` alone is often sufficient).
