# Web research benchmark

| Task | Difficulty | Model | Result | Score | Time | Generated | Reasoning est. | Turns | Tools/errors | Cache R/W | Compactions |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 01-python-standards | easy | `deepseek-v4-flash-0731` | PASS | 8/8 | 66.8s | 1,228 | ≈262 | 8 | 8/0 | 28,626/4,018 | 0 |
| 02-http-retry-policy | medium | `deepseek-v4-flash-0731` | PASS | 14/14 | 103.5s | 2,100 | ≈480 | 6 | 13/0 | 24,913/5,624 | 0 |
| 03-xz-incident | hard | `deepseek-v4-flash-0731` | FAIL | 15/20 | 113.5s | 1,622 | ≈322 | 7 | 9/0 | 37,461/7,386 | 0 |

## Totals

| Model | Tasks passed | Task score | Time | Generated | Reasoning est. | Turns | Tools/errors |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `deepseek-v4-flash-0731` | 2/3 | 37/42 | 283.9s | 4,950 | ≈1,064 | 21 | 30/0 |
