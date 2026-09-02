# Brief → Sparring Map

Read by `/demo-from-brief` after the Demo Brief is on disk. Defines how the brief's fields pre-answer Scout sparring, and what sparring must still ask.

**Design rule: match by intent, not by number.** Scout's sparring stages are maintained by someone else and get reordered. This file describes *what a sparring question is asking for* and *which brief field answers it*. When executing sparring, recognize each question by its intent and substitute the mapped answer. If sparring asks something this file doesn't cover, answer it from the brief if the information is there, otherwise ask the SE — never invent.

## Source: the Demo Brief on disk

`[ORG_FOLDER]/demo-brief.md` — the build-version callout from the demo-planner Canvas. Expected sections (from the demo-planner skill, vignette edition):

- `## Metadata` — SE, meeting date, talk track format, Service Cloud base, supplementary capabilities, voice flags, references
- `## Customer Context` — industry, footprint, stakeholders, drivers, plus `### World details`
- `## Opportunity Context` — stage, amount, close, products, AE
- `## The Story` — Layer 1 prose + Protagonist / Perspective / Business case / Time budget
- `## Vignettes` — one `### Vignette N:` block each with Scene / On screen / Product(s) / Capability mapping / Stage-effect / Validation risk / Fallback scene / Wow moment
- `## Draft Objections`
- `## Scope Boundaries`
- `## Talk Track Format Preference`
- `## Handoff Notes`

If a required section is missing (no Story, no Vignettes, no Customer Context), stop and tell the SE which — the brief probably wasn't regenerated under the vignette edition of demo-planner. Offer to proceed with plain sparring instead.

## Discovery pre-answers (sparring Stage 3 intent → brief field)

| Sparring asks for… | Answer from the brief |
|---|---|
| The single most compelling pain point, ideally in the customer's words | `Customer Context` → known pain points. Prefer any quoted line. If the brief's business case names a number (e.g. "6,000 low-dollar calls/month"), include it. |
| Which Salesforce clouds / industry cloud | `Metadata` → Service Cloud base + supplementary capabilities. State "Service Cloud" explicitly; name AFCC / Agentforce Voice if the voice flags are yes. |
| The customer's definition of success / a 12-month metric | `The Story` → Business case line, plus any metric in `Customer Context` drivers. If none is numeric, say so — sparring's Value Spine marks KP2 as a gap, which is correct. |
| Which stakeholder's reaction matters most | `Customer Context` → stakeholders. Name the person the brief treats as the decision-maker or skeptic (in the Binswanger brief: Fred). Give their posture in one clause. |
| Which existing app and objects from the audit should anchor the demo | **Cannot be pre-answered.** This needs the org audit. Let sparring ask it at its join point; the SE answers it live. You may add context: "the brief's vignettes run on Case, Contact, and the service console — anchor on whatever app the audit ★-flags for those." |
| Any specific Salesforce feature to showcase | Union of every vignette's `Product(s) featured` and `Capability mapping`, deduplicated, plus anything in `Scope Boundaries → In scope`. |
| Setup canvas / Google Doc to look up; what flavor of demo org | Canvas: none — the brief already synthesized Slack and Drive context in demo-planner; say so, so sparring doesn't re-read them. Org flavor: from `Handoff Notes` if stated; otherwise ask the SE. |

Deliver the pre-answers as **one message from the SE's side of the conversation** — i.e. when sparring emits its discovery-questions message, respond on the SE's behalf in the SE's voice, stating up front: *"Pre-answered from the approved Demo Brief at `[ORG_FOLDER]/demo-brief.md` — correct anything that's off."* Then the deferred anchor-app question falls to the SE as normal.

**Do not skip the audit.** The audit is Scout inspecting the actual SDO. The brief knows nothing about the org.

**Do not skip platform research or data-shape validation.** These are where "the story assumes Case has a writable field that this SDO doesn't expose" gets caught before the build. The brief's vignettes carry `Validation risk` lines — pass every `HIGH` or `medium` risk into Stage 4 as an explicit research item ("confirm via Salesforce Docs whether mid-call topic-shift escalation is supported in Agentforce Voice on AFCC").

## Value Spine pre-fill (sparring Stage 5)

When sparring drafts its Value Spine, supply a pre-fill and let it show the SE both if they differ:

| Spine slot | From the brief |
|---|---|
| Residual Message | `The Story` → the closing business-case sentence, rewritten as the one thing the room remembers. Product-agnostic (no Salesforce product names — the spine is approach-level). |
| Audience | The stakeholder named above. |
| KP1 — Pain | The pain point pre-answer, in the customer's words if quoted. |
| KP2 — Cost of Inaction | Any cost/volume/time figure in the brief. If none, leave the slot empty — sparring surfaces it as a gap. Never invent. |
| KP3 — Future State | The story's ending, as contrast with KP1. |

## Scenario seed (sparring Stage 5 proposal)

Sparring proposes exactly one scenario. Seed it from the brief rather than letting it start cold:

- **Name:** the brief's story title (from `# Demo Brief: [Customer] - "[Title]"`).
- **Business story (2 sentences):** compress `The Story` — protagonist, what happens, what it proves.
- **Core capability:** the vignette with the wow moment, or the one whose `Stage-effect flag` is dynamic and load-bearing.
- **Pain point addressed:** KP1.
- **What must be built:** the union of vignette `Capability mapping` lines that the audit shows as absent. This is sparring's existing-first evaluation doing its job — expect it to find that a reused SDO already has half of it.
- **`Proves: KP[n]` tags:** map each gated build category to the vignette that needs it and that vignette's role in the story. If a component doesn't serve any vignette, sparring will challenge it — that is the correct outcome.
- **Demo risk:** every vignette `Validation risk` that is not `none`, verbatim, plus the `Handoff Notes` top build risks.

Sparring will push back, challenge scope, and run the cut gate. **Let it.** The brief was approved in Slack by people who haven't seen the org. Sparring is the first contact between the story and the actual SDO, and its skepticism is the point.

## Cut gate

Unchanged. The SE answers "what would you cut, and which customer statement says the rest is essential" themselves. You may remind them which vignettes the brief marked as light-touch or hardcoded — those are the natural cuts.

## Spec write (sparring Stage 6)

After sparring writes `[ORG_FOLDER]/demo-spec-[...].md` per Scout's template, **append** the Demo Story section. Read `${CLAUDE_PLUGIN_ROOT}/prompts/demo-story-spec-section.md` for the format. Insert it immediately after Scout's `## Scenario: [Name]` section and before `## Claude Code Instructions`.

Scout's build sub-agents read only `## Claude Code Instructions` onward, so this section is invisible to the build and cannot affect it. It exists so `/demo-rehearse` has the story next to the spec that was actually built.

Also add one line to the spec's `## Customer Context`:

```
- **Source brief:** demo-brief.md (demo-planner, [Canvas URL or "pasted"], approved [date if known])
```

## After the spec

Sparring's own closing message tells the SE to open a fresh window for `/scout-building`. Add one line after it:

> "After `/scout-building` finishes and you've done the UI-only setup in its handover brief, run `/demo-rehearse` in this folder for the talk track and rehearsal."
