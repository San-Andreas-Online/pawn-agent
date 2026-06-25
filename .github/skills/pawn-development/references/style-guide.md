# Pawn Style and Refactoring Guide

## General Principle

Pawn style varies a lot from one project to another (a legacy of different SA-MP communities). **Consistency with the existing code takes priority over these conventions**: if a project already has an established style, follow it rather than imposing this guide. These conventions mostly apply to new code or projects without a clear convention.

## Naming

| Element | Common convention | Example |
| --- | --- | --- |
| Integer variable | `i` prefix | `iScore`, `iPlayerCount` |
| Float variable | `f` prefix | `fHealth` |
| String | `s` prefix (string, can be explicitly marked as zero-terminated with `s` if needed) | `sMessage[128]` |
| Array | no prefix, except if all contents share the same type | `playerScores[MAX_PLAYERS]` |
| Boolean | `b` prefix | `bIsAdmin` |
| Enum constant | shared UPPERCASE prefix | `E_PD_SCORE`, `E_PD_LEVEL` |
| `#define` constant | UPPERCASE_WITH_UNDERSCORES | `MAX_HOUSES` |
| Public/stock function | PascalCase | `GivePlayerMoneyEx`, `IsValidHouse` |

These prefixes (Hungarian notation) are a community convention, not a language rule—some modern projects avoid them in favor of simple descriptive names (`playerHealth` rather than `fHealth`). Ask for or observe the project convention before enforcing one.

## Code Organization

- **One `.inc` per functional domain** (e.g., `houses.inc`, `factions.inc`, `economy.inc`) rather than a single monolithic gamemode file with thousands of lines—this makes reviews and future refactors easier.
- **Systematic include guards** on every `.inc` (see `references/language-reference.md`).
- **Separate declarations from business logic**: put global `#define`/`enum`/`new` declarations at the top of the file, then callbacks, then utility (`stock`) functions.
- **Avoid “god functions”** with hundreds of lines handling an entire callback (e.g., all of `OnPlayerCommandText` in one huge `if/else if` chain)—extract each complex command into its own named function, called from the command dispatcher.

## Common Refactoring Patterns

### Function Extraction

A repeated logic block across multiple callbacks (e.g., bonus calculation, ID validation) should become a dedicated `stock` function, tested once instead of duplicated.

### Replacing Magic Literals

```pawn
// Before
if (GetPlayerScore(playerid) > 1000) { ... }

// After
#define VIP_SCORE_THRESHOLD 1000
if (GetPlayerScore(playerid) > VIP_SCORE_THRESHOLD) { ... }
```

### Replacing Manual Loops with `foreach`

When a loop is present, use macros to use foreach if available (`#if defined foreach`). Replacing `for (new i = 0; i < MAX_PLAYERS; i++) { if (!IsPlayerConnected(i)) continue; ... }` with `foreach (new i : Player) { ... }` reduces boundary-related mistakes and clarifies intent. Do not introduce a foreach dependency in a project that does not already use it just for this style gain.

### Consolidating Enums by Entity

Grouping data spread across multiple parallel arrays (`new iScore[MAX_PLAYERS]; new iLevel[MAX_PLAYERS];`) into a single structured enum (`enum E_PLAYER_DATA { E_PD_SCORE, E_PD_LEVEL }`) reduces desynchronization errors between arrays and makes it easier to add new fields.

## Refactoring Precautions

- **Never rename a `public` function without checking external dependencies** (other files, plugins calling by name via `CallLocalFunction`/`CallRemoteFunction`).
- **Preserve observable behavior**: a refactor must not change the execution order of logic that depends on side effects (e.g., a message sent before vs. after a check).
- **Recompile after each step** rather than at the end of a long series of changes, to quickly isolate the cause of a regression.
- **Comment the “why,” not the “what”**: a useful comment explains a non-obvious decision (e.g., “delay this check by 100ms because the client updates its position asynchronously”), not a restatement of the code (`// increments i`).
