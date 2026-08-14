# Web research benchmark

| Task | Difficulty | Model | Result | Score | Time | Generated | Reasoning est. | Turns | Tools/errors | Cache R/W | Compactions |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 01-python-standards | easy | `deepseek-v4-flash-0731` | PASS | 8/8 | 66.8s | 1,228 | ≈262 | 8 | 8/0 | 28,626/4,018 | 0 |
| 01-python-standards | easy | `gemma-4-31b` | PASS | 8/8 | 62.9s | 1,465 | ≈804 | 6 | 5/0 | 18,119/0 | 0 |
| 01-python-standards | easy | `muse-glimmer-30b` | PASS | 8/8 | 139.1s | 3,382 | ≈2,149 | 14 | 15/0 | 101,736/0 | 0 |
| 01-python-standards | easy | `qwen3.6-27b` | PASS | 8/8 | 38.3s | 874 | ≈208 | 4 | 4/0 | 11,764/0 | 0 |
| 02-http-retry-policy | medium | `deepseek-v4-flash-0731` | PASS | 14/14 | 103.5s | 2,100 | ≈480 | 6 | 13/0 | 24,913/5,624 | 0 |
| 02-http-retry-policy | medium | `gemma-4-31b` | PASS | 14/14 | 77.6s | 2,397 | ≈1,289 | 3 | 4/0 | 8,723/0 | 0 |
| 02-http-retry-policy | medium | `muse-glimmer-30b` | PASS | 14/14 | 133.9s | 2,833 | ≈1,718 | 8 | 13/0 | 53,329/0 | 0 |
| 02-http-retry-policy | medium | `qwen3.6-27b` | PASS | 14/14 | 78.8s | 2,033 | ≈740 | 6 | 12/0 | 33,955/0 | 0 |
| 03-xz-incident | hard | `deepseek-v4-flash-0731` | FAIL | 15/20 | 113.5s | 1,622 | ≈322 | 7 | 9/0 | 37,461/7,386 | 0 |
| 03-xz-incident | hard | `gemma-4-31b` | FAIL | 15/20 | 114.4s | 3,550 | ≈1,851 | 4 | 6/0 | 20,614/0 | 0 |
| 03-xz-incident | hard | `muse-glimmer-30b` | FAIL | 15/20 | 201.2s | 3,944 | ≈2,144 | 10 | 17/0 | 97,216/0 | 0 |
| 03-xz-incident | hard | `qwen3.6-27b` | FAIL | 9/20 | 128.7s | 3,029 | ≈787 | 8 | 12/0 | 66,196/0 | 0 |

## Totals

| Model | Tasks passed | Task score | Time | Generated | Reasoning est. | Turns | Tools/errors |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `deepseek-v4-flash-0731` | 2/3 | 37/42 | 283.9s | 4,950 | ≈1,064 | 21 | 30/0 |
| `gemma-4-31b` | 2/3 | 37/42 | 254.8s | 7,412 | ≈3,944 | 13 | 15/0 |
| `muse-glimmer-30b` | 2/3 | 37/42 | 474.2s | 10,159 | ≈6,011 | 32 | 45/0 |
| `qwen3.6-27b` | 2/3 | 31/42 | 245.8s | 5,936 | ≈1,735 | 18 | 28/0 |
