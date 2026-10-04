#!/usr/bin/env bash
#
# safe-code check-privacy — maintainer guard: shipped files must stay generic.
#
# safe-code is a public skill. Files that ship to users must not carry personal
# absolute paths, email addresses, or credentials. This script scans the shipped
# set and fails on:
#   - absolute home paths:  /Users/<name>  /home/<name>
#   - email addresses       (allowed: noreply@..., ...@users.noreply.github.com,
#                            ...@example.com/.org/.net, git@<host>: SSH remotes,
#                            and placeholder local parts: user@ you@ name@
#                            your-name@ yourname@ me@ someone@ anda@)
#   - token shapes          ghp_/gho_/ghu_/ghs_/ghr_/github_pat_, sk-..., xox?-...,
#                           AKIA..., -----BEGIN ... KEY-----
#
# Shipped/public set: skills/, integrations/, scripts/, README.md, CHANGELOG.md,
# CLAUDE.md, TUTORIAL-*.md, LICENSE. docs/ (specs/plans) is maintainer-only and
# excluded. The patterns below are written so this script does not match itself.
# A deliberate example can opt out per line with the marker `privacy-lint: allow`.
#
# Exit codes:
#   0  no hits
#   1  one or more hits (printed as file:line: text)
#
# Usage:
#   bash scripts/check-privacy.sh [repo-root]
set -u

if [ -t 1 ]; then
	C_OK=$'\033[32m'
	C_ERR=$'\033[31m'
	C_DIM=$'\033[2m'
	C_RST=$'\033[0m'
else
	C_OK=""
	C_ERR=""
	C_DIM=""
	C_RST=""
fi

# ---- locate repo root -------------------------------------------------------
if [ "${1:-}" != "" ] && [ -d "$1" ]; then
	ROOT="$(cd "$1" && pwd)"
else
	ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi
cd "$ROOT" || exit 1

printf "safe-code check-privacy\n"
printf "  %srepo root: %s%s\n\n" "$C_DIM" "$ROOT" "$C_RST"

TARGETS=()
for t in skills integrations scripts README.md CHANGELOG.md CLAUDE.md LICENSE TUTORIAL-*.md; do
	[ -e "$t" ] && TARGETS+=("$t")
done
if [ "${#TARGETS[@]}" -eq 0 ]; then
	printf "  %s[FAIL]%s no shipped files found under %s\n" "$C_ERR" "$C_RST" "$ROOT"
	exit 1
fi

PATHS='/Users/[A-Za-z0-9._-]|/home/[a-z]'
EMAIL='[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}'
TOKENS='gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|(^|[^A-Za-z0-9])sk-[A-Za-z0-9_-]{20,}|xox[abposr]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
# allowed email shapes, removed from a line before the email test
EMAIL_OK='[A-Za-z0-9._%+-]*noreply@[A-Za-z0-9.-]+|[A-Za-z0-9._%+-]+@users\.noreply\.github\.com|[A-Za-z0-9._%+-]+@example\.(com|org|net)|git@[A-Za-z0-9.-]+:|(^|[^A-Za-z0-9._%+-])(user|you|name|your-name|yourname|me|someone|anda)@[A-Za-z0-9.-]+'

HITS=0
report() { # report <kind> <grep-output-line>
	printf "  %s[FAIL]%s %-6s %s\n" "$C_ERR" "$C_RST" "$1" "$2"
	HITS=$((HITS + 1))
}

# grep -I skips binary files; -r recurses; -n adds line numbers; -H always names the file
scan() { # scan <kind> <regex> [allow-regex]
	local kind="$1" re="$2" ok="${3:-}" line text
	while IFS= read -r line; do
		text="${line#*:*:}"
		case "$text" in *"privacy-lint: allow"*) continue ;; esac
		if [ -n "$ok" ]; then
			printf '%s\n' "$text" | sed -E "s#${ok}##g" | grep -qE "$re" || continue
		fi
		report "$kind" "$line"
	done < <(grep -rIHnE --exclude=.DS_Store "$re" "${TARGETS[@]}" 2>/dev/null)
}

scan "path" "$PATHS"
scan "email" "$EMAIL" "$EMAIL_OK"
scan "token" "$TOKENS"

echo
if [ "$HITS" -eq 0 ]; then
	printf "%sResult: OK%s — no personal paths, emails, or token shapes in shipped files\n" "$C_OK" "$C_RST"
	exit 0
fi
printf "%sResult: FAILED%s — %d hit(s); make them generic, or mark a deliberate example with 'privacy-lint: allow'\n" \
	"$C_ERR" "$C_RST" "$HITS"
exit 1
