# Talk Track — output formats

Read by `/demo-rehearse` Step 3. Two formats; the spec's Demo Story names which.

Both formats share the header and the closing sections. Only the per-vignette body differs.

## Header (both formats)

```
# Talk Track — [Customer] — "[Story title]"

**Meeting:** [date] · **Format:** [outline | table] · **Budget:** [N] min
**Org:** [raw alias] · **Built from:** [changes-….md] · **Scout:** [SCOUT_VERSION] · **Pre-flight:** [date]
**Vignette status:** V1 V2 V5 green · V3 red (fallback) · V4 amber (see callouts)

**Residual message:** [one sentence — from the Value Spine]
**Protagonist:** [name — one clause] · **Perspective:** [whose screens]
```

## Outline format — per vignette

Prose narration, written to be spoken. Dialogue lines marked so the SE knows to shift voice.

```
## Vignette 1 — [What happens to the protagonist] (~[X] min)

**Screen:** [where the SE is when this starts — app, tab, record]

[Narration paragraph(s). Protagonist's world only; no product names in the narration.
Dialogue on its own line, marked:]

> 🗣 *Marisol:* "Actually — while I've got you…"
> 🗣 *Agent:* "That's a commercial job…"

**Click path:**
1. [Component / screen / action — actual API names or labels from the change log where the SE needs them]
2. …

**Payoff line** *(wow-moment vignettes only)*: [what the protagonist gets — said before any how]

**Callout** *(only if the SE is deliberately naming a product — e.g. the screen-pop moment)*: [the one sentence]

⚠️ **Before you rehearse** *(amber vignettes only)*: [unvalidated items from the change log and where to finish them]

**Transition →** [one sentence bridging to the next vignette's screen or persona]
```

For **red** vignettes, the narration is the Fallback scene, and the heading gets a suffix: `## Vignette 3 — [title] (~[X] min) — FALLBACK`. A one-line note under the heading says why: *"Topic-shift detection did not validate (change log: actions_unverified_in_preview). Fallback: Case 1 pre-exists, only Case 2 created live."*

## Table format — per vignette

Matches the Salesforce standard demo-script shape. One row per click or narration beat within the vignette. The SE adds screenshots during rehearsal.

```
## Vignette 1 — [What happens to the protagonist] (~[X] min)

| Product / Feature | Screen | Click Path | Script |
|---|---|---|---|
| — | Service Console › Home | — | [Narration — protagonist's world, no product names] |
| Agentforce Voice | AFV session panel | Accept inbound call | 🗣 *Agent:* "I'm texting you a link…" |
| Case | Console › Case list | Point to new Case row | [Narration] |
| … | … | … | … |

**Transition →** [one sentence]
```

Product / Feature column carries the product names; the Script column never does (except a deliberate callout, marked). Amber and red handling is the same as outline: a ⚠️ callout block under the table for amber, `— FALLBACK` suffix and reason line for red.

## Closing sections (both formats)

```
## Anticipated Questions

- **"[Question]"** — [Answer grounded in what actually deployed. If the original brief's answer relied on a capability that landed red, this is the rewritten answer.]
- …

## What's Not Real (for the SE's eyes)

[One bullet per hardcoded / simulated element, from the Stage-effect flags — so the SE never gets surprised by their own demo data. "Measuring-tool link goes to a static page." "Case 1 dates were set by the seed script to look like last Tuesday."]

## Still Yours To Do

[The SE Manual Checklist items and pre-flight UNKNOWN/FAIL items that the talk track assumes are done. Copy from the change log's SE Must Do Next + the pre-flight table; don't rewrite.]
```

Rehearsal actions append their own dated `## Rehearsal — [action] — [date]` sections after these, and `backup plans` appends `## Backup Plans`.
