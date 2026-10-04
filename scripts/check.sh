#!/usr/bin/env bash
# Shim: check.sh ships inside the skill so `npx skills add` installs it.
exec bash "$(dirname "$0")/../skills/safe-code/scripts/check.sh" "$@"
