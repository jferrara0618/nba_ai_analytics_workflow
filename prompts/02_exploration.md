# Prompt 02 — Data Exploration + Hypothesis Generation

## Purpose
Feed Claude a data schema and sample rows, and get back a ranked list of investigable hypotheses — so you spend time testing ideas, not staring at columns wondering where to start.

## When to Use
After the Requirements Brief (Prompt 01) is approved. Use this before writing any SQL to surface the most promising angles to explore.

## Inputs Required
- `[RESTATED_QUESTION]` — from your Prompt 01 output
- `[SCHEMA]` — table names, column names, and data types (paste from Snowflake)
- `[SAMPLE_ROWS]` — 5–10 representative rows from your key table(s)

---

## The Prompt

```
You are a senior data analyst helping me explore a dataset to answer this question:
"[RESTATED_QUESTION]"

Here is the schema of the available data:
[SCHEMA]

Here are sample rows:
[SAMPLE_ROWS]

Do the following:

1. PROFILE the data — note anything interesting, unusual, or potentially problematic 
   (nulls, skewed distributions, date gaps, outlier values)

2. GENERATE 5 hypotheses I should test to answer the question. 
   For each hypothesis:
   - State it as a falsifiable claim (e.g., "Teams that commit more turnovers in Q3 are X% more likely to lose a halftime lead")
   - Identify which columns I'd need to test it
   - Rate your confidence it will yield a meaningful signal: HIGH / MEDIUM / LOW
   - Explain your reasoning in 1 sentence

3. RECOMMEND which hypothesis to start with and why.

Flag any data quality concerns that could invalidate a hypothesis with [DATA RISK].
```

---

## Quality Controls
Before accepting the output, verify:
- [ ] Each hypothesis is falsifiable — it makes a specific, testable claim
- [ ] At least one hypothesis surfaces a variable the business can actually act on
- [ ] Data risks are flagged (nulls, small sample sizes, selection bias)
- [ ] The recommended starting hypothesis isn't just the most obvious one

---

## Example Schema Input

```
TABLE: game_stats
- game_id          VARCHAR
- game_date        DATE
- team_id          VARCHAR
- pts_q1           INT
- pts_q2           INT
- pts_q3           INT
- pts_q4           INT
- pts_total        INT
- fg_pct           FLOAT
- fg3_pct          FLOAT
- ft_pct           FLOAT
- reb              INT
- ast              INT
- tov              INT
- stl              INT
- blk              INT
- home_away        VARCHAR  -- 'H' or 'A'
- win              BOOLEAN

TABLE: game_metadata
- game_id          VARCHAR
- season           INT
- game_date        DATE
- home_team_id     VARCHAR
- away_team_id     VARCHAR
```

---

## Example Output

> **Data Profile:**
> - `fg3_pct` has ~3% null rate — likely missing for older games, fine for 2021+ analysis
> - `pts_q4` has a right skew — a handful of games with 40+ Q4 points; worth flagging as outliers
> - [DATA RISK] `tov` appears to be cumulative, not per-quarter — will need to calculate Q3/Q4 tov separately if we join game logs
>
> **Hypotheses:**
>
> 1. **Turnovers in Q3 predict blown leads** *(HIGH confidence)*  
>    Teams that blow halftime leads average significantly more Q3 turnovers than teams that hold them.  
>    Columns needed: `tov`, `pts_q1+q2` (halftime lead flag), `win`
>
> 2. **3-point shooting variance collapses in Q3/Q4** *(MEDIUM confidence)*  
>    Teams that blow leads show a larger drop in `fg3_pct` between first and second halves than teams that don't.  
>    Columns needed: `fg3_pct` by half (derived)
>
> 3. **Home/away has outsized effect on lead-holding** *(MEDIUM confidence)*  
>    Road teams are disproportionately represented in blown-lead games.  
>    Columns needed: `home_away`, `win`, halftime lead flag
>
> 4. **Free throw rate declines in clutch situations** *(LOW confidence)*  
>    Teams that blow leads attempt fewer free throws in Q4.  
>    Columns needed: `ft_pct`, `pts_q4`
>
> 5. **Rebound differential flips in the 2nd half** *(HIGH confidence)*  
>    Teams leading at half that lose the rebounding battle in Q3/Q4 lose the game at a much higher rate.  
>    Columns needed: `reb` by half (derived)
>
> **Recommendation:** Start with Hypothesis 1 (turnovers) — it's directly actionable for coaching staff and the data is clean enough to test confidently.

---

## Notes on Iteration
If hypotheses feel generic, add more context to `[RESTATED_QUESTION]` or include a note about what the stakeholder has *already* tried. The model will avoid re-suggesting known dead ends if you tell it what's already been ruled out.
