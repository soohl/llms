# Agentic ability benchmark

| Task | Difficulty | Model | Result | Score | Time | Generated | Reasoning est. | Turns | Tools/errors | Cache R/W | Compactions |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 01-python-repair | easy | `deepseek-v4-flash-0731` | PASS | 6/6 | 198.4s | 6,566 | ≈2,531 | 12 | 16/1 | 77,160/4,219 | 0 |
| 02-data-reconciliation | medium | `deepseek-v4-flash-0731` | FAIL | 0/12 | 125.1s | 4,229 | ≈3,524 | 2 | 1/0 | 2,691/3,209 | 0 |
| 03-dependency-planner | hard | `deepseek-v4-flash-0731` | FAIL | 0/20 | 137.3s | 4,537 | ≈3,824 | 4 | 6/0 | 8,916/3,701 | 0 |

## Totals

| Model | Tasks passed | Task score | Time | Generated | Reasoning est. | Turns | Tools/errors |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `deepseek-v4-flash-0731` | 1/3 | 6/38 | 460.8s | 15,332 | ≈9,879 | 18 | 23/1 |

## Historical baseline — not directly comparable

These cloud results used an older, non-identical 65K profile. They are context only, not controlled comparisons with the local 64K runs.

| Task | Model | Result | Score | Time | Turns | Tools/errors |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 01-python-repair | `gpt-5.6-luna (historical baseline)` | PASS | 6/6 | 207.7s | 11 | 22/3 |
| 02-data-reconciliation | `gpt-5.6-luna (historical baseline)` | PASS | 12/12 | 185.8s | 7 | 10/1 |
| 03-dependency-planner | `gpt-5.6-luna (historical baseline)` | PASS | 20/20 | 311.2s | 16 | 27/3 |
