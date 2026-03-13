# Prompt 01 — Stakeholder Requirements Clarification

## Purpose
Transform an ambiguous stakeholder question into a structured requirements brief with clear success metrics, scope boundaries, and a defined insight deliverable.

## When to Use
At the very start of any analysis. Before writing a single line of SQL, use this prompt to align on what "done" looks like.

## Inputs Required
- `[STAKEHOLDER_ROLE]` — who is asking (e.g., General Manager, Head Coach, VP of Basketball Ops)
- `[RAW_QUESTION]` — their original, unstructured question
- `[DATASET_CONTEXT]` — brief description of available data

---

## The Prompt

```
You are an experienced analytics consultant working with a sports organization.

A [STAKEHOLDER_ROLE] has come to you with this question:
"[RAW_QUESTION]"

Available data: [DATASET_CONTEXT]

Your job is to produce a structured Requirements Brief. Do the following:

1. RESTATE the question as a precise, answerable analytics question (1-2 sentences)
2. IDENTIFY 2-3 success metrics — how will we know the analysis answered the question?
3. DEFINE scope boundaries — what is in scope vs. out of scope for this analysis?
4. LIST the data fields/tables likely needed to answer this
5. FLAG any ambiguities that need stakeholder clarification before work begins
6. SUGGEST the ideal output format (table, chart type, narrative summary, etc.)

Format your output as a Requirements Brief with clear headers for each section.
Flag any assumption you're making with [ASSUMPTION].
```

---

## Quality Controls
Before accepting the output, verify:
- [ ] The restated question is specific enough to be falsifiable (you could be wrong)
- [ ] Success metrics are measurable, not subjective ("win % improves" not "better performance")
- [ ] At least one ambiguity is flagged — if none are flagged, the prompt may have over-assumed
- [ ] Scope boundaries rule something *out*, not just in

---

## Example Input

**Stakeholder Role:** General Manager  
**Raw Question:** "Why are we losing games we should be winning?"  
**Dataset Context:** NBA game logs 2018–2024, including team stats, player minutes, game location, and score by quarter

---

## Example Output

> **Requirements Brief**
>
> **Restated Question:**  
> Among games where our team held a halftime lead, what in-game factors most strongly predict a second-half collapse, and how do those factors compare to the league average?
>
> **Success Metrics:**
> - Identify ≥2 statistically distinct patterns that differentiate blown leads from held leads
> - Surface at least one actionable variable the coaching staff controls (e.g., lineup usage, pace, shot selection)
> - Deliver findings with enough confidence to present to coaching staff
>
> **In Scope:**
> - Home and away games, 2021–2024 seasons
> - Quarters 3 and 4 only
> - Team-level stats (not individual player)
>
> **Out of Scope:**
> - Opponent quality adjustment (save for v2)
> - Injury data
>
> **Data Fields Needed:**
> - `game_id`, `team_id`, `pts_q1–q4`, `fg_pct`, `fg3_pct`, `reb`, `tov`, `game_date`, `matchup`
>
> **Ambiguities to Clarify:**
> - [ASSUMPTION] "Games we should be winning" = games where we led at halftime. Confirm?
> - What counts as a "collapse"? Losing by any margin, or losing by 5+?
>
> **Recommended Output Format:**  
> Summary narrative (3 paragraphs) + supporting comparison table (our team vs. league avg on key 2nd-half metrics)

---

## Notes on Iteration
If the output is too generic, add more specificity to `[RAW_QUESTION]` or constrain `[DATASET_CONTEXT]`. The model will scope its output to the information you give it — garbage in, garbage out applies here too.
