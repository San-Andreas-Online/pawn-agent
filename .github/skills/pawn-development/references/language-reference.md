# Pawn Language Reference

Pawn is a weakly typed language, close to C, but with important specifics that cause most bugs and compilation errors for developers coming from other languages.

## Table of contents

- Variables, scope, and tags
- Arrays and strings
- Enumerations
- Operators and common pitfalls
- Functions: native / public / forward / stock
- Control flow
- Macros and preprocessor
- Includes and include guards

---

## Variables, scope, and tags

```pawn
new iVariable;              // integer, default value is 0
new Float:fValue = 1.5;     // Float: tag required for floating-point values
new bool:bFlag = true;      // tag bool:
static iCounter;            // file scope, persists across calls if local to a function
new const MAX_X = 100;      // constant (equivalent to #define in many cases)
```

- The **tag** (`Float:`, `bool:`, or a custom tag) comes before the variable name, not after like a C type. Use `new Float:x;` and not `new float x;`.
- A `static` variable declared **inside a function** keeps its value between calls (like `static` in C) — a frequent pitfall if used by mistake while expecting it to reset.
- A `static` variable declared **at file level** (outside functions) limits its visibility to that file — useful to avoid name collisions between `.pwn`/`.inc`, but then it is only visible in the current module.
- There is no true strong typing: a `cell` can be reinterpreted; a tag mismatch only triggers a **warning**, not an error — so code can compile and still crash at runtime.

## Arrays and strings

Strings are arrays of `cell` (often treated as ASCII characters), not a native type:

```pawn
new szName[MAX_PLAYER_NAME];      // string buffer, always size explicitly
GetPlayerName(playerid, szName, sizeof(szName));   // use sizeof() for length, not a hardcoded constant
format(szMessage, sizeof(szMessage), "Bonjour %s", szName);
```

- **Always** use `sizeof(buffer)` instead of a hardcoded number when calling a function that fills a buffer — resizing the buffer later without updating a hardcoded number is a classic source of memory overflow.
- `MAX_PLAYER_NAME` is 24 (including the terminator) in standard SA-MP/open.mp — a smaller buffer truncates or corrupts adjacent memory.
- String concatenation is not done with `+`: use `format()`, or `strcat()`.
- A 2D string array must declare both dimensions: `new szList[10][64];`.

## Enumerations

Very common pattern used to structure per-player/object data (struct-like):

```pawn
enum E_PLAYER_DATA
{
    E_PD_SCORE,
    E_PD_LEVEL,
    Float:E_PD_HEALTH_BONUS
}

new PlayerData[MAX_PLAYERS][E_PLAYER_DATA];

PlayerData[playerid][E_PD_SCORE] = 100;
```

- The tag of a floating-point field in an enumeration must be repeated (`Float:E_PD_HEALTH_BONUS`), otherwise it is treated as an integer.
- Prefix enumeration constants (e.g. `E_PD_`) to avoid name collisions between multiple enums in the same scope.

## Operators and common pitfalls

| Pitfall | Faulty example | Correction |
| --- | --- | --- |
| Assignment instead of comparison | `if (iScore = 0)` | `if (iScore == 0)` |
| Silent integer division | `new x = 5 / 2;` → `2` | Use `Float:` and `float()` if a decimal result is expected |
| Comparison with different tags | `if (fHealth == 0)` without cast | `if (fHealth == 0.0)` or `floatcmp` |
| `++`/`--` on float tag | `fValue++;` does nothing useful on a Float | `fValue += 1.0;` |

Pawn **does not raise compilation errors** for most of these pitfalls (at best, a tag mismatch warning) — that is why `references/common-bugs.md` is essential as a companion.

## Functions: native / public / forward / stock

```pawn
native SetPlayerHealth(playerid, Float:health);   // implemented server/plugin side, not in Pawn

forward OnMyCustomEvent(playerid, reason);         // declares a callback other scripts can hook
public OnMyCustomEvent(playerid, reason)           // implementation called by the server or via CallLocalFunction
{
    return 1;
}

stock MyHelperFunction(playerid)                   // utility function; "stock" avoids a warning if never called
{
    return GetPlayerScore(playerid) * 2;
}
```

- `public`: the name is resolved by string at runtime (server/plugins can call it by name) — renaming an existing `public` function can silently break external hooks.
- `forward` is required so another script can call `CallLocalFunction("FunctionName", ...)` even if the function is not yet defined at parse time.
- `stock` suppresses the "function never used" warning — use it for library functions intended to be included elsewhere, not to hide dead code by mistake.
- The default **return type** is `cell` (integer); to return a semantic boolean, code typically returns `1`/`0` even without an explicit `bool:` tag on the function.

## Control flow

```pawn
switch (iAction)
{
    case 0: { /* ... */ }
    case 1, 2: { /* multiple values */ }
    default: { /* ... */ }
}

for (new i = 0; i < MAX_PLAYERS; i++)
{
    if (!IsPlayerConnected(i)) continue;
    // ...
}
```

- No `break` is needed in a Pawn `case` (unlike C) — each `case` is already exclusive.
- `foreach` (from YSI/y_iterate) is very often preferred over `for (new i = 0; i < MAX_PLAYERS; i++)` to iterate only over connected players — see `references/openmp-api.md`.

## Macros and preprocessor

```pawn
#define MAX_HOUSES 100
#define IsValidHouse(%0) (%0 >= 0 && %0 < MAX_HOUSES)
```

- Parameterized macros (`%0`, `%1`...) are a frequent source of bugs if arguments contain operators without parentheses at call site — always parenthesize the full macro body and each parameter.

## Includes and include guards

```pawn
#if defined _mylib_included
    #endinput
#endif
#define _mylib_included
```

- Any new library (`.inc`) intended to be included by multiple files must have this kind of guard to avoid redefinitions in case of double inclusion.
