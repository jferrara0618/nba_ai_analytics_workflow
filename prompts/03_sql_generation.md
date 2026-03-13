# Prompt 03 — Business Question → Snowflake SQL

## Purpose
Translate a plain-English analytics question into production-quality Snowflake SQL — with inline comments, logic explanations, and edge case notes baked in.

## When to Use
Once you've selected a hypothesis to test (Prompt 02). Run this once per hypothesis. Do NOT skip Prompt 04 (QA) before sharing output with stakeholders.

## Inputs Required
- `[BUSINESS_QUESTION]` — the specific, restated question from your hypothesis
- `[SCHEMA]` — relevant table/column definitions
- `[FILTERS]` — any scope constraints (seasons, teams, date ranges)
- `[OUTPUT_FORMAT]` — what you want the query to return (e.g., one row per game, one row per team-season)

---

## The Prompt

```
You are a senior analytics engineer writing Snowflake SQL.

Business question: [BUSINESS_QUESTION]

Schema:
[SCHEMA]

Filters/scope: [FILTERS]

Desired output: [OUTPUT_FORMAT]

Write a Snowflake SQL query to answer this question. Requirements:
1. Use CTEs (WITH clauses) to make the logic readable — one CTE per logical step
2. Add an inline comment above each CTE explaining what it does and why
3. Use window functions where appropriate instead of subqueries
4. After the SQL, write a "Logic Summary" section explaining the approach in plain English
5. Write a "Assumptions Made" section listing any choices you made where the question was ambiguous
6. Write a "Watch Out For" section with 2-3 edge cases or data quality risks in this specific query

Format: SQL code block first, then the three sections below it.
```

---

## Quality Controls
Before accepting the SQL output, verify:
- [ ] CTEs are named descriptively (not `cte1`, `cte2`)
- [ ] The Logic Summary matches what the SQL actually does — spot check one CTE
- [ ] At least one edge case is flagged in "Watch Out For"
- [ ] Assumptions Made section exists — if it's empty, the question may have been too narrow or the model over-assumed

Then run Prompt 04 on this SQL before sharing with anyone.

---

## Example Input

**Business Question:** Among games where our team held a halftime lead, do games with higher Q3 turnover counts result in losses at a significantly higher rate?  
**Schema:** `game_stats` (game_id, team_id, pts_q1, pts_q2, pts_q3, pts_q4, tov, win, home_away)  
**Filters:** Seasons 2021–2024, one specific team_id  
**Output:** One row per game, showing halftime lead size, Q3 turnovers, and win/loss

---

## Example Output

```sql
-- ============================================================
-- ANALYSIS: Q3 Turnovers and Blown Leads
-- Business Question: Do higher Q3 turnover games predict losses
--                    in games where we led at halftime?
-- ============================================================

WITH

-- Step 1: Calculate halftime score and flag games where team led at half
halftime_leads AS (
    SELECT
        game_id,
        team_id,
        pts_q1 + pts_q2                          AS pts_first_half,
        pts_q3 + pts_q4                          AS pts_second_half,
        pts_q1 + pts_q2 + pts_q3 + pts_q4       AS pts_total,
        tov,
        win,
        home_away
    FROM game_stats
    WHERE team_id = '[YOUR_TEAM_ID]'
      AND season BETWEEN 2021 AND 2024
),

-- Step 2: Join to opponent stats to calculate halftime lead margin
-- We need opponent's first-half score to determine if team was leading
with_opponent AS (
    SELECT
        h.game_id,
        h.team_id,
        h.pts_first_half                         AS team_first_half,
        o.pts_first_half                         AS opp_first_half,
        h.pts_first_half - o.pts_first_half      AS halftime_margin,
        h.tov                                    AS q3_q4_tov,
        h.win
    FROM halftime_leads h
    JOIN halftime_leads o
        ON h.game_id = o.game_id
        AND h.team_id != o.team_id
),

-- Step 3: Filter to only games where team led at halftime
-- and bucket turnovers into low / medium / high
lead_games AS (
    SELECT
        game_id,
        halftime_margin,
        q3_q4_tov,
        win,
        CASE
            WHEN q3_q4_tov <= 5  THEN 'Low (0-5)'
            WHEN q3_q4_tov <= 10 THEN 'Medium (6-10)'
            ELSE                      'High (11+)'
        END                                      AS tov_bucket
    FROM with_opponent
    WHERE halftime_margin > 0   -- only games where team led at half
)

-- Final: Win rate by turnover bucket
SELECT
    tov_bucket,
    COUNT(*)                                     AS games,
    SUM(CASE WHEN win THEN 1 ELSE 0 END)         AS wins,
    ROUND(AVG(CASE WHEN win THEN 1.0 ELSE 0 END) * 100, 1) AS win_pct
FROM lead_games
GROUP BY tov_bucket
ORDER BY tov_bucket;
```

**Logic Summary:**  
We isolate games where the team held a halftime lead, then group those games by how many turnovers occurred in the second half. The final output shows win rate by turnover volume — if the pattern holds, win% should drop meaningfully as turnovers increase.

**Assumptions Made:**
- `tov` in `game_stats` reflects total game turnovers, not Q3/Q4 only. Adjust if per-quarter tov data is available.
- Halftime lead is defined as points_q1 + points_q2 > opponent's. A 1-point lead qualifies.
- Bucketing thresholds (5, 10) are illustrative — adjust based on team's typical tov distribution.

**Watch Out For:**
- Small sample sizes in the "High" tov bucket may make win% unreliable — check `games` count before drawing conclusions
- If `tov` is cumulative (game-level), this analysis can't isolate Q3 vs Q4 behavior — validate with a raw row check
- Playoff games vs. regular season may behave differently — consider adding a `game_type` filter

---

## Notes on Iteration
If the SQL is structurally correct but logically off, rerun the prompt with the "Assumptions Made" section pasted back in as corrections. Example: *"Your assumption about tov being game-level is wrong — we have per-quarter data in `tov_q3` and `tov_q4`. Rewrite with that."*
