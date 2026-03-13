# NBA AI-Augmented Analytics Workflow

A reference pattern for delivering trusted sports analytics insights faster using AI — built on NBA data, Snowflake, and a structured 5-step prompt workflow.

## What This Is

This project demonstrates a repeatable, AI-assisted analytics workflow that takes an ambiguous business question from a stakeholder and delivers a defensible insight — with documented prompt patterns, quality controls, and example outputs at every step.

It maps directly to a modern analytics delivery model:
> **What happened → Why → What to do next**

---

## The 5-Step Workflow

```
Stakeholder Question
        ↓
[01] Requirements Clarification   → structured brief with success metrics
        ↓
[02] Data Exploration + Hypotheses → ranked hypotheses to investigate
        ↓
[03] SQL Generation               → Snowflake-ready SQL with logic comments
        ↓
[04] QA + Edge Case Review        → quality checklist before stakeholder delivery
        ↓
[05] Insight Narrative            → what happened → why → what to do next
```

Each step has a documented prompt pattern in `/prompts/` and a sample output in `/outputs/`.

---

## Repo Structure

```
nba-ai-analytics-workflow/
├── README.md
├── prompts/
│   ├── 01_requirements.md       # Stakeholder discovery prompt
│   ├── 02_exploration.md        # Data profiling + hypothesis generation
│   ├── 03_sql_generation.md     # Business question → Snowflake SQL
│   ├── 04_qa_checklist.md       # Edge case + quality control review
│   └── 05_narrative.md          # Insight narrative generation
├── sql/
│   ├── team_performance.sql     # 4th quarter performance by team
│   └── player_efficiency.sql    # Player efficiency rating breakdown
├── outputs/
│   ├── requirements_brief.md    # Sample output from prompt 01
│   ├── hypothesis_doc.md        # Sample output from prompt 02
│   └── insight_narrative.md     # Sample output from prompt 05
└── data/
    └── setup_instructions.md    # How to load NBA data into Snowflake
```

---

## Dataset

This project uses the [NBA Games Dataset](https://www.kaggle.com/datasets/nathanlauga/nba-games) from Kaggle, which includes:

- Game-level stats (points, rebounds, assists, FG%) from 2003–present
- Team metadata and season records
- Player-level game logs

Load instructions: see [`data/setup_instructions.md`](data/setup_instructions.md)

---

## How to Use These Prompt Patterns

Each prompt in `/prompts/` follows this format:

- **Purpose** — what this prompt is designed to do
- **When to use it** — where it fits in the workflow
- **Inputs required** — what you need to provide
- **The prompt** — copy/paste ready, with `[PLACEHOLDERS]` for your context
- **Quality controls** — how to evaluate whether the output is trustworthy
- **Example output** — what a good response looks like

### Key design principles:
1. **Placeholders over free-form** — every prompt uses explicit `[BRACKETS]` so outputs are consistent across analysts and questions
2. **Quality gates built in** — each prompt asks the model to flag its own uncertainty
3. **Outputs are artifacts** — every step produces a document, not just a chat response

---

## Skills Demonstrated

| Skill | Where It Shows Up |
|---|---|
| AI workflow design | The 5-step pattern itself |
| Prompt engineering | `/prompts/` — structured, repeatable patterns |
| Snowflake SQL | `/sql/` — CTEs, window functions, aggregations |
| Stakeholder translation | `outputs/requirements_brief.md` |
| Insight communication | `outputs/insight_narrative.md` |
| Quality control | `prompts/04_qa_checklist.md` |

---

## Example Question This Workflow Answers

> *"Our team is losing games we lead at halftime. What's happening in the second half, and what should we change?"*

Follow the 5 steps in `/prompts/` to see how an ambiguous GM question becomes a structured, data-backed recommendation.

---

## Author

Built as a portfolio project demonstrating AI-augmented analytics delivery.  
Stack: Claude (AI layer) · Snowflake (data) · SQL · Markdown
