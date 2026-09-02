# sf-demo-story

A story layer for [SF Demo Scout](https://github.com/seb-schi/sf-demo-scout). Scout audits the org, spars on scope, and deploys. This plugin handles what happens on either side of that: getting an approved, story-driven Demo Brief into Scout without re-interviewing you, and producing the talk track and rehearsal support after Scout builds.

It never modifies Scout. It reads Scout's command files at runtime and works inside Scout's workspace (`~/claude-projects/sf-demo-scout/orgs/`).

## What's in the box

| Path | What it is |
|---|---|
| `commands/demo-from-brief.md` | `/demo-from-brief <canvas-url>` — reads the Demo Brief Canvas, pre-answers Scout sparring from it, appends the story to Scout's spec |
| `commands/demo-rehearse.md` | `/demo-rehearse` — Service Cloud pre-flight, talk track from spec + change log, rehearsal actions |
| `prompts/brief-to-sparring-map.md` | How brief fields map onto sparring's questions. **The one file to edit when Scout changes.** |
| `prompts/service-cloud-preflight.md` | Telephony / routing / NBA / messaging / data-freshness checks Scout doesn't run |
| `prompts/talk-track-template.md` | Outline and table talk-track formats |
| `prompts/demo-story-spec-section.md` | The `## Demo Story` section appended to Scout's spec |
| `prompts/scout-resolve.md` | Finds Scout's install path, checks version, enters the workspace |
| `hooks/session-startup.sh` | Startup nudge: which customer folders have a brief but no spec, or a build but no talk track |
| `slack/demo-planner-SKILL.md` | The revised demo-planner Slackbot skill (vignette edition). Not loaded by Claude Code — it's here so the two halves version together. |

## One-time setup (plugin author)

1. Create a GitHub repo named `sf-demo-story` and push this folder to it.
2. Edit `.claude-plugin/marketplace.json` — replace `REPLACE-WITH-YOUR-GITHUB-USER` with your GitHub user or org.
3. Replace the demo-planner skill in your Slackbot configuration with `slack/demo-planner-SKILL.md`. The old skill's "next steps" message told SEs to paste into Cursor and run demo-build; the new one tells them to run `/demo-from-brief`. The build version format also changed (Story + Vignettes instead of Story Beats), and `/demo-from-brief` expects the new format.
4. Retire the old `demo-build` skill from Claude Code. Everything it did is now either Scout's job (scoping, build plan, deploy) or `/demo-rehearse`'s (talk track, rehearsal).

## One-time setup (each SE)

**Prerequisite:** Scout installed and set up. If not:

```
/plugin marketplace add https://github.com/seb-schi/sf-demo-scout.git
/plugin install sf-demo-scout@scout
/reload-plugins
/scout-setup
```

`/scout-setup` handles the Salesforce CLI, the SFDX workspace, and Slack MCP registration. sf-demo-story needs Slack MCP to read Canvases — if the SE skipped that in Scout setup, `/demo-from-brief` will say so and fall back to a pasted brief.

**Then install sf-demo-story:**

```
/plugin marketplace add https://github.com/<your-user>/sf-demo-story.git
/plugin install sf-demo-story@demo-story
/reload-plugins
```

Choose *Install for you (user scope)* when prompted. Verify with `/help` — `demo-from-brief` and `demo-rehearse` should be listed.

Updates pull automatically at session start, same as Scout.

## Running a demo, start to finish

**1. Slack — story.** Invoke demo-planner with the customer and meeting date. Approve the customer brief, iterate on the story and vignettes, approve. You get a Canvas. The sales team comments; you incorporate feedback. Copy the Canvas link.

**2. Claude Code, window 1 — sparring.** Open Claude Code in `~/claude-projects/sf-demo-scout` on Opus. Run:

```
/demo-from-brief https://salesforce.enterprise.slack.com/docs/.../F0XXXXXXXXX
```

Confirm the target SDO. The command saves the brief to the customer folder and hands off to Scout sparring with discovery pre-answered. You'll be asked two things Scout genuinely needs from you: which app and objects to anchor on (after the org audit finishes), and the cut gate. Scout runs its platform research and data-shape validation as normal and writes the spec, with the story appended.

**3. Claude Code, window 2 — building.** Fresh window, Opus. Run `/scout-building`. Approve the conflict check and the Phase 2 / Phase 3 gates. Scout deploys and gives you a handover brief. Do the UI-only Setup items it lists — for a voice demo that's AFCC, Omni-Channel routing, NBA on the page, channel connections.

**4. Claude Code — rehearsal.** Any window, Sonnet is fine. Run `/demo-rehearse`. It runs the Service Cloud pre-flight against the org, asks what to do about any failures, writes the talk track to the customer folder, and offers the rehearsal actions:

```
/demo-rehearse validate build
/demo-rehearse check timing
/demo-rehearse review transitions
/demo-rehearse simulate questions
/demo-rehearse refresh data
/demo-rehearse tighten vignette 3
/demo-rehearse backup plans
```

The week of the demo, `refresh data` regenerates the seed dates so "this morning" is still this morning.

**5. After.** Both commands propose lessons at the end, into Scout's `orgs/lessons/`. Story and talk-track lessons go to `demo-craft.md`, which demo-planner benefits from next time.

## The startup nudge

When you open Claude Code in the Scout workspace, the hook prints one line per customer folder that's mid-pipeline:

```
── sf-demo-story ──
Approved brief, no spec yet: memphis-sdo-binswanger → run /demo-from-brief
Built, no talk track yet: metro-cpq-metro → run /demo-rehearse
```

Silent when nothing's pending, silent outside the workspace.

## When Scout updates

Scout pulls updates automatically. sf-demo-story maps onto sparring by *intent* ("the question asking for the pain point") rather than position, so most Scout changes pass through. When they don't:

- `/demo-from-brief` prints a version-mismatch line at startup if Scout is newer than the version this plugin was verified against.
- If sparring asks something the pre-answers didn't cover, the command falls back to asking you — it never invents.
- To re-verify against a new Scout: run one demo end to end, then update `VERIFIED_SCOUT_VERSION` in `prompts/scout-resolve.md` and, if needed, the intent table in `prompts/brief-to-sparring-map.md`.

## Design notes

- **Why not fork Scout?** It's actively maintained by someone else and updates automatically. A companion that reads its files gets those updates for free; a fork doesn't.
- **Why keep the audit, Stage 4, 5b, and the cut gate?** The brief was approved by people who haven't seen the org. Sparring is the first contact between the story and the actual SDO. Its skepticism is the point of running it.
- **Why does the story live in the spec if Scout ignores it?** So `/demo-rehearse` finds the story next to the spec that was actually built, and so a second SE picking up the folder has both.
- **Why "vignette" and not "beat"?** A beat is a point in a feature sequence. A vignette is a moment in someone's day. The vocabulary shapes what gets written.
