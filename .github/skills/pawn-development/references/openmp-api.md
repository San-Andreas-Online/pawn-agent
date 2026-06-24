# API open.mp / SA-MP

open.mp is a modern, open-source reimplementation of the SA-MP server, **backward-compatible** with existing SA-MP gamemodes/filterscripts while adding new natives, more precise callbacks, and a `config.json` configuration file (instead of/in addition to `server.cfg`).

## Table des matières

- Main lifecycle callbacks
- Player iteration: `foreach`
- Commands: y_hooks / sscanf
- Dialogs
- Timers
- Streamer (dynamic objects/zones)
- Notable differences: open.mp vs legacy SA-MP

---

## Main lifecycle callbacks

| Callback | When | Common pitfall |
| --- | --- | --- |
| `OnGameModeInit` | Gamemode startup | Forgetting `SetGameModeText`, `UsePlayerPedAnims`, etc. does not prevent compilation but changes default behavior |
| `OnPlayerConnect` | Player connection | `playerid` can be reused after disconnect — always reset player data here, not only at creation time |
| `OnPlayerDisconnect` | Player disconnect | **Always** clean up related resources (active timers, streamer objects, pending MySQL entries) or you may get leaks/crashes when this `playerid` is reused |
| `OnPlayerSpawn` | Player spawn | Do not confuse with `OnPlayerConnect` for "first spawn vs respawn" logic |
| `OnDialogResponse` | Dialog response | Always check both `dialogid` AND `response` (1=left button, 0=right) before acting |

Each hooked callback must **return a value** consistent with its usage: returning `0` in some callbacks (e.g. `OnPlayerCommandText`) means "not handled" and lets other scripts/the server process the event; returning `1` stops it. Check existing behavior before changing return values.

## Player iteration: `foreach`

Instead of:

```pawn
for (new i = 0; i < MAX_PLAYERS; i++)
{
    if (!IsPlayerConnected(i)) continue;
    // ...
}
```

The idiomatic pattern (via YSI `y_iterate`/`foreach`):

```pawn
foreach (new i : Player)
{
    // i is guaranteed to be a connected player
}
```

If the project already uses `foreach`/`Iterator`, stay consistent with that pattern instead of reintroducing manual `for` loops.

## Commands: y_hooks / sscanf

Two approaches often coexist in the same project:

**Simple callback hooks** (no library):

```pawn
public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/help", true))
    {
        // ...
        return 1;
    }
    return 0;
}
```

Warning: if **multiple** scripts define `public OnPlayerCommandText`, only YSI/y_hooks behavior (which chains hooks) guarantees they all run — without that library, redefining the same `public` in the same compilation unit is an error; in separate files not compiled together, it is not an issue.

**With `y_hooks`**:

```pawn
hook OnPlayerCommandText(playerid, cmdtext[])
{
    // each script can hook this callback independently; y_hooks chains them automatically
}
```

**Argument parsing with sscanf** (very common for commands like `/sethealth <id> <value>`):

```pawn
new targetid, Float:health;
if (sscanf(params, "if", targetid, health))
{
    SendClientMessage(playerid, -1, "Usage: /sethealth <id> <health>");
    return 1;
}
```

- The `sscanf` format (`d`=integer, `f`=float, `s`=string, `u`=player by name/id...) must exactly match the number and order of variables passed, or undefined silent behavior may occur.
- `sscanf` returns a **non-zero** value when parsing fails — always check this return value before using variables.

## Dialogs

```pawn
ShowPlayerDialog(playerid, DIALOG_MON_MENU, DIALOG_STYLE_LIST, "Titre", "Option 1\nOption 2", "Choisir", "Annuler");

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DIALOG_MON_MENU)
    {
        if (!response) return 1; // "Cancel" button
        switch (listitem)
        {
            case 0: { /* Option 1 */ }
            case 1: { /* Option 2 */ }
        }
    }
    return 0;
}
```

- Always define dialog IDs as named constants (`#define DIALOG_MON_MENU 100`) instead of hardcoded numbers, to avoid ID collisions across scripts.

## Timers

```pawn
new monTimer = SetTimerEx("MaFonction", 1000, false, "i", playerid); // false = one-time execution
// ...
public MaFonction(playerid)
{
    if (!IsPlayerConnected(playerid)) return 1; // player may have disconnected before execution
    // ...
    return 1;
}
```

- **Always** verify that referenced entities (player, vehicle, object) still exist when the timer fires — even a short delay allows disconnects in between.
- Use `KillTimer()` in `OnPlayerDisconnect`/`OnGameModeExit` for any repeating timer (`true`) tied to an entity that may disappear, or you risk leaks/crashes on reused `playerid` values.

## Streamer (dynamic objects/zones)

Used to manage many objects/zones/checkpoints dynamically without exceeding native limits:

```pawn
new STREAMER_TAG_OBJECT:monObjet = CreateDynamicObject(modelid, x, y, z, rx, ry, rz, worldid, interiorid, playerid, streamdistance);
```

- Always type the variable with the matching `STREAMER_TAG_*` tag (e.g. `STREAMER_TAG_OBJECT:`, `STREAMER_TAG_AREA:`) rather than a raw integer — otherwise generic `Streamer_*` functions may misinterpret the type.
- Explicitly destroy (`DestroyDynamicObject`, etc.) any dynamically created streamer entity when no longer needed (map change, creator disconnect) to prevent server-side memory buildup.

## Notable differences: open.mp vs legacy SA-MP

- **Configuration**: open.mp uses `config.json` (JSON structure) instead of `server.cfg`; verify which one the project actually uses before proposing config changes.
- **Compatibility**: existing SA-MP code (`a_samp.inc`) compiles and runs on open.mp in the vast majority of cases — no need to migrate legacy code unless the user explicitly wants open.mp-specific natives.
- **Extended natives**: open.mp exposes additional information (client version, more control over components/skins, more granular callbacks) — if a request seems limited in classic SA-MP, check whether a dedicated open.mp native exists before implementing a complex workaround.
- **Legacy plugins**: most SA-MP plugins (streamer, MySQL R41, sscanf, YSI) remain usable as-is on open.mp.
