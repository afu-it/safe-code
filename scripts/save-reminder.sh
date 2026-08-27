#!/usr/bin/env bash
# Shim: the reminder ships inside the skill so `npx skills add` installs it.
exec bash "$(dirname "$0")/../skills/safe-code/scripts/save-reminder.sh" "$@"
