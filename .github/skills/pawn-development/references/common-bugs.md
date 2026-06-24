# Catalogue of Common Pawn Bugs

This file lists the most frequent causes of bugs in Pawn/open.mp, to be checked systematically during a debugging session. Pawn often compiles faulty code without errors (at best a warning) — manual verification of these points is therefore essential.

## Buffer Overflows and Array Sizes

- **String buffer too small**: `new szName[16];` then `GetPlayerName(playerid, szName, 24);` → silent memory overflow that corrupts adjacent variables. Always size name buffers to at least `MAX_PLAYER_NAME` and use `sizeof()` at the call site rather than a hardcoded number.
- **Out-of-bounds index on `playerid`/`vehicleid`**: an array sized `new iData[MAX_PLAYERS]` indexed with a vehicle ID (or vice versa) causes silent corruption rather than an immediate crash — verify consistency between the sizing constant (`MAX_PLAYERS`, `MAX_VEHICLES`) and the ID being used.
- **`for` loop with wrong bound**: `for (new i = 0; i <= MAX_PLAYERS; i++)` (using `<=` instead of `<`) reads/writes an out-of-bounds index.

## Uninitialized Variables

- An unassigned `new` variable defaults to `0`, but a **per-player enumeration array entry** reused after disconnection (`PlayerData[playerid][...]`) may contain the previous player's values if not reset in `OnPlayerConnect` — a classic trap for fields like money, score, or progression state.
- Systematically verify that `OnPlayerConnect` resets (or reloads from the database) all relevant data rather than assuming a clean default state.

## Operator Confusion

- `=` instead of `==` in a condition (`if (iState = 1)`) — assigns instead of comparing; the compiler does not always warn depending on the context.
- Comparing `Float:` with `==` on a calculated value (floats have precision issues) — prefer a tolerance-based comparison (`floatabs(a - b) < 0.01`) if the value comes from a calculation rather than a constant.
- Unexpected integer division: `new percentage = iScore / iMax * 100;` truncates before the multiplication if `iScore` and `iMax` are integers — reorder (`iScore * 100 / iMax`) or cast to `Float:`.

## Tag Mismatch (Warning Often Wrongly Ignored)

- `warning 213: tag mismatch` is **not trivial**: it very often indicates a forgotten `Float:` on a variable, a parameter, or an enumeration field. Every warning of this type in the compilation output must be examined, not dismissed out of habit.

## Callbacks and Hooks

- **Overwritten hook** (#overwritten-hooks): if two scripts/files independently define `public OnPlayerConnect` (or another standard callback) **without** going through `y_hooks`/`hook`, and both files are compiled together in a single `.pwn` via `#include`, it is a symbol redefinition error. If each is a separately compiled module (filterscript), both execute but independently — verify the actual project architecture before assuming either case.
- **Wrong return value** in a callback that acts as a "filter" (e.g. `OnPlayerCommandText` returns `0` for "unhandled, pass to next", `1` for "handled, stop") — always returning `1` breaks other commands/scripts that depend on chaining.
- **Forgetting `KillTimer`**: a repeating timer (`SetTimer(..., true)`) tied to an entity that can disappear (player, vehicle) must be cancelled in the corresponding disconnect/destroy callback, otherwise the timer keeps firing on a recycled ID.

## Native/Function Errors

- **Not checking the return value of a native that can fail**: for example `CreateVehicle` returns `INVALID_VEHICLE_ID` on failure; not checking this return before using the ID in subsequent calls causes undefined behaviour.
- **Confusing an invalid `playerid` with `0`**: `playerid` at `0` is a valid player ID (the first connected player), so a check like `if (playerid)` to verify validity is wrong — use `IsPlayerConnected(playerid)` or compare explicitly to `INVALID_PLAYER_ID`.

## Poorly Parenthesized Macros

```pawn
#define DOUBLE(%0) %0 * 2          // WRONG
#define DOUBLE(%0) ((%0) * 2)      // correct
```

Without parentheses, `DOUBLE(a + b)` expands to `a + b * 2` instead of `(a + b) * 2` — always fully parenthesize the body and each parameter of a macro.

## Quick Checklist Before Closing a Bug

1. Has the compilation warning/error disappeared (and no new ones introduced)?
2. Are the relevant buffers sized with `sizeof()` at the call site rather than a hardcoded number?
3. Are per-player/vehicle data correctly reset on connection/creation?
4. Are the return values of critical natives (entity creation, parsing) checked before use?
5. Are timers/dynamic objects created cleaned up when the associated entity is destroyed?
