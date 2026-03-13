# Data Setup Instructions

## Dataset Source

This project uses the **NBA Games Dataset** from Kaggle:  
https://www.kaggle.com/datasets/nathanlauga/nba-games

Download the following files:
- `games.csv` — one row per game with team stats
- `games_details.csv` — player-level game log (optional for player analysis)
- `teams.csv` — team metadata

---

## Loading into Snowflake

### Step 1: Create a database and schema

```sql
CREATE DATABASE nba_analytics;
CREATE SCHEMA nba_analytics.raw;
USE SCHEMA nba_analytics.raw;
```

### Step 2: Create tables

```sql
CREATE OR REPLACE TABLE game_stats (
    game_id         VARCHAR(20),
    game_date       DATE,
    team_id         VARCHAR(20),
    pts_q1          INT,
    pts_q2          INT,
    pts_q3          INT,
    pts_q4          INT,
    pts_total       INT,
    fg_pct          FLOAT,
    fg3_pct         FLOAT,
    ft_pct          FLOAT,
    reb             INT,
    ast             INT,
    tov             INT,
    stl             INT,
    blk             INT,
    home_away       VARCHAR(5),    -- 'H' or 'A'
    win             BOOLEAN
);

CREATE OR REPLACE TABLE game_metadata (
    game_id         VARCHAR(20),
    season          INT,
    game_date       DATE,
    home_team_id    VARCHAR(20),
    away_team_id    VARCHAR(20),
    game_type       VARCHAR(20)    -- 'regular' or 'playoff'
);

CREATE OR REPLACE TABLE teams (
    team_id         VARCHAR(20),
    team_name       VARCHAR(100),
    abbreviation    VARCHAR(5),
    city            VARCHAR(50),
    conference      VARCHAR(10)
);
```

### Step 3: Load CSVs via Snowflake UI

1. Go to **Snowsight → Data → Load Data**
2. Select your table
3. Upload the matching CSV file
4. Use format options: header row = true, delimiter = comma

Or use SnowSQL:

```sql
PUT file:///path/to/games.csv @%game_stats;
COPY INTO game_stats FROM @%game_stats FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
```

---

## Column Mapping Notes

The Kaggle dataset uses slightly different column names. Map as follows:

| Kaggle Column | Our Column |
|---|---|
| `GAME_ID` | `game_id` |
| `GAME_DATE_EST` | `game_date` |
| `TEAM_ID_home` | `team_id` (home row) |
| `PTS_home` | `pts_total` (home row) |
| `FG_PCT_home` | `fg_pct` |
| `FT_PCT_home` | `ft_pct` |
| `FG3_PCT_home` | `fg3_pct` |
| `AST_home` | `ast` |
| `REB_home` | `reb` |
| `HOME_TEAM_WINS` | `win` (home row = TRUE if 1) |

> Note: The Kaggle dataset stores games as one row with both team stats. You'll need to unpivot into two rows (one per team) to match this project's schema. See the transformation script below.

---

## Transformation: Unpivot to One Row Per Team

```sql
-- Creates the game_stats table in the expected format
-- from the raw Kaggle wide-format games.csv

INSERT INTO game_stats
-- Home team rows
SELECT
    GAME_ID                         AS game_id,
    GAME_DATE_EST::DATE             AS game_date,
    TEAM_ID_home                    AS team_id,
    NULL                            AS pts_q1,   -- not in this dataset
    NULL                            AS pts_q2,
    NULL                            AS pts_q3,
    NULL                            AS pts_q4,
    PTS_home                        AS pts_total,
    FG_PCT_home                     AS fg_pct,
    FG3_PCT_home                    AS fg3_pct,
    FT_PCT_home                     AS ft_pct,
    REB_home                        AS reb,
    AST_home                        AS ast,
    NULL                            AS tov,      -- not in this dataset
    NULL                            AS stl,
    NULL                            AS blk,
    'H'                             AS home_away,
    (HOME_TEAM_WINS = 1)            AS win
FROM raw_games

UNION ALL

-- Away team rows
SELECT
    GAME_ID,
    GAME_DATE_EST::DATE,
    TEAM_ID_away,
    NULL, NULL, NULL, NULL,
    PTS_away,
    FG_PCT_away,
    FG3_PCT_away,
    FT_PCT_away,
    REB_away,
    AST_away,
    NULL, NULL, NULL,
    'A',
    (HOME_TEAM_WINS = 0)
FROM raw_games;
```

> **Note on quarter-level data:** The base Kaggle dataset doesn't include per-quarter scores. For Q1–Q4 breakdown, use the `nba_api` Python package instead, which provides play-by-play and box score data with quarter splits.

---

## Alternative: nba_api Python Package

For richer data including per-quarter stats:

```bash
pip install nba_api
```

```python
from nba_api.stats.endpoints import teamgamelog, boxscoretraditionalv2

# Get game log for a team
logs = teamgamelog.TeamGameLog(team_id='1610612747', season='2023-24')
df = logs.get_data_frames()[0]

# Write to CSV, then load into Snowflake
df.to_csv('team_game_log.csv', index=False)
```

This provides: `PTS_Q1`, `PTS_Q2`, `PTS_Q3`, `PTS_Q4`, `TOV`, `STL`, `BLK`, and more at the team-game level.
