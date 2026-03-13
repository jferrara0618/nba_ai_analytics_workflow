# Prompt 05 — Insight Narrative Generation

## Purpose
Turn query results into a crisp, stakeholder-ready narrative that answers: **what happened → why → what to do next.**

## When to Use
After your SQL has passed QA (Prompt 04) and you have actual results. Paste results directly into this prompt — don't summarize them yourself first.

## Inputs Required
- `[STAKEHOLDER_ROLE]` — who will read this (GM, Head Coach, VP of Ops, etc.)
- `[ORIGINAL_QUESTION]` — the question the stakeholder originally asked
- `[QUERY_RESULTS]` — paste the actual output rows from your SQL
- `[CONTEXT]` — any relevant background (team record, recent trends, what's already been tried)

---

## The Prompt

```
You are a senior analytics consultant writing an insight brief for a [STAKEHOLDER_ROLE].

They originally asked: "[ORIGINAL_QUESTION]"

Here are the query results:
[QUERY_RESULTS]

Additional context: [CONTEXT]

Write a structured insight narrative with exactly three sections:

**WHAT HAPPENED**
- Lead with the single most important number or finding
- Be specific — use the actual values from the data
- 2-3 sentences maximum
- Do not hedge or qualify excessively — state what the data shows

**WHY IT'S HAPPENING** (if the data supports it)
- Offer 1-2 data-supported explanations
- Clearly label anything that is a hypothesis vs. something the data directly shows
- If the data doesn't answer "why," say so clearly rather than speculating

**WHAT TO DO NEXT**
- 2-3 specific, actionable recommendations
- At least one recommendation should be investigative (what to look at next)
- At least one recommendation should be operational (what to change now)
- Frame recommendations in terms of decisions the [STAKEHOLDER_ROLE] can actually make

Tone: direct and confident. This person makes high-stakes decisions daily — they want the point, not a disclaimer.
Length: 200-300 words total. If you can't say it in 300 words, the insight isn't clear enough yet.

End with one sentence: "The next question to answer is: [QUESTION]" — surfacing the most important follow-on analysis.
```

---

## Quality Controls
Before sending to a stakeholder:
- [ ] "What Happened" leads with a specific number, not a vague claim
- [ ] "Why" section clearly labels hypotheses vs. data-backed findings
- [ ] "What to Do Next" has at least one thing they can act on this week
- [ ] Total length is under 300 words
- [ ] No jargon the stakeholder wouldn't use themselves
- [ ] Read it out loud — does it sound like a confident advisor, or a hedging analyst?

---

## Example Input

**Stakeholder Role:** General Manager  
**Original Question:** "Why are we losing games we lead at halftime?"  
**Query Results:**

| tov_bucket   | games | wins | win_pct |
|--------------|-------|------|---------|
| Low (0-5)    | 34    | 29   | 85.3%   |
| Medium (6-10)| 41    | 26   | 63.4%   |
| High (11+)   | 18    | 5    | 27.8%   |

**Context:** Team is 31-19 overall, 7th in the East. Has lost 4 of last 6 games they led at halftime.

---

## Example Output

> **WHAT HAPPENED**
>
> When the team commits 11 or more second-half turnovers in games they lead at halftime, they win just 27.8% of the time — compared to 85.3% when they hold it to 5 or fewer. This isn't noise: across 18 high-turnover halftime-lead games this season, they've lost 13.
>
> **WHY IT'S HAPPENING**
>
> The data shows the correlation clearly, but not the cause. Two hypotheses worth investigating: (1) High-pressure defensive schemes are forcing higher turnover rates in Q3/Q4, particularly on the road — the team's away turnover rate in 4th quarters is worth pulling. (2) Lineup rotations may be introducing ball-handling mismatches late in games. This is a hypothesis, not confirmed by this data.
>
> **WHAT TO DO NEXT**
>
> 1. **This week:** Flag the 4 recent blown leads for film review — specifically Q3 possessions where turnovers occurred and who was on the floor.
> 2. **This week:** Pull the lineup-level turnover data for Q3/Q4 in halftime-lead games to identify if specific rotation units are driving the pattern.
> 3. **Longer term:** Set a second-half turnover target (≤7) as a trackable in-game metric for the coaching staff.
>
> The next question to answer is: *Which specific lineups are on the floor during high-turnover Q3/Q4 possessions in games we should have won?*

---

## Notes on Iteration
If the narrative feels vague, the most common cause is vague query results — go back and make sure your SQL is returning specific numbers, not just directional trends. The narrative is only as sharp as the data behind it.
