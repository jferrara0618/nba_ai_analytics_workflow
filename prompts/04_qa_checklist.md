# Prompt 04 — QA + Edge Case Review

## Purpose
Before any SQL output touches a stakeholder, run it through this QA prompt. It catches the most common failure modes in AI-generated SQL: silent null handling, aggregation errors, date spine gaps, and faulty joins.

## When to Use
Every time. After Prompt 03, before sharing results. No exceptions.

## Why This Step Exists
AI-generated SQL is often *structurally* correct but *logically* wrong. It will run without errors and return plausible-looking numbers — and still be wrong. This step makes that visible before it embarrasses you.

## Inputs Required
- `[SQL]` — the full query from Prompt 03
- `[SCHEMA]` — same schema used in Prompt 03
- `[BUSINESS_QUESTION]` — the specific question this SQL is meant to answer

---

## The Prompt

```
You are a senior analytics engineer doing a QA review of this SQL query before it goes to a stakeholder.

Business question this query is answering:
[BUSINESS_QUESTION]

Schema:
[SCHEMA]

SQL to review:
[SQL]

Perform a thorough QA review. Check for all of the following and flag any issues found:

1. NULL HANDLING
   - Are there columns that could be null that aren't handled?
   - Would nulls cause incorrect aggregations (e.g., AVG ignoring nulls silently)?

2. JOIN LOGIC
   - Is every JOIN type (INNER, LEFT, etc.) intentional?
   - Could any JOIN fan out rows and inflate counts?
   - Are there cases where a JOIN might drop rows unexpectedly?

3. AGGREGATION CORRECTNESS
   - Are GROUP BY clauses complete?
   - Are any window functions missing PARTITION BY or ORDER BY?
   - Could any metric be double-counted?

4. DATE / TIME LOGIC
   - Are date filters inclusive/exclusive as intended?
   - Are there gaps in date ranges that could silently exclude data?
   - Is timezone handling needed and missing?

5. BUSINESS LOGIC
   - Does the query actually answer the business question as stated?
   - Are there any filter conditions that could over- or under-scope the result?
   - Would the output mislead a non-technical reader?

6. PERFORMANCE
   - Are there any obvious inefficiencies (e.g., SELECT * in a subquery, missing WHERE clause on a large table)?

For each issue found, provide:
- SEVERITY: HIGH / MEDIUM / LOW
- DESCRIPTION: what the issue is
- FIX: the specific change to make

End with an overall PASS / NEEDS REVISION verdict.
```

---

## Quality Controls
A trustworthy QA output should:
- [ ] Flag at least 1–2 issues on any non-trivial query (if zero issues, re-run or add more context)
- [ ] Include at least one business logic check, not just syntax/structure
- [ ] Provide specific fixes, not just descriptions of problems
- [ ] Return NEEDS REVISION if any HIGH severity issue is found

**If the verdict is NEEDS REVISION:** Fix the flagged issues in the SQL, then re-run this prompt on the revised version. Do not skip the re-run.

---

## Example Output

> **QA Review: Q3 Turnover Blown Lead Analysis**
>
> **1. NULL HANDLING**
> - SEVERITY: MEDIUM  
>   `tov` could be null for forfeited or postponed games. The current `AVG()` will silently exclude nulls, which may skew turnover averages in low-sample buckets.  
>   FIX: Add `WHERE tov IS NOT NULL` to the `halftime_leads` CTE, or use `COALESCE(tov, 0)` if zero is a valid substitute.
>
> **2. JOIN LOGIC**
> - SEVERITY: HIGH  
>   The self-join on `game_id` and `team_id != team_id` will produce 2 rows per game if both teams match the team_id filter — but since you're filtering to one team, this should be safe. However, if `team_id` is ever NULL, the `!=` condition won't exclude those rows.  
>   FIX: Add `AND o.team_id IS NOT NULL` to the join condition.
>
> **3. AGGREGATION CORRECTNESS**
> - No issues found.
>
> **4. DATE / TIME LOGIC**
> - SEVERITY: LOW  
>   `season BETWEEN 2021 AND 2024` is inclusive on both ends — confirm this is intended and that "2024" refers to the 2023-24 season, not calendar year.  
>   FIX: Add a comment clarifying season definition, or switch to an explicit date range if more control is needed.
>
> **5. BUSINESS LOGIC**
> - SEVERITY: MEDIUM  
>   The query measures *total game* turnovers, not Q3/Q4 specifically, despite the hypothesis being about "Q3 turnover behavior." This misaligns with the stated question.  
>   FIX: If per-quarter tov data is available, use `tov_q3 + tov_q4` instead of `tov`.
>
> **6. PERFORMANCE**
> - No major issues. Table size is manageable for a single-team filter.
>
> ---
> **Verdict: NEEDS REVISION**  
> Address the HIGH severity join null issue and the MEDIUM business logic misalignment before sharing results.

---

## Notes on Iteration
This prompt works best when `[SCHEMA]` includes column descriptions, not just data types. Even one-line descriptions ("tov INT — total turnovers, game level") dramatically improve the quality of business logic checks.
