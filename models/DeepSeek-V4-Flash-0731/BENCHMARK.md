# DeepSeek V4 Flash 0731 Benchmarks

- Backend: DS4 `84cc882352757baf628a1776badf7cc54d584e28`
- Hardware: Apple M3 Ultra, 256 GiB unified memory
- Workload: shared 128–8,192 context sweep, 128 generated tokens
- Tuning: fully resident Metal, 8,192 prefill chunk, DSpark/MTP off

| Context | Q4 prefill | MXFP4 prefill | Q4 decode | MXFP4 decode |
| ---: | ---: | ---: | ---: | ---: |
| 128 | 139.14 t/s | 141.74 t/s | 39.71 t/s | 41.43 t/s |
| 256 | 164.37 t/s | 166.36 t/s | 39.58 t/s | 41.53 t/s |
| 512 | 234.55 t/s | 241.00 t/s | 38.38 t/s | 41.35 t/s |
| 1,024 | 312.71 t/s | 315.58 t/s | 39.49 t/s | 41.20 t/s |
| 2,048 | 388.17 t/s | 389.70 t/s | 39.76 t/s | 40.59 t/s |
| 4,096 | 409.30 t/s | 439.24 t/s | 36.60 t/s | 36.99 t/s |
| 8,192 | 423.37 t/s | 447.08 t/s | 35.37 t/s | 36.60 t/s |

MXFP4 is smaller and about 4% faster, so it is the default.

```sh
./llm benchmark deepseek-v4-flash-0731 ds4 mxfp4
```
