---
name: demo-from-brief
description: >
  Take an approved Demo Brief (Slack Canvas link or local file) from the demo-planner
  Slackbot into SF Demo Scout sparring without re-interviewing the SE. Pre-answers
  Scout's discovery from the brief, seeds the Value Spine and scenario from the
  story and vignettes, and appends the Demo Story to Scout's spec so /demo-rehearse
  can write the talk track later. Usage: /demo-from-brief <canvas-url | path | blank>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, Agent, mcp__plugin_sf-demo-scout_Salesforce_DX__retrieve_metadata, mcp__plugin_sf-demo-scout_Salesforce_DX__run_soql_query, mcp__plugin_sf-demo-scout_Salesforce_DX__list_all_orgs, mcp__salesforce-docs__salesforce_docs_search, mcp__salesforce-docs__salesforce_docs_fetch, mcp__slack__slack_read_canvas, mcp__slack__slack_search_public_and_private, mcp__google-workspace__get_doc_as_markdown
---

# Demo From Brief — Story-first intake into Scout sparring

You are running Scout sparring with the interview already done. The SE and their sales team approved a Demo Brief in Slack; your job is to get that brief into a Scout spec with the least SE effort possible while keeping every check Scout runs against the actual org.

Argument: `$ARGUMENTS` — a Slack Canvas URL, a local file path, or empty.

This command is designed for Opus (Scout sparring's requirement). If the model is not Opus, emit Scout's standard line once: *"⚠️ This command is designed for Opus. Please run `/model` to switch if not on Opus."*

## Step 0: Resolve Scout and enter the workspace

Read `${CLAUDE_PLUGIN_ROOT}/prompts/scout-resolve.md` and follow it end-to-end. It sets `SCOUT_ROOT`, `SCOUT_VERSION`, and `cd`s into the Scout workspace. If it aborts, stop.

Then read `[SCOUT_ROOT]/prompts/lessons-bootstrap.md` and follow it, exactly as `/scout-sparring` would — the lessons files hold mistakes from prior sessions, including any `demo-craft.md` topic sf-demo-story users have been adding.

## Step 1: Confirm the target org

Run `sf config get target-org --json` and `sf org display --json`. Extract raw alias and username.

If no org is connected or auth expired: read `[SCOUT_ROOT]/prompts/switch-org.md` and follow it, exactly as Scout does.

Emit, then wait:

> "Active org: **[alias]** ([username]). This is the SDO the demo will be built in — right org, or **switch**?"

If the SE says switch, run `switch-org.md` again and re-confirm.

## Step 2: Acquire the Demo Brief

Branch on `$ARGUMENTS`:

**Slack Canvas URL** (contains `slack.com/docs/` or `slack.com/canvas/`): probe Slack MCP first — bash `claude mcp list 2>/dev/null | grep -qE '^slack:.*Connected' && echo OK || echo MISSING`. On MISSING: *"Slack MCP isn't connected, so I can't read the Canvas. Either run `/scout-setup` to register Slack, or paste the brief's 'For the build' section directly."* Wait. On OK: call `mcp__slack__slack_read_canvas` with the URL. From the returned content, extract the build version — everything from the line beginning `# Demo Brief:` to the end of the callout (the collapsible "For the build" section). Discard the sales-team top section; it's a summary of what the build version already contains.

**Local file path** (ends in `.md` or `.txt`, or the file exists): read it. If it contains both a top section and a `# Demo Brief:` build version, extract the build version as above.

**Empty**: ask once — *"Paste the Canvas link, a file path, or the brief's 'For the build' content."* Wait.

**Pasted content**: treat as the brief.

Validate the brief has the sections `brief-to-sparring-map.md` requires (Metadata, Customer Context, The Story, Vignettes). If any are missing, stop and say which, then offer: *"This brief predates the vignette edition of demo-planner. I can run plain `/scout-sparring` instead and you answer discovery normally — want that?"*

## Step 3: Resolve the customer folder and save the brief

Take the customer name from the brief's `# Demo Brief: [Customer] - "[Title]"` header. Read `[SCOUT_ROOT]/prompts/sparring/customer-normalization.md` and execute it — it derives `ORG_FOLDER = orgs/<slug(alias)>-<slug(customer)>/` and handles existing-folder matches (the SE may be reusing an SDO folder from a prior customer; let normalization ask).

Create `[ORG_FOLDER]` if new. Write the brief to `[ORG_FOLDER]/demo-brief.md`. If a `demo-brief.md` already exists, show the SE the two `Metadata → Meeting date` lines and ask whether to overwrite or keep both (rename the old one `demo-brief-[old date].md`).

Emit one line: *"Brief saved to `[ORG_FOLDER]/demo-brief.md`. Handing off to Scout sparring — I'll answer its discovery from the brief; you'll get the anchor-app question after the audit and the cut gate as normal."*

## Step 4: Load the mapping

Read `${CLAUDE_PLUGIN_ROOT}/prompts/brief-to-sparring-map.md` in full. Hold its tables in context — you'll consult them at each sparring stage.

## Step 5: Run Scout sparring with the brief in hand

Read `[SCOUT_ROOT]/commands/scout-sparring.md` in full and **execute its procedure from its Stage 1 onward**, with these overrides. Everything not listed here runs exactly as Scout wrote it.

**Stage 1 — Org setup and intent.** Already done in Steps 1 and 3. Do not re-ask for the org or the customer. Intent is **new** unless the brief's `Handoff Notes` or the customer-normalization step indicated a reused org, in which case intent is **reuse-org**. Skip sparring's opening menu.

**Stage 2 — Audit routing.** Run exactly as written. Let the audit run (background-fresh or reuse-if-recent per Scout's own 7-day rule). Do not skip it.

**Stage 3 — Discovery.** When sparring would emit its discovery-questions message, do not emit it to the SE. Instead, produce the pre-answer message per the map's "Discovery pre-answers" table — clearly labeled as drawn from the brief — and treat those as the SE's answers. The anchor-app question (the one that needs the audit's ★ items) is **not** pre-answerable: let it surface at sparring's join point and wait for the SE's real answer. Skip the named-source lookup offer (Slack canvas / Google Doc) — demo-planner already synthesized those; say so in one line.

Pass every vignette `Validation risk` marked HIGH or medium into Stage 4 as an explicit research item.

**Stage 4 — Platform research and knowledge cartridge.** Run exactly as written, plus the risk items above.

**Stage 5 — Value Spine.** Pre-fill from the map's "Value Spine pre-fill" table. Present it to the SE in sparring's standard spine format, with one added line at the top: *"Pre-filled from the brief's business case — sparring's own read is below where it differs."* If sparring's independent draft differs materially from the pre-fill, show both and let the SE pick. Gaps stay gaps; never invent KP2.

**Stage 5 — Scenario proposal.** Seed from the map's "Scenario seed" table. Then let sparring do what it does: existing-first evaluation against the audit, challenge components without a KP cite, external-skills offer if relevant, and the **mandatory cut gate**. The SE answers the cut gate themselves. If the brief marked vignettes as hardcoded or light-touch, mention them as natural cut candidates when the SE hesitates.

**Stage 5b — Data shape.** Run exactly as written.

**Stage 6 — Spec.** Let sparring write the spec per Scout's template. Then append the Demo Story section per the map's "Spec write" instructions (read `${CLAUDE_PLUGIN_ROOT}/prompts/demo-story-spec-section.md`). Update any vignette whose build changed during sparring, and record those in `Sparring adjustments`. Add the `Source brief` line to Customer Context. Let sparring's living-architecture-doc and lessons steps run as written.

**Done.** Emit sparring's closing message as written, then add:

> "Next: `/scout-building` in a fresh window. When the build is done and you've cleared the UI-only items in its handover brief, run `/demo-rehearse` here for the talk track and rehearsal."

## Rules

- **Never modify anything under `[SCOUT_ROOT]`.** You read Scout's files; you write only to `[ORG_FOLDER]`.
- **Never skip the audit, Stage 4, Stage 5b, or the cut gate.** The brief was approved by people who haven't seen the org. Sparring's skepticism is the first contact between story and SDO; that is the value of running it.
- **Never invent an answer the brief doesn't contain.** If sparring asks something the map doesn't cover and the brief doesn't answer, ask the SE.
- **Never spawn `/scout-building`.** Scout's own rule: it runs top-level in a fresh session.
- **Attribute.** Every pre-answer is labeled as coming from the brief so the SE knows what to correct.
- If sparring behaves in a way this command doesn't anticipate (a new stage, a reordered question), follow sparring. It is the source of truth for its own procedure; this command only supplies answers.
