# Requirements Brief
**Generated via:** Prompt 01 — Stakeholder Requirements Clarification  
**Date:** 2024-01-15  
**Stakeholder:** General Manager  
**Analyst:** [Your Name]

---

## Original Question
> "Why are we losing games we should be winning?"

---

## Restated Question
Among games where the team held a halftime lead, what second-half factors most strongly predict a final loss — and how do those factors compare to games where the lead was successfully protected?

---

## Success Metrics
1. Identify ≥2 statistically distinct patterns that separate blown-lead games from held-lead games, each with enough sample size (n ≥ 15) to be meaningful
2. Surface at least one variable the coaching staff directly controls (e.g., lineup usage, shot selection, pace) rather than opponent-dependent factors
3. Produce a finding specific enough to inform a concrete decision — not "we turn the ball over more" but "our second-unit lineup turns the ball over at 2.3x the rate of our starters in Q3"

---

## Scope

**In Scope:**
- Regular season games, 2021–2024 seasons
- Games where team held a halftime lead (any margin)
- Team-level stats: turnovers, rebounds, FG%, 3P%, assists, pace
- Home and away games

**Out of Scope:**
- Playoff games (different competitive dynamics)
- Opponent strength adjustment (save for v2 if initial findings are promising)
- Injury-adjusted analysis
- Individual player attribution (team-level first; player-level is a follow-on)

---

## Data Fields Needed

| Table | Fields |
|---|---|
| `game_stats` | `game_id`, `team_id`, `pts_q1–q4`, `fg_pct`, `fg3_pct`, `reb`, `tov`, `ast`, `win`, `home_away` |
| `game_metadata` | `game_id`, `season`, `game_type` |
| `teams` | `team_id`, `team_name` |

---

## Ambiguities Flagged

1. **[ASSUMPTION]** "Games we should be winning" interpreted as games where team held a halftime lead. Does the GM mean something different — e.g., games against lower-seeded opponents, or games with a win probability above a threshold?

2. **[CLARIFICATION NEEDED]** What counts as a "blown lead"? Options:
   - Any halftime lead game that results in a loss
   - Only games where the lead exceeded X points at some point in Q3/Q4
   - Confirmed: using "any halftime lead game that ends in a loss" for v1

3. **[ASSUMPTION]** Analysis will be team-level, not lineup-level. Player attribution is a natural follow-on but would require additional data pull.

---

## Recommended Output Format

**Primary deliverable:** 3-paragraph insight narrative (what happened → why → what to do next) with one supporting comparison table showing key second-half metrics split by win/loss outcome in halftime-lead games.

**Secondary deliverable:** A ranked list of 3 follow-on questions worth investigating if the primary analysis yields a clear signal.

**Format for delivery:** Slack summary (3 sentences) linking to a Sigma dashboard with the full breakdown.

---

## Timeline
- SQL + initial findings: 2 days
- Stakeholder review: Day 3
- Final narrative + recommendations: Day 4
