# Scout Resolve — locate SF Demo Scout, check version, enter workspace

Read by `/demo-from-brief` and `/demo-rehearse` as their first step. sf-demo-story is a companion to SF Demo Scout: it reads Scout's command and prompt files at runtime and works inside Scout's workspace, but never modifies anything under Scout's plugin directory.

## Step 1: Find Scout's install path

Run this Bash. It reads Claude Code's installed-plugins registry — the same method Scout's own fragments use to resolve `PLUGIN_ROOT_ABS` for sub-agents.

```bash
python3 - << 'PY'
import json, os, sys
p = os.path.expanduser('~/.claude/plugins/installed_plugins.json')
try:
    d = json.load(open(p))
except Exception as e:
    print("SCOUT_STATE=NOT_INSTALLED"); sys.exit(0)
entries = d.get('plugins', {}).get('sf-demo-scout@scout')
if not entries:
    print("SCOUT_STATE=NOT_INSTALLED"); sys.exit(0)
e = next((x for x in entries if x.get('scope') == 'user'), entries[0])
root = e['installPath']
ver = "unknown"
try:
    ver = json.load(open(os.path.join(root, '.claude-plugin', 'plugin.json'))).get('version', 'unknown')
except Exception:
    pass
print(f"SCOUT_STATE=OK")
print(f"SCOUT_ROOT={root}")
print(f"SCOUT_VERSION={ver}")
PY
```

Branch on output:

- `SCOUT_STATE=NOT_INSTALLED` → ABORT the parent command and emit:

  > "sf-demo-story rides on SF Demo Scout, which isn't installed. Install Scout first:
  > ```
  > /plugin marketplace add https://github.com/seb-schi/sf-demo-scout.git
  > /plugin install sf-demo-scout@scout
  > /reload-plugins
  > /scout-setup
  > ```
  > Then re-run this command."

- `SCOUT_STATE=OK` → record `SCOUT_ROOT` and `SCOUT_VERSION` for the session. Continue.

## Step 2: Version compatibility check

sf-demo-story reads Scout's sparring stages by *intent* (the question that asks for the pain point, the step that drafts the Value Spine), not by line number, so minor Scout updates usually pass through unnoticed. But Scout auto-updates and this plugin is tested against a specific version.

```
VERIFIED_SCOUT_VERSION = 2026.09.01-adopt-cmdt-custom-setting
```

Compare `SCOUT_VERSION` to `VERIFIED_SCOUT_VERSION` (string compare on the leading `YYYY.MM.DD` date portion):

- Equal → silent.
- Scout is newer → emit one line and continue:

  > "ℹ️ Scout is at `[SCOUT_VERSION]`; sf-demo-story was last verified against `[VERIFIED_SCOUT_VERSION]`. If sparring asks something unexpected or skips a step described here, that's why — answer it normally and tell the sf-demo-story maintainer."

- Scout is older → emit one line and continue:

  > "ℹ️ Scout is at `[SCOUT_VERSION]`, older than the version sf-demo-story expects. Run `/plugin marketplace update scout` when convenient."

Never abort on a version mismatch. The intent-based mapping is designed to degrade gracefully.

## Step 3: Enter the Scout workspace

Read `[SCOUT_ROOT]/prompts/workspace-bootstrap.md` and follow it. It `cd`s into `~/claude-projects/sf-demo-scout` and aborts cleanly if Scout hasn't been set up (`/scout-setup` not yet run). If it aborts, abort the parent command with its message.

After this step, all `orgs/...` paths resolve against the workspace, exactly as they do for Scout's own commands.

## Values carried forward

- `SCOUT_ROOT` — absolute path; use it for every `[SCOUT_ROOT]/...` reference in the parent command. Do NOT use `${CLAUDE_PLUGIN_ROOT}` for Scout paths — that variable resolves to sf-demo-story's own root, not Scout's.
- `SCOUT_VERSION` — for the change log / talk-track header.
- `${CLAUDE_PLUGIN_ROOT}` — sf-demo-story's own root; use it for this plugin's `prompts/` files.
