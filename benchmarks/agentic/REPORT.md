# Agentic ability benchmark

| Task | Difficulty | Model | Result | Score | Time | Generated | Reasoning est. | Turns | Tools/errors | Cache R/W | Compactions |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 01-python-repair | easy | `deepseek-v4-flash-0731` | FAIL | 4/6 | 138.6s | 4,528 | ≈1,100 | 8 | 14/0 | 35,671/3,771 | 0 |
| 01-python-repair | easy | `gemma-4-31b` | PASS | 6/6 | 220.5s | 7,972 | ≈3,213 | 22 | 21/0 | 134,744/0 | 0 |
| 01-python-repair | easy | `muse-glimmer-30b` | PASS | 6/6 | 270.1s | 11,914 | ≈7,607 | 26 | 30/1 | 271,081/0 | 0 |
| 01-python-repair | easy | `qwen3.6-27b` | FAIL | 4/6 | 108.3s | 4,161 | ≈369 | 11 | 16/1 | 53,142/0 | 0 |
| 01-python-repair | easy | `qwen3.8-27b` | PASS | 6/6 | 507.5s | 20,110 | ≈13,459 | 8 | 15/0 | 113,528/0 | 0 |
| 02-data-reconciliation | medium | `deepseek-v4-flash-0731` | FAIL | 10/12 | 211.4s | 7,038 | ≈2,591 | 7 | 8/0 | 49,665/4,826 | 0 |
| 02-data-reconciliation | medium | `gemma-4-31b` | FAIL | 10/12 | 246.3s | 8,788 | ≈2,513 | 12 | 11/1 | 95,567/0 | 0 |
| 02-data-reconciliation | medium | `muse-glimmer-30b` | FAIL | 8/12 | 361.1s | 16,296 | ≈13,080 | 14 | 17/0 | 171,448/0 | 0 |
| 02-data-reconciliation | medium | `qwen3.6-27b` | FAIL | 10/12 | 204.1s | 8,166 | ≈2,171 | 10 | 13/1 | 85,003/0 | 0 |
| 02-data-reconciliation | medium | `qwen3.8-27b` | PASS | 12/12 | 421.9s | 16,747 | ≈9,482 | 8 | 12/0 | 108,565/0 | 0 |
| 03-dependency-planner | hard | `deepseek-v4-flash-0731` | PASS | 20/20 | 461.4s | 15,796 | ≈7,703 | 13 | 15/0 | 164,267/5,050 | 0 |
| 03-dependency-planner | hard | `gemma-4-31b` | FAIL | 0/20 | 326.8s | 11,830 | ≈3,511 | 11 | 10/1 | 118,463/0 | 0 |
| 03-dependency-planner | hard | `muse-glimmer-30b` | PASS | 20/20 | 793.2s | 35,910 | ≈36,377 | 40 | 43/0 | 575,337/0 | 0 |
| 03-dependency-planner | hard | `qwen3.6-27b` | FAIL | 0/20 | 251.7s | 10,043 | ≈499 | 16 | 15/2 | 154,811/0 | 0 |
| 03-dependency-planner | hard | `qwen3.8-27b` | FAIL | 0/20 | 405.1s | 16,384 | ≈15,209 | 1 | 0/0 | 398/0 | 0 |

## Totals

| Model | Tasks passed | Task score | Time | Generated | Reasoning est. | Turns | Tools/errors |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `deepseek-v4-flash-0731` | 1/3 | 34/38 | 811.3s | 27,362 | ≈11,394 | 28 | 37/0 |
| `gemma-4-31b` | 1/3 | 16/38 | 793.6s | 28,590 | ≈9,237 | 45 | 42/2 |
| `muse-glimmer-30b` | 2/3 | 34/38 | 1424.3s | 64,120 | ≈57,064 | 80 | 90/1 |
| `qwen3.6-27b` | 0/3 | 14/38 | 564.2s | 22,370 | ≈3,039 | 37 | 44/4 |
| `qwen3.8-27b` | 2/3 | 18/38 | 1334.4s | 53,241 | ≈38,150 | 17 | 27/0 |

## Historical baseline — not directly comparable

These cloud results used an older, non-identical 65K profile. They are context only, not controlled comparisons with the local 64K runs.

| Task | Model | Result | Score | Time | Turns | Tools/errors |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 01-python-repair | `gpt-5.6-luna (historical baseline)` | PASS | 6/6 | 207.7s | 11 | 22/3 |
| 02-data-reconciliation | `gpt-5.6-luna (historical baseline)` | PASS | 12/12 | 185.8s | 7 | 10/1 |
| 03-dependency-planner | `gpt-5.6-luna (historical baseline)` | PASS | 20/20 | 311.2s | 16 | 27/3 |
