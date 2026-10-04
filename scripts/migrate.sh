#!/usr/bin/env bash
# Shim: migrate.sh ships inside the skill so `npx skills add` installs it.
exec bash "$(dirname "$0")/../skills/safe-code/scripts/migrate.sh" "$@"
