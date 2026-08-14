# Agentic ability benchmark

Benchmark: `pi-agentic-64k-native-strong-v7`

| Task | Difficulty | Model | Result | Score | Time | Generated | Reasoning est. | Turns | Tools/errors | Cache R/W | Compactions |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 01-python-repair | easy | `deepseek-v4-flash-0731` | PASS | 6/6 | 172.3s | 5,698 | ≈1,696 | 9 | 14/0 | 46,245/4,024 | 0 |
| 02-data-reconciliation | medium | `deepseek-v4-flash-0731` | not run | — | — | — | — | — | — | — | — | — |
| 03-dependency-planner | hard | `deepseek-v4-flash-0731` | not run | — | — | — | — | — | — | — | — | — |

## Totals

| Model | Tasks passed | Task score | Time | Generated | Reasoning est. | Turns | Tools/errors |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `deepseek-v4-flash-0731` | 1/1 | 6/6 | 172.3s | 5,698 | ≈1,696 | 9 | 14/0 |

## Historical baseline — not directly comparable

These cloud results used an older, non-identical 65K profile. They are context only, not controlled comparisons with the local 64K runs.

| Task | Model | Result | Score | Time | Turns | Tools/errors |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 01-python-repair | `gpt-5.6-luna (historical baseline)` | PASS | 6/6 | 207.7s | 11 | 22/3 |
| 02-data-reconciliation | `gpt-5.6-luna (historical baseline)` | PASS | 12/12 | 185.8s | 7 | 10/1 |
| 03-dependency-planner | `gpt-5.6-luna (historical baseline)` | PASS | 20/20 | 311.2s | 16 | 27/3 |
