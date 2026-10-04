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
# Only safe-code's own files move: the six session files (ACTIVE.md SESSION.md
# LOG.md BACKLOG.md MEMORY.md safe-refactor-code.md, plus a v3 .agents/
# CHANGELOG.md), and only from a folder that carries a safe-code marker (one of
# ACTIVE.md / SESSION.md / safe-refactor-code.md inside it, or a project-level
# marker: .safe-code/, an AGENTS.md naming safe-code, or the v3 .gitignore
# entry). Anything else in those folders — real subagents in .claude/agents/,
# project skills in .agents/skills/ — is never touched. Root context/ moves
# only with the v3 .gitignore entry (or progress-tracker.md plus a project
# marker), and then only safe-code's named context files + feature-specs/*.md;
# a root CHANGELOG.md moves only with the v3 .gitignore entry.
#
# Safe by default: DRY-RUN unless you pass --apply. Never overwrites an existing
# file in .safe-code/ (conflicts are reported and skipped). Never deletes
# anything other than now-empty legacy folders, and only with --apply.
#
# Ships inside the skill (<skill-dir>/scripts/migrate.sh); the skill's source
# repo keeps a root shim at scripts/migrate.sh.
#
# Usage:
#   bash <skill-dir>/scripts/migrate.sh            # preview (dry-run)
#   bash <skill-dir>/scripts/migrate.sh --apply    # actually move files
#   bash <skill-dir>/scripts/migrate.sh --apply [project-root]
#
# Exit codes:
#   0  nothing to do, or migration completed (or previewed) cleanly
#   1  completed/previewed but some files were skipped due to conflicts
set -u

# sibling scripts (check.sh) live next to this one
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---- args -------------------------------------------------------------------
APPLY=0
ROOT_ARG=""
for arg in "$@"; do
	case "$arg" in
	--apply) APPLY=1 ;;
	-h | --help)
		sed -n '2,38p' "$0" | sed 's/^# \{0,1\}//'
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
		if [ -f "$dir/AGENTS.md" ] || [ -d "$dir/.safe-code" ] || [ -f "$dir/.agents/ACTIVE.md" ] ||
			[ -f "$dir/.agents/SESSION.md" ]; then
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

# safe-code session files (the only names ever moved out of a legacy folder)
SESSION_FILES=(ACTIVE.md SESSION.md LOG.md BACKLOG.md MEMORY.md safe-refactor-code.md)
# names distinctive enough to mark a folder as safe-code's on their own
MARKER_FILES=(ACTIVE.md SESSION.md safe-refactor-code.md)

# safe-code's v3 root context/ files (the only names ever moved out of context/;
# feature-specs/*.md also moves). Keep in sync with SKILL.md Doc Structure.
CONTEXT_FILES=(project-overview.md architecture.md user-preferences.md code-standards.md
	ai-workflow-rules.md ui-context.md progress-tracker.md current-issues.md)

# v3 .gitignore entry: the one marker that proves safe-code managed root context/
V3_GITIGNORE=0
if [ -f .gitignore ] && grep -qE '^/?context/current-issues\.md' .gitignore; then
	V3_GITIGNORE=1
fi

# project-level safe-code marker
PROJECT_MARKER=0
if [ -d .safe-code ] || [ "$V3_GITIGNORE" -eq 1 ] ||
	{ [ -f AGENTS.md ] && grep -qi 'safe-code' AGENTS.md; }; then
	PROJECT_MARKER=1
fi

# exact-case file test: on a case-insensitive filesystem `[ -f d/MEMORY.md ]`
# also matches a subagent's memory.md, so compare the real directory entry.
has_file() { # has_file <dir> <name>
	[ -f "$1/$2" ] && [ -n "$(find "$1" -mindepth 1 -maxdepth 1 -type f -name "$2" 2>/dev/null)" ]
}

# a safe-code session file: exact name, and not a subagent/skill definition
# (those open with a `---` frontmatter line; safe-code session files never do)
is_session_file() { # is_session_file <dir> <name>
	local first=""
	has_file "$1" "$2" || return 1
	IFS= read -r first <"$1/$2" || [ -n "$first" ] || return 0
	[ "${first%$'\r'}" != "---" ]
}

# files in <dir> that safe-code owns (prints one path per line)
safe_code_files() { # safe_code_files <dir>
	local d="$1" f
	for f in "${SESSION_FILES[@]}"; do
		is_session_file "$d" "$f" && printf '%s\n' "$d/$f"
	done
	# v3 .agents/ also held the changelog
	[ "$d" = ".agents" ] && is_session_file "$d" CHANGELOG.md && printf '%s\n' "$d/CHANGELOG.md"
	return 0
}

# is <dir> a safe-code legacy session folder? (session files + a marker)
is_legacy_dir() { # is_legacy_dir <dir>
	local d="$1" f
	[ -d "$d" ] || return 1
	[ -n "$(safe_code_files "$d")" ] || return 1
	for f in "${MARKER_FILES[@]}"; do
		is_session_file "$d" "$f" && return 0
	done
	[ "$PROJECT_MARKER" -eq 1 ]
}

# safe-code's own files in the v3 root context/ (prints one path per line)
context_files() {
	local f
	for f in "${CONTEXT_FILES[@]}"; do
		has_file context "$f" && printf '%s\n' "context/$f"
	done
	[ -d context/feature-specs ] &&
		find context/feature-specs -mindepth 1 -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort
	return 0
}

# ---- find legacy locations that actually hold safe-code files -----------------
FOUND=()
AGENTS_DIR_LEGACY=0
for d in "${LEGACY_DIRS[@]}"; do
	if is_legacy_dir "$d"; then
		FOUND+=("$d")
		[ "$d" = ".agents" ] && AGENTS_DIR_LEGACY=1
	fi
done

# v3 root context/ counts as legacy only when safe-code managed it: the v3
# .gitignore entry, or progress-tracker.md inside it PLUS a project-level marker.
# A root context/progress-tracker.md alone is not enough — other tools use it.
V3_CONTEXT=0
if [ -d context ] && [ -n "$(context_files)" ] &&
	{ [ "$V3_GITIGNORE" -eq 1 ] ||
		{ has_file context progress-tracker.md && [ "$PROJECT_MARKER" -eq 1 ]; }; }; then
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
for d in ${FOUND[@]+"${FOUND[@]}"}; do
	echo "From $d"
	# only safe-code's own files; everything else (subagents, skills) stays
	ensure_dir .safe-code
	while IFS= read -r src; do
		move_file "$src" ".safe-code/$(basename "$src")"
	done < <(safe_code_files "$d")
	others="$(find "$d" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')"
	moving="$(safe_code_files "$d" | wc -l | tr -d ' ')"
	if [ "$APPLY" -eq 0 ] && [ "$((others - moving))" -gt 0 ]; then
		info "leaving $((others - moving)) other item(s) in $d untouched"
	fi
done

# v3 root context/ -> .safe-code/context/ (safe-code's named files only)
if [ "$V3_CONTEXT" -eq 1 ]; then
	echo "From context/ (v3 layout)"
	ensure_dir .safe-code/context
	while IFS= read -r src; do
		rel="${src#context/}"
		destdir=".safe-code/context/$(dirname "$rel")"
		[ "$(dirname "$rel")" = "." ] && destdir=".safe-code/context"
		ensure_dir "$destdir"
		move_file "$src" "$destdir/$(basename "$src")"
	done < <(context_files)
	others="$(find context -type f 2>/dev/null | wc -l | tr -d ' ')"
	moving="$(context_files | wc -l | tr -d ' ')"
	if [ "$APPLY" -eq 0 ] && [ "$((others - moving))" -gt 0 ]; then
		info "leaving $((others - moving)) other file(s) in context/ untouched"
	fi

	# v3 root CHANGELOG.md -> .safe-code/CHANGELOG.md — only with the v3 .gitignore
	# entry; a root CHANGELOG.md is otherwise the project's own release history
	if [ "$V3_GITIGNORE" -eq 1 ] && has_file . CHANGELOG.md; then
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
# Rewrite only references to what this run migrates: `context/` when the v3
# root context/ moved, and `.agents/<session file>` / bare `.agents/` when
# .agents/ was a safe-code folder. `.agents/skills/...` and other paths stay.
AGENTS_SED=""
AGENTS_GREP=""
if [ "$V3_CONTEXT" -eq 1 ]; then
	# only safe-code's named context files, feature-specs/, or bare `context/`
	CTX_RE='(project-overview|architecture|user-preferences|code-standards|ai-workflow-rules|ui-context|progress-tracker|current-issues)\.md|feature-specs/|`'
	AGENTS_SED="s#\`context/(${CTX_RE})#\`.safe-code/context/\\1#g;"
	AGENTS_GREP="\`context/(${CTX_RE})"
fi
if [ "$AGENTS_DIR_LEGACY" -eq 1 ]; then
	AGENTS_SED="${AGENTS_SED} s#\`\\.agents/((ACTIVE|SESSION|LOG|BACKLOG|MEMORY|safe-refactor-code|CHANGELOG)\\.md)?\`#\`.safe-code/\\1\`#g;"
	AGENTS_GREP="${AGENTS_GREP:+$AGENTS_GREP|}\`\\.agents/((ACTIVE|SESSION|LOG|BACKLOG|MEMORY|safe-refactor-code|CHANGELOG)\\.md)?\`"
fi
if [ -f AGENTS.md ] && [ -n "$AGENTS_GREP" ] && grep -qE "$AGENTS_GREP" AGENTS.md; then
	if [ "$APPLY" -eq 1 ]; then
		sed -i.safe-code.bak -E "$AGENTS_SED" AGENTS.md &&
			rm -f AGENTS.md.safe-code.bak
		pass "AGENTS.md: old context/ and .agents/ session-file references rewritten to .safe-code/"
	else
		info "would rewrite AGENTS.md context/ and .agents/ session-file references to .safe-code/"
	fi
else
	info "AGENTS.md: no old path references found"
fi
echo

# ---- clean up now-empty legacy folders (apply only) -------------------------
if [ "$APPLY" -eq 1 ]; then
	for d in ${FOUND[@]+"${FOUND[@]}"}; do
		if [ -d "$d" ] && [ -z "$(ls -A "$d" 2>/dev/null)" ]; then
			rmdir "$d" 2>/dev/null && info "removed empty $d"
			# remove now-empty parent (.codex, .claude, ...) if it has nothing left
			parent="$(dirname "$d")"
			if [ "$parent" != "." ] && [ -d "$parent" ] && [ -z "$(ls -A "$parent" 2>/dev/null)" ]; then
				rmdir "$parent" 2>/dev/null && info "removed empty $parent"
			fi
		elif [ -d "$d" ]; then
			info "kept $d (still has files — not safe-code's, or conflicting)"
		fi
	done
	if [ "$V3_CONTEXT" -eq 1 ] && [ -d context ]; then
		# remove only the folders safe-code created, and only when empty
		rmdir context/feature-specs 2>/dev/null
		rmdir context 2>/dev/null
		if [ -d context ]; then info "kept context/ (still has files)"; else info "removed empty context/"; fi
	fi
	echo
fi

# ---- summary ----------------------------------------------------------------
if [ "$APPLY" -eq 1 ]; then
	printf "Summary: %s%d moved%s, %s%d skipped%s\n" "$C_OK" "$MOVED" "$C_RST" "$C_ERR" "$SKIPPED" "$C_RST"
	if [ "$SKIPPED" -gt 0 ]; then
		warn "resolve conflicts above by merging the kept files into .safe-code/ manually"
	fi
	info "next: review changes, run 'bash $SCRIPT_DIR/check.sh', then commit"
else
	printf "Summary: %s%d to move%s, %s%d conflict(s)%s — re-run with --apply\n" \
		"$C_OK" "$MOVED" "$C_RST" "$C_ERR" "$SKIPPED" "$C_RST"
fi

[ "$SKIPPED" -gt 0 ] && exit 1
exit 0
