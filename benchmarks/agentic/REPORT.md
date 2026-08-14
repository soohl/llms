# Agentic ability benchmark

| Task | Difficulty | Model | Result | Score | Time | Generated | Reasoning est. | Turns | Tools/errors | Cache R/W | Compactions |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 01-python-repair | easy | `deepseek-v4-flash-0731` | FAIL | 4/6 | 138.6s | 4,528 | ≈1,100 | 8 | 14/0 | 35,671/3,771 | 0 |
| 02-data-reconciliation | medium | `deepseek-v4-flash-0731` | FAIL | 10/12 | 211.4s | 7,038 | ≈2,591 | 7 | 8/0 | 49,665/4,826 | 0 |
| 03-dependency-planner | hard | `deepseek-v4-flash-0731` | PASS | 20/20 | 461.4s | 15,796 | ≈7,703 | 13 | 15/0 | 164,267/5,050 | 0 |

## Totals

| Model | Tasks passed | Task score | Time | Generated | Reasoning est. | Turns | Tools/errors |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `deepseek-v4-flash-0731` | 1/3 | 34/38 | 811.3s | 27,362 | ≈11,394 | 28 | 37/0 |

## Historical baseline — not directly comparable

These cloud results used an older, non-identical 65K profile. They are context only, not controlled comparisons with the local 64K runs.

| Task | Model | Result | Score | Time | Turns | Tools/errors |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 01-python-repair | `gpt-5.6-luna (historical baseline)` | PASS | 6/6 | 207.7s | 11 | 22/3 |
| 02-data-reconciliation | `gpt-5.6-luna (historical baseline)` | PASS | 12/12 | 185.8s | 7 | 10/1 |
| 03-dependency-planner | `gpt-5.6-luna (historical baseline)` | PASS | 20/20 | 311.2s | 16 | 27/3 |
