#!/bin/bash
# sf-demo-story — session startup nudge.
# Runs on every Claude Code SessionStart. Stays silent outside the Scout
# workspace and does no network calls, so it costs nothing on launch.
# Only local filesystem checks: which customer folders are mid-pipeline.

SCOUT_WORKSPACE="${SCOUT_WORKSPACE:-$HOME/claude-projects/sf-demo-scout}"
if [ "$PWD" != "$SCOUT_WORKSPACE" ]; then
  exit 0
fi
[ -d orgs ] || exit 0

NEED_SPARRING=""
NEED_REHEARSE=""

for dir in orgs/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  [ "$name" = "lessons" ] && continue

  has_brief=$(ls "$dir"demo-brief.md 2>/dev/null | head -1)
  has_spec=$(ls "$dir"demo-spec-*.md 2>/dev/null | head -1)
  has_changes=$(ls "$dir"changes-*.md 2>/dev/null | head -1)
  has_track=$(ls "$dir"talk-track-*.md 2>/dev/null | head -1)

  if [ -n "$has_brief" ] && [ -z "$has_spec" ]; then
    NEED_SPARRING="$NEED_SPARRING $name"
  elif [ -n "$has_changes" ] && [ -z "$has_track" ]; then
    NEED_REHEARSE="$NEED_REHEARSE $name"
  fi
done

if [ -n "$NEED_SPARRING" ] || [ -n "$NEED_REHEARSE" ]; then
  echo "── sf-demo-story ──"
  [ -n "$NEED_SPARRING" ] && echo "Approved brief, no spec yet:$NEED_SPARRING → run /demo-from-brief"
  [ -n "$NEED_REHEARSE" ] && echo "Built, no talk track yet:$NEED_REHEARSE → run /demo-rehearse"
fi
exit 0
