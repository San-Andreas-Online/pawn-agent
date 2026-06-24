#!/usr/bin/env bash
#
# compile_check.sh — Locate pawncc in an open.mp/SA-MP project and compile
# a .pwn/.inc file to verify that it does not introduce errors.
#
# Usage:
#   bash compile_check.sh path/to/file.pwn [project_root_path]
#
# If project_root_path is not provided, the script walks up from the source
# file directory to look for a pawncc binary and common include directories
# (qawno/include, pawno/include, includes/).

set -uo pipefail

SOURCE_FILE="${1:-}"
PROJECT_ROOT="${2:-}"

if [[ -z "$SOURCE_FILE" ]]; then
    echo "Usage: $0 <file.pwn|file.inc> [project_root]" >&2
    exit 2
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: file not found: $SOURCE_FILE" >&2
    exit 2
fi

SOURCE_DIR="$(cd "$(dirname "$SOURCE_FILE")" && pwd)"

# If the project root is not provided, walk up to 6 levels above the source
# file to find a pawncc binary.
if [[ -z "$PROJECT_ROOT" ]]; then
    SEARCH_DIR="$SOURCE_DIR"
    for _ in 1 2 3 4 5 6; do
        if [[ -d "$SEARCH_DIR" ]]; then
            PROJECT_ROOT="$SEARCH_DIR"
        fi
        PARENT="$(dirname "$SEARCH_DIR")"
        [[ "$PARENT" == "$SEARCH_DIR" ]] && break
        SEARCH_DIR="$PARENT"
    done
fi

echo "Searching for pawncc under: $PROJECT_ROOT"

PAWNCC=""
while IFS= read -r -d '' candidate; do
    PAWNCC="$candidate"
    break
done < <(find "$PROJECT_ROOT" -maxdepth 6 -type f \( -iname "pawncc" -o -iname "pawncc.exe" \) -print0 2>/dev/null)

if [[ -z "$PAWNCC" ]]; then
    cat >&2 <<'EOF'
pawncc not found in this project/environment.

Unable to verify compilation automatically. Tell the user this instead of
pretending the file was compiled — propose a targeted manual review instead
(see references/common-bugs.md) or ask the user to provide the path to
pawncc/an include directory.
EOF
    exit 3
fi

echo "pawncc found: $PAWNCC"
chmod +x "$PAWNCC" 2>/dev/null || true

# Build the list of common include directories present in the project.
INCLUDE_ARGS=()
for dir in "qawno/include" "pawno/include" "includes" "include"; do
    full="$PROJECT_ROOT/$dir"
    if [[ -d "$full" ]]; then
        INCLUDE_ARGS+=("-i$full")
    fi
done
# Also add the source file directory itself, for local includes.
INCLUDE_ARGS+=("-i$SOURCE_DIR")

echo "Compiling: $SOURCE_FILE"
echo "Include options: ${INCLUDE_ARGS[*]:-(none found)}"
echo "---"

"$PAWNCC" -d3 "${INCLUDE_ARGS[@]}" "$SOURCE_FILE"
STATUS=$?

echo "---"
if [[ $STATUS -eq 0 ]]; then
    echo "Compilation succeeded (exit code 0). Still check warnings above (notably 213, 235 — see references/compiling.md)."
else
    echo "Compilation failed (exit code $STATUS). See the errors above and references/compiling.md for interpretation."
fi

exit $STATUS
