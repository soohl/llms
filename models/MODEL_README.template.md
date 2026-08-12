# <Model name>

One-paragraph description of why this model is in the local inventory, its
architecture/use case, and the hardware targeted by the current configuration.
Copy this file to `models/<Model-Name>/README.md`.

## Sources

| Resource | URL |
| --- | --- |
| Official model repository | <URL> |
| GGUF repository | <URL> |
| Model card or paper | <URL> |

State the model license and any access restrictions. Do not commit model
weights.

## Local inventory

| Variant | GGUF filename | Quantization | Size | SHA-256 | Default |
| --- | --- | --- | ---: | --- | --- |
| `<variant>` | `<file>.gguf` | `<quant>` | `<bytes>` | `<digest>` | yes/no |

Document optional support files separately.

## Backend support

Use **tested** only when setup, tuned serving, and the common benchmark work.
Otherwise use **planned**.

| Backend | Status | Revision/version | Accelerator | Variants | Benchmark |
| --- | --- | --- | --- | --- | --- |
| `<backend>` | tested | `<revision>` | Metal/CUDA/CPU | `<variants>` | [`BENCHMARK.md`](BENCHMARK.md) |
| `llama.cpp` | planned | — | — | — | — |

## Setup and download

All commands run from the repository root:

```sh
./llm setup <model> <backend>
./llm download <model> <variant>
```

List required tools, authentication variables, expected disk/RAM use, and any
backend-specific build requirements. Backends are shared checkouts under root
`backends/`, not copied into model directories.

## Serve

```sh
./llm serve <model> <backend> [variant]
```

Document the endpoint, API shape, defaults, and supported environment
overrides. State whether the server is safe to expose directly.

## Benchmark

```sh
./llm benchmark <model> <backend> [variant]
```

Describe the common workload, environment overrides, and hardware. The command
must print results and create no artifact. Summarize representative output in
one `BENCHMARK.md`.

## Current tuning

| Setting | Value | Reason |
| --- | --- | --- |
| Context | `<tokens>` | <reason> |
| Prefill chunk/batch | `<value>` | <reason> |
| Accelerator/offload | `<value>` | <reason> |
| KV cache | `<value>` | <reason> |
| Sampling | `<value>` | <reason> |

Clearly distinguish the current reproducible profile from historical
experiments. Record assumptions that affect comparability.

## Results

Link to `BENCHMARK.md`, which should contain one section per tested backend
with hardware, backend revision, variants, tuning, and comparable tables.

## Known limitations

- <unsupported capability, hardware constraint, or open issue>
