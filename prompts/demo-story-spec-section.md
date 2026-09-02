# Demo Story — spec section template

Appended to Scout's `demo-spec-*.md` by `/demo-from-brief` (after `## Scenario`, before `## Claude Code Instructions`). Read by `/demo-rehearse`. Ignored by Scout's build sub-agents.

Copy the content from `[ORG_FOLDER]/demo-brief.md` — do not rewrite the prose. The one thing to update: for every vignette whose `Capability mapping` the sparring session changed (a component cut at the cut gate, a field renamed after data-shape validation, a capability the audit showed already exists), update that vignette's `On screen` and `Capability mapping` lines to match the spec's Claude Code Instructions, and note the change in `Sparring adjustments`.

```
## Demo Story

**Source:** demo-brief.md ([Canvas URL or "pasted"])
**Talk track format:** [outline | table]
**Time budget:** [N] min across [N] vignettes

### The Story

[Layer 1 prose, verbatim from the brief. No product names.]

- **Protagonist:** [name, who they are to the customer, situation, stake, why-now]
- **Perspective:** [whose screens the audience watches, per vignette if it changes]
- **Business case:** [one sentence]

### Vignettes

#### Vignette 1: [What happens to the protagonist] (~[X] min)
- Scene: [verbatim from brief]
- On screen: [from brief, updated if sparring changed the build]
- Product(s) featured: [...]
- Capability mapping: [from brief, updated to match spec's Claude Code Instructions]
- Stage-effect flag: [dynamic | hardcoded | hybrid — notes]
- Validation risk: [none | description]
- Fallback scene: [only if validation risk exists]
- Wow moment: [if this vignette holds it]

#### Vignette 2: ...

### Draft Objections
[verbatim from brief]

### Sparring adjustments
[One bullet per change sparring made that affects a vignette — "Vignette 4 NBA recommendation cut at cut gate; On screen now shows transcript + case only." Write "None" if the story survived sparring unchanged.]
```
