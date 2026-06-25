# Compiling with pawncc

## Locate the compiler

In a typical open.mp project, `pawncc` is usually located in one of these paths (depending on version/setup):

```text
qawno/pawncc          (open.mp, Linux)
qawno/pawncc.exe      (open.mp, Windows)
pawno/pawncc          (SA-MP legacy, Linux)
pawno/pawncc.exe      (SA-MP legacy, Windows)
```

You can still check the project structure to find it if the above paths do not exist.

The `scripts/compile_check.sh` script provided with this skill attempts to automatically locate the binary in the current project.

## Typical compile command

```bash
./pawncc -d3 -;+ -O2 -i./includes -i./qawno/include gamemode.pwn
```

- `-d3`: maximum debug level (recommended in development — makes `crashdetect` much more useful to pinpoint the exact line of a crash).
- `-i<path>`: adds an include search path for `#include` files (often required for third-party includes like `streamer.inc`, `sscanf2.inc`, `YSI_*` files).
- `-O2`: optimization level (mostly for production; can make debugging harder).
- By default, the output `.amx` file uses the same name as the source `.pwn` file.

If the project has a custom build configuration (shell script, VS Code task, Makefile), **use it first** instead of rebuilding a manual command, so you keep the include paths and options already defined by the project.

## Reading pawncc messages

General format: `file.pwn(line_number) : error/warning NNN: message`

### Common errors

| Code        | Meaning                          | Typical cause                                                                                         |
| ----------- | -------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `error 017` | undefined symbol                 | Function/variable used before declaration, missing include, or typo in a name                         |
| `error 021` | symbol already defined           | Variable/function redefined (often due to double include without guard, or duplicate `public` name)   |
| `error 035` | argument type mismatch           | Argument type/tag incompatible with the function signature                                            |
| `error 029` | invalid expression, assumed zero | Syntax error in an expression — often a missing parenthesis or misplaced operator                     |

### Common warnings (do not ignore)

| Code          | Meaning                                   | Why it matters                                                                                     |
| ------------- | ----------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `warning 213` | tag mismatch                              | Very often a missing `Float:`/`bool:` — see `references/common-bugs.md`                            |
| `warning 217` | loose indentation                         | Cosmetic only, no functional impact                                                                |
| `warning 225` | unreachable code                          | Dead code after a `return` — often indicates a control-flow logic bug, not just cleanup            |
| `warning 235` | public function lacks forward declaration | The callback will not be called correctly by the server — almost always a real bug to fix          |

## Diagnosing runtime crashes (beyond compilation)

If the code compiles but the server crashes or behaves incorrectly at runtime:

- Check that the `crashdetect` plugin appears in server logs (`server_log.txt`) — it reports the exact Pawn line of a crash if the `.amx` was compiled with `-d3`.
- Crashes caused by array overflows do not always occur immediately after the faulty write — corruption may appear later in an unrelated-looking variable. If `crashdetect` points to a line that seems harmless, suspect an earlier array overflow (see `references/common-bugs.md`).
