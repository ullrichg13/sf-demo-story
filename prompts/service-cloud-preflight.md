# Service Cloud Pre-flight

Read by `/demo-rehearse` before writing the talk track. Scout builds what the Metadata API can reach and routes everything else to the SE Manual Checklist. Most of Service Cloud's runtime surface — telephony, routing, presence, messaging — is UI-configured, so a Scout build can report green while the demo cannot take a call. This pre-flight checks the things a Service Cloud / voice demo depends on that Scout will not have verified.

Run only the checks relevant to the spec's Demo Story. If no vignette uses voice, skip the voice checks. Read-only throughout: SOQL and metadata retrieve only, never a write.

## How to run each check

Use MCP `run_soql_query` and `retrieve_metadata` where available; fall back to `sf data query --target-org [RAW_ALIAS]` and `sf project retrieve start`. Every check has three outcomes:

- **PASS** — the org has what the vignette needs.
- **FAIL** — the org demonstrably lacks it.
- **UNKNOWN** — the query errored or the object isn't exposed in this org. Do NOT treat unknown as pass. Route to the SE as "confirm in Setup: [path]".

Report as a table: check, outcome, what to do if not PASS.

## Checks

### Voice (only if any vignette features Agentforce Voice, Service Cloud Voice, or a live call)

**V1 — Telephony provisioned.** Agentforce Voice requires the native AFCC / Amazon Connect path, not BYOT. Query:
```
SELECT Id, InternalName, Name FROM CallCenter
```
A CallCenter whose InternalName indicates Amazon Connect / Service Cloud Voice (typically containing `SCV`, `Amazon`, or the partner telephony name) → PASS. Only BYOT / OpenCTI-style call centers → FAIL. No rows → FAIL. This cannot be fixed day-of; if FAIL, the voice vignettes need a different org or a recorded fallback. Setup path if UNKNOWN: Setup → Call Centers.

**V2 — Voice channel and vendor.** Query:
```
SELECT Id, DeveloperName, VendorType FROM ConversationVendorInfo
```
Rows present → PASS. Object not queryable → UNKNOWN (Setup → Partner Telephony / Amazon Connect).

**V3 — Agent assigned to the call center.** Query:
```
SELECT Id, Username, CallCenterId FROM User WHERE Username = '[demo username from spec]'
```
`CallCenterId` non-null → PASS. Null → FAIL (Setup → Call Centers → Manage Call Center Users).

**V4 — Agentforce Voice agent active.** For each Agentforce agent named in a voice vignette:
```
SELECT DeveloperName, Status, AgentType FROM BotDefinition WHERE DeveloperName = '[agent api name]'
```
`Status = 'Active'` → PASS. Anything else → FAIL. Cross-check Scout's change log: if the log says `NeedsUICommit` or `deployed but NOT validated`, carry that forward regardless of status — an Active agent whose hero action never fired is not demo-ready.

### Routing (if any vignette escalates to a rep, routes a work item, or shows Omni-Channel)

**R1 — Service channels.** Query:
```
SELECT DeveloperName, RelatedEntity FROM ServiceChannel
```
A channel for the object the vignette routes (Case, MessagingSession, VoiceCall) → PASS.

**R2 — Queue routing config.** Query:
```
SELECT DeveloperName, RoutingModel, CapacityWeight FROM QueueRoutingConfig
```
At least one config → PASS. Then confirm the demo queue uses it:
```
SELECT Id, DeveloperName, QueueRoutingConfigId FROM Group WHERE Type = 'Queue' AND DeveloperName = '[queue from spec]'
```
`QueueRoutingConfigId` non-null → PASS.

**R3 — Presence.** Query:
```
SELECT DeveloperName FROM PresenceUserConfig
SELECT DeveloperName FROM ServicePresenceStatus
```
Both non-empty → PASS. The rep user must also be assigned to a PresenceUserConfig — check `PresenceUserConfigUser` for the demo rep's user id.

### Recommendations (if any vignette features Next Best Action or an Agentforce recommendation on the rep console)

**N1 — Strategy exists.** Retrieve `RecommendationStrategy` metadata (`retrieve_metadata` type `RecommendationStrategy`). A strategy whose name matches the spec → PASS. Scout may have built this; confirm it appears in the change log as deployed.

**N2 — Recommendations seeded.** Query:
```
SELECT Id, Name, ActionReference FROM Recommendation
```
At least one row the strategy can surface → PASS. Empty → FAIL (the strategy will render nothing on the console).

**N3 — Component on the page.** NBA renders only if the Einstein Next Best Action component is on the record page the vignette shows. This is App Builder, UI-only. Mark UNKNOWN and route to the SE: "confirm the NBA component is on the [object] record page used in Vignette [N]."

### Messaging (if any vignette uses chat, SMS, WhatsApp, or Messaging for In-App and Web)

**M1 — Channel active.** Query:
```
SELECT DeveloperName, MessageType, IsActive FROM MessagingChannel
```
Active channel of the right type → PASS.

**M2 — Agent connected to channel.** Agentforce channel assignment is docs-confirmed UI-only (Scout's CLAUDE.md says so). Mark UNKNOWN and route to the SE: "confirm [agent] is connected to [channel] in Agentforce Builder → Connections."

### Console and wrap-up (if any vignette shows the service console, call wrap-up, or case summaries)

**C1 — Console app.** Query:
```
SELECT DeveloperName, Label, NavType FROM AppDefinition WHERE NavType = 'Console'
```
The app the spec's `Primary build surface` names → PASS.

**C2 — Wrap-up / summary generation enabled.** No reliable metadata signal. Mark UNKNOWN; route to the SE: "confirm Einstein Work Summaries / Call Summary is enabled (Setup → Einstein for Service)."

### Data freshness (always)

**D1 — Date drift.** For every seeded record the spec's Data Seeding section lists with a date field (case opened, activity date, last modified), query the actual value and compare to today. Anything the story describes as recent ("this morning", "last week") that is now older than the story implies → FAIL with the delta. This feeds the talk track: either the SE runs a refresh script before the demo, or the Scene wording changes to match the real dates.

**D2 — Protagonist records present.** Query the Contact / Account / Case records for the story's named people (from the Demo Story's Protagonist line). All present → PASS. This is the check that catches "the SDO was re-spun and Marisol doesn't exist anymore."

## Output

```
### Pre-flight — [date]
| Check | Outcome | If not PASS |
|---|---|---|
| V1 Telephony provisioned | PASS | — |
| V4 Voice agent active | FAIL | Change log: NeedsUICommit. Take live via Builder before rehearsal. |
| N3 NBA component on page | UNKNOWN | Confirm in App Builder: Case record page, Vignette 4 |
| D1 Date drift | FAIL | Case 5001234 opened 2026-08-10; story says "this morning". Run refresh or reword. |
...
```

Then, before writing the talk track, ask the SE one question: **"Any FAIL here that changes which vignettes are demo-able, or should I write the talk track with the fallback scenes where needed?"** Wait for the answer. Every FAIL on a load-bearing vignette becomes a fallback scene in the talk track unless the SE says they'll fix it first.
