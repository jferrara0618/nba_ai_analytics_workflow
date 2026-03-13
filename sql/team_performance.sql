-- ============================================================
-- Team 4th Quarter Performance Analysis
-- Business Question: In games where we led at halftime, what
--   second-half factors most predict winning vs. losing?
-- Generated via: Prompt 03 (SQL Generation)
-- QA Status: Reviewed via Prompt 04 ✓
-- ============================================================

WITH

-- Step 1: Get all game stats for the target team
-- Scope to regular season games, 2021-2024
team_games AS (
    SELECT
        gs.game_id,
        gs.team_id,
        gs.pts_q1,
        gs.pts_q2,
        gs.pts_q3,
        gs.pts_q4,
        gs.pts_q1 + gs.pts_q2                          AS pts_first_half,
        gs.pts_q3 + gs.pts_q4                          AS pts_second_half,
        gs.fg_pct,
        gs.fg3_pct,
        gs.reb,
        gs.tov,
        gs.ast,
        gs.win,
        gs.home_away,
        gm.season
    FROM game_stats gs
    JOIN game_metadata gm ON gs.game_id = gm.game_id
    WHERE gs.team_id = '{{ team_id }}'           -- replace with your team_id
      AND gm.season BETWEEN 2021 AND 2024
      AND gm.game_type = 'regular'               -- exclude playoffs
      AND gs.tov IS NOT NULL                     -- exclude data quality gaps
),

-- Step 2: Get opponent stats for the same games
-- Needed to calculate halftime margin (did we actually lead?)
opponent_games AS (
    SELECT
        gs.game_id,
        gs.pts_q1 + gs.pts_q2                          AS opp_first_half,
        gs.pts_q3 + gs.pts_q4                          AS opp_second_half,
        gs.fg_pct                                       AS opp_fg_pct,
        gs.reb                                          AS opp_reb,
        gs.tov                                          AS opp_tov
    FROM game_stats gs
    WHERE gs.team_id != '{{ team_id }}'          -- opponent rows
      AND gs.game_id IN (SELECT game_id FROM team_games)
      AND gs.tov IS NOT NULL
),

-- Step 3: Join team and opponent to calculate lead margins
-- and flag games where we led at halftime
games_with_margins AS (
    SELECT
        t.game_id,
        t.season,
        t.home_away,
        t.pts_first_half,
        t.pts_second_half,
        t.fg_pct,
        t.fg3_pct,
        t.reb,
        t.tov,
        t.ast,
        t.win,
        o.opp_first_half,
        o.opp_second_half,
        o.opp_fg_pct,
        o.opp_reb,
        o.opp_tov,
        t.pts_first_half - o.opp_first_half             AS halftime_margin,
        t.pts_second_half - o.opp_second_half           AS second_half_margin,
        t.reb - o.opp_reb                               AS reb_differential,
        t.tov - o.opp_tov                               AS tov_differential
    FROM team_games t
    JOIN opponent_games o ON t.game_id = o.game_id
),

-- Step 4: Filter to only halftime lead games
-- and bucket key metrics for comparison
halftime_lead_games AS (
    SELECT
        game_id,
        season,
        home_away,
        halftime_margin,
        second_half_margin,
        fg3_pct,
        tov,
        reb_differential,
        tov_differential,
        win,
        -- Bucket halftime lead size
        CASE
            WHEN halftime_margin BETWEEN 1 AND 5   THEN 'Close (1-5 pts)'
            WHEN halftime_margin BETWEEN 6 AND 12  THEN 'Comfortable (6-12 pts)'
            ELSE                                        'Large (13+ pts)'
        END                                             AS lead_size_bucket,
        -- Bucket 2nd-half turnovers
        CASE
            WHEN tov <= 5   THEN 'Low (0-5)'
            WHEN tov <= 10  THEN 'Medium (6-10)'
            ELSE                 'High (11+)'
        END                                             AS tov_bucket
    FROM games_with_margins
    WHERE halftime_margin > 0   -- team led at halftime
)

-- ============================================================
-- FINAL OUTPUT: Win rate by turnover bucket and lead size
-- One row per bucket combination
-- ============================================================
SELECT
    lead_size_bucket,
    tov_bucket,
    COUNT(*)                                            AS games,
    SUM(CASE WHEN win THEN 1 ELSE 0 END)               AS wins,
    ROUND(
        AVG(CASE WHEN win THEN 1.0 ELSE 0 END) * 100
    , 1)                                               AS win_pct,
    ROUND(AVG(tov), 1)                                 AS avg_tov,
    ROUND(AVG(reb_differential), 1)                    AS avg_reb_diff,
    ROUND(AVG(fg3_pct) * 100, 1)                       AS avg_fg3_pct
FROM halftime_lead_games
GROUP BY lead_size_bucket, tov_bucket
ORDER BY lead_size_bucket, tov_bucket;
