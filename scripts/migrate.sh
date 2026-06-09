#!/usr/bin/env bash
#
# safe-code migrate — move legacy layouts into the unified .safe-code/ dir.
#
# v4.0 moved everything safe-code manages into a single .safe-code/ folder at
# the project root (AGENTS.md stays at root as the universal entry point):
#   pre-v3 layout: .codex/agents/, .claude/agents/, .cursor/agents/,
#                  .windsurf/agents/ and the helper skills' */memory/ dirs
#   v3 layout:     .agents/ session docs + root context/ + root CHANGELOG.md
# This script performs that move and patches old config (.gitignore, AGENTS.md
# path references) to the new version.
#
# Safe by default: DRY-RUN unless you pass --apply. Never overwrites an existing
# file in .safe-code/ (conflicts are reported and skipped). Never deletes
# anything other than now-empty legacy folders, and only with --apply.
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
		sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
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
		if [ -f "$dir/AGENTS.md" ] || [ -d "$dir/.safe-code" ] || [ -d "$dir/.agents" ]; then
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

# legacy session-doc locations (pre-v3 per-agent dirs + v3 unified .agents/)
LEGACY_DIRS=(
	".codex/agents" ".claude/agents" ".cursor/agents" ".windsurf/agents"
	".codex/memory" ".claude/memory" ".cursor/memory" ".windsurf/memory"
	".agents"
)

printf "safe-code migrate (v4.0 layout)\n"
info "project root: $ROOT"
if [ "$APPLY" -eq 1 ]; then
	info "mode: APPLY (files will be moved)"
else
	info "mode: DRY-RUN (preview only; pass --apply to move)"
fi
echo

# ---- find legacy locations that actually exist -------------------------------
FOUND=()
for d in "${LEGACY_DIRS[@]}"; do
	[ -d "$d" ] && FOUND+=("$d")
done

# v3 root context/ counts as legacy only when safe-code managed it
# (marker: progress-tracker.md inside, or the v3 .gitignore entry)
V3_CONTEXT=0
if [ -d context ] && { [ -f context/progress-tracker.md ] ||
	{ [ -f .gitignore ] && grep -qE '^/?context/current-issues\.md' .gitignore; }; }; then
	V3_CONTEXT=1
fi

if [ "${#FOUND[@]}" -eq 0 ] && [ "$V3_CONTEXT" -eq 0 ]; then
	pass "no legacy layouts found — nothing to migrate"
	exit 0
fi

# ---- migrate ----------------------------------------------------------------
MOVED=0
SKIPPED=0

ensure_dir() { # ensure_dir <path>
	if [ ! -d "$1" ]; then
		if [ "$APPLY" -eq 1 ]; then
			mkdir -p "$1"
			pass "created $1/"
		else
			info "would create $1/"
		fi
	fi
}

move_file() { # move_file <src> <dest>
	local src="$1" dest="$2" base
	base="$(basename "$src")"
	if [ -e "$dest" ]; then
		skip "$base — already exists at $dest (left $src in place)"
		SKIPPED=$((SKIPPED + 1))
		return
	fi
	if [ "$APPLY" -eq 1 ]; then
		if command -v git >/dev/null 2>&1 && git ls-files --error-unmatch "$src" >/dev/null 2>&1; then
			git mv "$src" "$dest" 2>/dev/null || mv "$src" "$dest"
		else
			mv "$src" "$dest"
		fi
		move "$src -> $dest"
	else
		move "would move $src -> $dest"
	fi
	MOVED=$((MOVED + 1))
}

# session docs from per-agent dirs and v3 .agents/ -> .safe-code/
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
	ensure_dir .safe-code
	for src in "${files[@]}"; do
		move_file "$src" ".safe-code/$(basename "$src")"
	done
done

# v3 root context/ -> .safe-code/context/ (recursive, .md only)
if [ "$V3_CONTEXT" -eq 1 ]; then
	echo "From context/ (v3 layout)"
	ensure_dir .safe-code/context
	while IFS= read -r src; do
		rel="${src#context/}"
		destdir=".safe-code/context/$(dirname "$rel")"
		[ "$(dirname "$rel")" = "." ] && destdir=".safe-code/context"
		ensure_dir "$destdir"
		move_file "$src" "$destdir/$(basename "$src")"
	done < <(find context -name '*.md' -type f | sort)

	# v3 root CHANGELOG.md -> .safe-code/CHANGELOG.md (only with v3 markers)
	if [ -f CHANGELOG.md ]; then
		echo "From CHANGELOG.md (v3 layout)"
		move_file "CHANGELOG.md" ".safe-code/CHANGELOG.md"
	fi
fi
echo

# ---- patch old config to the new version (apply only) ------------------------
echo "Config patches"
if [ -f .gitignore ] && grep -qE '^/?context/current-issues\.md' .gitignore; then
	if [ "$APPLY" -eq 1 ]; then
		sed -i.safe-code.bak -E 's#^/?context/current-issues\.md#/.safe-code/context/current-issues.md#' .gitignore &&
			rm -f .gitignore.safe-code.bak
		pass ".gitignore: /context/current-issues.md -> /.safe-code/context/current-issues.md"
	else
		info "would patch .gitignore entry to /.safe-code/context/current-issues.md"
	fi
elif [ -f .gitignore ] && grep -q '/.safe-code/context/current-issues.md' .gitignore; then
	pass ".gitignore already on v4.0 path"
else
	info ".gitignore: no safe-code entry to patch"
fi
if [ -f AGENTS.md ] && grep -qE '`(context/|\.agents/)' AGENTS.md; then
	if [ "$APPLY" -eq 1 ]; then
		sed -i.safe-code.bak -E 's#`context/#`.safe-code/context/#g; s#`\.agents/#`.safe-code/#g' AGENTS.md &&
			rm -f AGENTS.md.safe-code.bak
		pass "AGENTS.md: old context/ and .agents/ references rewritten to .safe-code/"
	else
		info "would rewrite AGENTS.md context/ and .agents/ references to .safe-code/"
	fi
else
	info "AGENTS.md: no old path references found"
fi
echo

# ---- clean up now-empty legacy folders (apply only) -------------------------
if [ "$APPLY" -eq 1 ]; then
	for d in "${FOUND[@]}"; do
		if [ -d "$d" ] && [ -z "$(ls -A "$d" 2>/dev/null)" ]; then
			rmdir "$d" 2>/dev/null && info "removed empty $d"
			# remove now-empty parent (.codex, .claude, ...) if it has nothing left
			parent="$(dirname "$d")"
			if [ "$parent" != "." ] && [ -d "$parent" ] && [ -z "$(ls -A "$parent" 2>/dev/null)" ]; then
				rmdir "$parent" 2>/dev/null && info "removed empty $parent"
			fi
		elif [ -d "$d" ]; then
			info "kept $d (still has files — unmigrated, conflicting, or non-.md)"
		fi
	done
	if [ "$V3_CONTEXT" -eq 1 ] && [ -d context ]; then
		# remove emptied context/ tree (find -depth removes leaf dirs first)
		find context -depth -type d -empty -exec rmdir {} \; 2>/dev/null
		[ ! -d context ] && info "removed empty context/" || info "kept context/ (still has files)"
	fi
	echo
fi

# ---- summary ----------------------------------------------------------------
if [ "$APPLY" -eq 1 ]; then
	printf "Summary: %s%d moved%s, %s%d skipped%s\n" "$C_OK" "$MOVED" "$C_RST" "$C_ERR" "$SKIPPED" "$C_RST"
	if [ "$SKIPPED" -gt 0 ]; then
		warn "resolve conflicts above by merging the kept files into .safe-code/ manually"
	fi
	info "next: review changes, run 'bash scripts/check.sh', then commit"
else
	printf "Summary: %s%d to move%s, %s%d conflict(s)%s — re-run with --apply\n" \
		"$C_OK" "$MOVED" "$C_RST" "$C_ERR" "$SKIPPED" "$C_RST"
fi

[ "$SKIPPED" -gt 0 ] && exit 1
exit 0
