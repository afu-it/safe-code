#!/usr/bin/env bash
#
# safe-code check-version — maintainer guard against version drift.
#
# The safe-code version is written in several places that must move together.
# The single source of truth is the frontmatter `version:` in
# skills/safe-code/SKILL.md; this script asserts every other live mention
# matches it. Run it before tagging/releasing or wire it into CI.
#
# This is a REPO-MAINTAINER check (it inspects the skill source). It is NOT the
# same as scripts/check.sh, which verifies conventions inside a CONSUMER project.
#
# Exit codes:
#   0  all version mentions agree
#   1  a mismatch was found (or the source version could not be read)
#
# Usage:
#   bash scripts/check-version.sh [repo-root]
set -u

if [ -t 1 ]; then
	C_OK=$'\033[32m'; C_ERR=$'\033[31m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
	C_OK=""; C_ERR=""; C_DIM=""; C_RST=""
fi
pass() { printf "  %s[ok]%s   %s\n" "$C_OK" "$C_RST" "$1"; }
fail() { printf "  %s[FAIL]%s %s\n" "$C_ERR" "$C_RST" "$1"; }
info() { printf "  %s%s%s\n" "$C_DIM" "$1" "$C_RST"; }

# ---- locate repo root -------------------------------------------------------
if [ "${1:-}" != "" ] && [ -d "$1" ]; then
	ROOT="$(cd "$1" && pwd)"
elif command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
	ROOT="$(git rev-parse --show-toplevel)"
else
	ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

SKILL="$ROOT/skills/safe-code/SKILL.md"
README="$ROOT/README.md"

printf "safe-code check-version\n"
info "repo root: $ROOT"
echo

if [ ! -f "$SKILL" ]; then
	fail "source of truth not found: $SKILL"
	exit 1
fi

# ---- source of truth: SKILL.md frontmatter version --------------------------
SRC="$(grep -m1 '^version:' "$SKILL" | sed -E 's/^version:[[:space:]]*"?([0-9]+\.[0-9]+(\.[0-9]+)?)"?.*/\1/')"
if [ -z "$SRC" ]; then
	fail "could not read frontmatter version from $SKILL"
	exit 1
fi
pass "source of truth: SKILL.md frontmatter = $SRC"
echo

FAILS=0
check() { # check <label> <found-version> ; empty found = "not present" (skipped)
	local label="$1" found="$2"
	if [ -z "$found" ]; then
		info "$label: not present (skipped)"
	elif [ "$found" = "$SRC" ]; then
		pass "$label = $found"
	else
		fail "$label = $found  (expected $SRC)"
		FAILS=$((FAILS + 1))
	fi
}

# ---- README badge: ![version](...badge/version-X.Y...) ----------------------
if [ -f "$README" ]; then
	BADGE="$(grep -oE 'badge/version-[0-9]+\.[0-9]+(\.[0-9]+)?' "$README" | head -1 | sed -E 's#badge/version-##')"
	check "README.md badge" "$BADGE"
else
	info "README.md: not found (skipped)"
fi

# ---- Step 8 summary banner: === safe-code vX.Y session complete === ---------
BANNER="$(grep -oE 'safe-code v[0-9]+\.[0-9]+(\.[0-9]+)? session complete' "$SKILL" | head -1 | sed -E 's/^safe-code v//; s/ session complete$//')"
check "SKILL.md Step 8 banner" "$BANNER"

echo
if [ "$FAILS" -eq 0 ]; then
	printf "%sResult: OK%s — all version mentions agree on %s\n" "$C_OK" "$C_RST" "$SRC"
	exit 0
else
	printf "%sResult: FAILED%s — %d mismatch(es); update them to %s or fix the source\n" \
		"$C_ERR" "$C_RST" "$FAILS" "$SRC"
	exit 1
fi
