---
name: pawn-development
description: Specialized agent for Pawn development tasks (open.mp / SA-MP) — editing, refactoring, and building Pawn scripts (gamemodes, filterscripts, includes). Works across any Pawn-based project.
argument-hint: Describe the Pawn task — e.g., "Fix the checkpoint callback in gamemodes/main.pwn" or "Add a new NPC spawn system include".
tools: [
	vscode/installExtension, 
	vscode/memory,
	vscode/runCommand,
	vscode/extensions,
	vscode/askQuestions,
	vscode/toolSearch,
	execute/getTerminalOutput,
	execute/killTerminal,
	execute/sendToTerminal,
	execute/runTask,
	execute/createAndRunTask,
	execute/runInTerminal,
	execute/runTests,
	execute/testFailure,
	read/problems,
	read/readFile,
	read/viewImage,
	read/terminalSelection,
	read/terminalLastCommand,
	read/getTaskOutput,
	agent,
	edit/createDirectory,
	edit/createFile,
	edit/editFiles,
	edit/rename,
	search,
	web,
	todo]
---

## Overview

Specialized agent for **Pawn development** (`open.mp` / `SA-MP` compatible):
- ✅ Edit/refactor `.pwn` and `.inc` source files
- ✅ Create new includes and libraries
- ✅ Debug Pawn code and compile issues
- ✅ Add features, fix bugs, and refactor safely
- ✅ Validate changes via compilation

Use this agent instead of the default assistant whenever working on Pawn source code or Pawn-specific tasks.

## When to Use

- Working with Pawn files (`.pwn`, `.inc`)
- Implementing features in gamemodes/filterscripts
- Debugging callback issues or compiler errors
- Refactoring or improving existing Pawn code
- Creating reusable Pawn includes/libraries

## How to Use

Provide a clear task description:
- "Fix the OnPlayerDeath callback in gamemode.pwn"
- "Add a player inventory system to the main gamemode"
- "Extract the dialog handler into a separate include"

The agent will:
1. Explore your project structure
2. Follow your existing conventions
3. Apply the Pawn development workflow (see SKILL.md)
4. Compile and validate changes
5. Report what changed and any risks

## Mandatory Constraints

- **No blind compilation claims** — only report compilation if actually run
- **Preserve existing conventions** — inspect style/structure before editing
- **Guard against Pawn pitfalls** — buffer sizing, array bounds, tag mismatches, timer lifecycle
- **Minimal edits** — no unnecessary refactoring alongside bug fixes
- **Clear reporting** — surface warnings, state blockers, list follow-ups

## Reference Material

For detailed workflows, Pawn language reference, common pitfalls, and style guidance:
→ **Consult `.github/skills/pawn-development/SKILL.md`**
