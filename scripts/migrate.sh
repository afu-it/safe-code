#!/usr/bin/env bash
#
# safe-code migrate — move legacy session folders into the unified .agents/ dir.
#
# v3.0 moved session/continuity docs from per-agent folders
# (.codex/agents/, .claude/agents/, .cursor/agents/, .windsurf/agents/, and the
# helper skills' .codex/memory/ etc.) into a single agent-agnostic .agents/
# folder at the project root. This script performs that move for you.
#
# Safe by default: DRY-RUN unless you pass --apply. Never overwrites an existing
# file in .agents/ (conflicts are reported and skipped). Never deletes anything
# other than the now-empty legacy folders, and only with --apply.
#
# Usage:
#   bash scripts/migrate.sh            # preview (dry-run)
#   bash scripts/migrate.sh --apply    # actually move files
#   bash scripts/migrate.sh --apply [project-root]
#
# Exit codes:
#   0  nothing to do, or migration completed (or previewed) cleanly
#   1  completed/previewed but some files were skipped due to conflicts
set -u

# ---- args -------------------------------------------------------------------
APPLY=0
ROOT_ARG=""
for arg in "$@"; do
	case "$arg" in
	--apply) APPLY=1 ;;
	-h | --help)
		sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
		exit 0
		;;
	*) ROOT_ARG="$arg" ;;
	esac
done

# ---- output helpers (no color if not a tty) ---------------------------------
if [ -t 1 ]; then
	C_OK=$'\033[32m'
	C_WARN=$'\033[33m'
	C_ERR=$'\033[31m'
	C_DIM=$'\033[2m'
	C_RST=$'\033[0m'
else
	C_OK=""
	C_WARN=""
	C_ERR=""
	C_DIM=""
	C_RST=""
fi

pass() { printf "  %s[ok]%s   %s\n" "$C_OK" "$C_RST" "$1"; }
warn() { printf "  %s[warn]%s %s\n" "$C_WARN" "$C_RST" "$1"; }
move() { printf "  %s[move]%s %s\n" "$C_OK" "$C_RST" "$1"; }
skip() { printf "  %s[skip]%s %s\n" "$C_ERR" "$C_RST" "$1"; }
info() { printf "  %s%s%s\n" "$C_DIM" "$1" "$C_RST"; }

# ---- locate project root (same anchoring strategy as check.sh) --------------
find_root() {
	if [ "${1:-}" != "" ] && [ -d "$1" ]; then
		(cd "$1" && pwd)
		return
	fi
	if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
		git rev-parse --show-toplevel
		return
	fi
	local dir
	dir="$(pwd)"
	while [ "$dir" != "/" ]; do
		if [ -f "$dir/AGENTS.md" ] || [ -d "$dir/.agents" ]; then
			echo "$dir"
			return
		fi
		dir="$(dirname "$dir")"
	done
	pwd
}

ROOT="$(find_root "$ROOT_ARG")"
cd "$ROOT" || {
	echo "cannot enter $ROOT"
	exit 1
}

# legacy session-doc locations from before v3.0
LEGACY_DIRS=(
	".codex/agents" ".claude/agents" ".cursor/agents" ".windsurf/agents"
	".codex/memory" ".claude/memory" ".cursor/memory" ".windsurf/memory"
)

printf "safe-code migrate\n"
info "project root: $ROOT"
if [ "$APPLY" -eq 1 ]; then
	info "mode: APPLY (files will be moved)"
else
	info "mode: DRY-RUN (preview only; pass --apply to move)"
fi
echo

# ---- find legacy folders that actually exist --------------------------------
FOUND=()
for d in "${LEGACY_DIRS[@]}"; do
	[ -d "$d" ] && FOUND+=("$d")
done

if [ "${#FOUND[@]}" -eq 0 ]; then
	pass "no legacy session folders found — nothing to migrate"
	exit 0
fi

# ---- migrate ----------------------------------------------------------------
MOVED=0
SKIPPED=0

ensure_agents_dir() {
	if [ ! -d .agents ]; then
		if [ "$APPLY" -eq 1 ]; then
			mkdir -p .agents
			pass "created .agents/"
		else
			info "would create .agents/"
		fi
	fi
}

for d in "${FOUND[@]}"; do
	echo "From $d"
	# only migrate markdown session docs; leave anything else in place
	shopt -s nullglob
	files=("$d"/*.md)
	shopt -u nullglob
	if [ "${#files[@]}" -eq 0 ]; then
		info "no *.md files here"
		continue
	fi
	ensure_agents_dir
	for src in "${files[@]}"; do
		base="$(basename "$src")"
		dest=".agents/$base"
		if [ -e "$dest" ]; then
			skip "$base — already exists in .agents/ (left $src in place)"
			SKIPPED=$((SKIPPED + 1))
			continue
		fi
		if [ "$APPLY" -eq 1 ]; then
			if command -v git >/dev/null 2>&1 && git ls-files --error-unmatch "$src" >/dev/null 2>&1; then
				git mv "$src" "$dest" 2>/dev/null || mv "$src" "$dest"
			else
				mv "$src" "$dest"
			fi
			move "$base -> .agents/$base"
		else
			move "would move $base -> .agents/$base"
		fi
		MOVED=$((MOVED + 1))
	done
done
echo

# ---- clean up now-empty legacy folders (apply only) -------------------------
if [ "$APPLY" -eq 1 ]; then
	for d in "${FOUND[@]}"; do
		if [ -d "$d" ] && [ -z "$(ls -A "$d" 2>/dev/null)" ]; then
			rmdir "$d" 2>/dev/null && info "removed empty $d"
			# remove now-empty parent (.codex, .claude, ...) if it has nothing left
			parent="$(dirname "$d")"
			if [ -d "$parent" ] && [ -z "$(ls -A "$parent" 2>/dev/null)" ]; then
				rmdir "$parent" 2>/dev/null && info "removed empty $parent"
			fi
		elif [ -d "$d" ]; then
			info "kept $d (still has non-.md files)"
		fi
	done
	echo
fi

# ---- summary ----------------------------------------------------------------
if [ "$APPLY" -eq 1 ]; then
	printf "Summary: %s%d moved%s, %s%d skipped%s\n" "$C_OK" "$MOVED" "$C_RST" "$C_ERR" "$SKIPPED" "$C_RST"
	if [ "$SKIPPED" -gt 0 ]; then
		warn "resolve conflicts above by merging the kept files into .agents/ manually"
	fi
	info "next: review changes, run 'bash scripts/check.sh', then commit"
else
	printf "Summary: %s%d to move%s, %s%d conflict(s)%s — re-run with --apply\n" \
		"$C_OK" "$MOVED" "$C_RST" "$C_ERR" "$SKIPPED" "$C_RST"
fi

[ "$SKIPPED" -gt 0 ] && exit 1
exit 0
