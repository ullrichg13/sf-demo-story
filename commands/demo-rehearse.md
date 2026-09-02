---
name: demo-rehearse
description: >
  After /scout-building has deployed a demo, produce the talk track and rehearsal
  support. Runs a Service Cloud / voice pre-flight against the org, merges the spec's
  Demo Story with what Scout actually deployed (using fallback scenes where the build
  didn't validate), writes the talk track in the SE's chosen format, then offers
  on-demand rehearsal: validate build, check timing, review transitions, simulate
  customer questions, refresh demo data, tighten a vignette, build backup plans.
  Usage: /demo-rehearse [action]
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, mcp__plugin_sf-demo-scout_Salesforce_DX__retrieve_metadata, mcp__plugin_sf-demo-scout_Salesforce_DX__run_soql_query, mcp__slack__slack_create_canvas
---

# Demo Rehearse — Talk track and rehearsal after the build

Scout built the demo. Scout does not know what the SE is going to *say*. This command turns the spec's Demo Story plus Scout's change log into a talk track the SE can rehearse against, and then helps them rehearse.

Argument: `$ARGUMENTS` — empty (full run: pre-flight → talk track → offer actions) or one of the rehearsal action names below to jump straight to it.

This command works fine on Sonnet. Do not emit a model gate.

## Step 0: Resolve Scout and enter the workspace

Read `${CLAUDE_PLUGIN_ROOT}/prompts/scout-resolve.md` and follow it. Then read `[SCOUT_ROOT]/prompts/lessons-bootstrap.md` and follow it — load the `demo-craft.md` topic if it exists, plus whatever topics match the spec's component classes.

## Step 1: Identify the customer folder and load inputs

Run `sf config get target-org --json`. Slugify the alias per `[SCOUT_ROOT]/prompts/sparring/slug-rule.md`. List `orgs/<slug(alias)>-*/`. One folder → use it and say so. Multiple → ask. None → *"No customer folders for this org. Run `/demo-from-brief` and `/scout-building` first."* Stop.

Set `ORG_FOLDER`. Load, in this order:

1. **Spec** — latest `[ORG_FOLDER]/demo-spec-*.md`. Read the `## Demo Story` section in full (this is the story layer `/demo-from-brief` appended), the `## Scenario` section, and the `## SE Manual Checklist`. If there is no `## Demo Story` section: *"This spec has no Demo Story section — it was written by plain `/scout-sparring`, not `/demo-from-brief`. I can still write a talk track from the Scenario section, but it'll be capability-shaped rather than story-shaped. Proceed, or paste the brief's story so I can use it?"* Wait.
2. **Change log** — latest `[ORG_FOLDER]/changes-*.md`. Extract: what deployed, what was skipped, everything in *Issues Encountered*, anything marked `Draft`, `test-unvalidated`, `deployed but NOT validated`, `NeedsUICommit`, `actions_unverified_in_preview`, and the *SE Must Do Next* list. If no change log exists: *"No change log — `/scout-building` hasn't run. Run it first."* Stop.
3. **Living architecture doc** — `[ORG_FOLDER]/demo-architecture.md` if present, for the running picture of what's in the org across iterations.
4. **Prior talk track** — latest `[ORG_FOLDER]/talk-track-*.md` if present. If one exists and `$ARGUMENTS` is empty, ask: *"There's a talk track from [date]. Regenerate from the current build, or jump to a rehearsal action on the existing one?"*

Build a **vignette status map**: for each vignette in the Demo Story, list its `Capability mapping` components and mark each one from the change log as `deployed+validated`, `deployed-unvalidated`, `draft`, `skipped`, or `manual` (in SE Manual Checklist). A vignette is **green** if every load-bearing component is validated or manual-and-SE-confirmed; **amber** if any is unvalidated or draft; **red** if any is skipped or failed.

## Step 2: Service Cloud pre-flight

Read `${CLAUDE_PLUGIN_ROOT}/prompts/service-cloud-preflight.md` and execute it against the org, running only the checks the Demo Story's vignettes need. Present the results table. Ask its closing question and wait.

Merge the answer into the vignette status map: a FAIL on a load-bearing component makes that vignette amber (SE will fix) or red (fallback scene will be used), per the SE's answer.

Skip this step when `$ARGUMENTS` names a rehearsal action and a talk track already exists.

## Step 3: Write the talk track

Read `${CLAUDE_PLUGIN_ROOT}/prompts/talk-track-template.md` for the format matching the spec's `Talk track format` (outline or table).

For each vignette:

- **Green:** use the `Scene` as the narration and `On screen` as the click path. Name the actual components that deployed (from the change log) so the SE knows what they're clicking.
- **Amber:** use the `Scene`, but add a *"Before you rehearse"* callout listing the unvalidated items and where the change log says to finish them (Scout's "Built — Validate in Sonnet" list). The talk track assumes the SE will clear them; if they don't, the fallback applies.
- **Red:** use the `Fallback scene` as the narration. If the vignette has no fallback scene, write one now in the same voice as the Scene, and flag it: *"No fallback was written for this vignette in the brief — drafted one; review it."* Never narrate a capability the change log says didn't validate.

Rules for the narration:

- The story is spoken; the product is shown. Narration stays in the protagonist's world and never names a Salesforce product unless the SE is deliberately naming it as a callout (e.g. the Binswanger screen-pop moment). Product names live in the click path column / line.
- Keep every line of dialogue from the Scene. Those lines are what the SE says *as* the protagonist or the agent; mark them so the SE knows to shift voice.
- Add a **transition line** at the end of each vignette that bridges to the next screen or persona, since the SE will be navigating while talking.
- Add the wow-moment vignette's **payoff line** — what the protagonist gets — before any explanation of how.
- Carry the **Draft Objections** into an *Anticipated Questions* section, and for each, check the answer against the actual build. An objection answered with a capability that landed red gets rewritten.

Header the talk track with: customer, meeting date, format, target org alias, `SCOUT_VERSION`, the change log filename it was built from, the pre-flight date, and a one-line **vignette status summary** (e.g. "V1 V2 V5 green · V3 red (fallback) · V4 amber (NBA component on page unconfirmed)").

Save to `[ORG_FOLDER]/talk-track-[YYYY-MM-DD]-[HHmm].md`. Tell the SE the path.

Offer the Slack canvas: probe Slack MCP; if connected, *"Write this talk track to a Slack canvas? (y/n)"* On y, `slack_create_canvas` with title `Talk Track — [Customer] — [date]`.

Then: *"Talk track saved. Rehearsal actions available — say any of: **validate build**, **check timing**, **review transitions**, **simulate questions**, **refresh data**, **tighten vignette N**, **backup plans**."*

## Step 4: Rehearsal actions (on demand)

Each action reads the current talk track and the change log. Each writes its output back into the talk track file under a dated `## Rehearsal — [action] — [date]` section unless noted.

### validate build

Walk each vignette's click path against the org, read-only: query the seeded records the Scene names (protagonist's Contact/Account/Case), confirm the components the click path names exist and are active (flow `ActiveVersionId`, agent `Status`, permission set assigned to the demo user), and confirm any hardcoded values the Stage-effect flag calls out are actually present on the records. Output pass/fail per vignette plus specific fixes. Where a fix is a build change, point the SE to Scout's quick-tweak door (tell Claude in the building session) rather than doing it here — this command is read-only against the org.

### check timing

Per vignette: narration word count at ~150 words/min + ~4 sec per click in the click path + ~5 sec per major navigation. Total against the Demo Story's time budget. Name the longest and shortest vignettes. Over budget → propose specific sentence and click cuts. Under → propose where to slow down on the payoff.

### review transitions

Read end-to-end. Flag: end-state of one vignette vs start-state of the next (screen, persona, time of day), missing bridge narration, repeated phrasing across vignettes, references to things not yet established. Propose bridge language per transition. Story continuity matters here — if Vignette 2 says "Tuesday morning" and Vignette 5 says "later that day," check the seeded dates agree.

### simulate questions

Take the Anticipated Questions. For each: is the answer grounded in what actually deployed (not the sales-side framing)? Then generate 3–5 more a skeptical attendee would ask based on the build — especially anything that would expose a hardcoded value or a fallback scene. Draft answers for gaps. The SE may name a persona (*"be Fred — technical CIO, builds his own agents, hates being oversold"*); stay in that voice for the exchange.

### refresh data

Scan the spec's Data Seeding section and the seeded records for date fields. Compare to today and to what each Scene implies ("this morning," "last week"). Produce `[ORG_FOLDER]/scripts/refresh-data-[date].apex` that resets dates relative to today, preserving the story's relative timeline (Case 1 is still older than Case 2 by the same gap). Do not run it — output the `sf apex run --file` command for the SE, following Scout's convention that data mutations are the SE's to execute. If Scout's change log lists a reusable seed script with a bulk path, prefer pointing the SE at that.

### tighten vignette N

The SE describes what dragged. Respond with targeted fixes across four layers: narration (cut filler, sharpen the payoff line), click path (skip a navigation, pre-set a tab), stage effect (hardcode something dynamic that's unreliable — and update the Stage-effect flag), and build (a prompt-template tweak, pre-loaded data — route to Scout's quick-tweak door). Rewrite that vignette in the talk track in place; note the change in a dated rehearsal section.

### backup plans

For every amber or red vignette and every wow moment: what the SE says if the AI response doesn't fire, if the page is slow, if a customer asks for something outside the demo, if a hardcoded value looks wrong on screen. Write them in the story's voice — a recovery line should sound like the SE is still telling Marisol's story, not apologizing for software. Append as `## Backup Plans` organized by vignette.

## Step 5: Lessons

At the end of the session, if anything was learned that would change how demo-planner writes a story or a fallback (a capability that never validates in SDOs, a Scene structure that timed badly, a stage-effect decision that saved the vignette), propose it as a lesson for `orgs/lessons/demo-craft.md` following `[SCOUT_ROOT]/prompts/lessons-maintenance.md`'s append format. If `demo-craft.md` doesn't exist, propose creating it with the INDEX line *"demo-craft.md — story, vignette, and talk-track lessons: what validates in SDOs, what times well, which fallbacks worked"*. SE-gated, as Scout's lessons are.

## Closing

Remind the SE, once: the technical foundation is checked. The live polish — delivery, pace, silence in the right places — is human work. One out-loud rehearsal with a colleague watching catches what none of these actions can.
