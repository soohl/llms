# Local LLM Directory

A local directory of GGUF models, tuned backends, and comparable benchmarks.
Weights and backend checkouts stay untracked.

## Commands

```sh
./llm list
./llm setup <model> <backend>
./llm download <model> <variant>
./llm download <model> <variant> --speculative
./llm serve <model> <backend> [variant]
./llm benchmark <model> <backend> [variant]
```

Muse example:

```sh
./llm setup muse-glimmer-30b llamacpp
./llm download muse-glimmer-30b kquant-17gb
./llm download muse-glimmer-30b kquant-17gb --speculative
./llm serve muse-glimmer-30b llamacpp
./llm benchmark muse-glimmer-30b llamacpp
```

`serve` uses tuned values from the model's `model.conf`. `LLM_*` environment
variables override them.

Use `--speculative on|off` for serving. Benchmarks also accept
`--speculative compare` to report target-only and model-specific speculative
decoding over `benchmark/prompts/speculative.json`.

## Models

| Model | Variant | Backend | Hardware | Docs |
| --- | --- | --- | --- | --- |
| DeepSeek V4 Flash 0731 | `q4`, `mxfp4` | `ds4` | Apple M3 Ultra, 256 GiB | [Guide](models/DeepSeek-V4-Flash-0731/README.md) · [Results](models/DeepSeek-V4-Flash-0731/BENCHMARK.md) |
| Muse Glimmer 30B | `kquant-17gb` + DFlash | `llamacpp` | NVIDIA RTX 4090, 24 GB | [Guide](models/Muse-Glimmer-30B/README.md) · [Results](models/Muse-Glimmer-30B/BENCHMARK.md) |
| Qwen3.6 27B | `q4-k-m` | `llamacpp` | NVIDIA RTX 4090, 24 GB | [Guide](models/Qwen3.6-27B/README.md) · [Results](models/Qwen3.6-27B/BENCHMARK.md) |

## Layout

```text
backends/scripts/       backend setup, serve, and benchmark adapters
backends/config/        pinned backend revisions and build settings
benchmark/prompts/      shared benchmark input
benchmark/scripts/      benchmark helpers
models/<Model>/         model.conf, docs, results, and ignored gguf/
llm                     model discovery and command dispatch
```

Models are discovered from `models/*/model.conf`; model paths are not
hard-coded in `llm`. Add a model by copying
[`TEMPLATE_MODEL.conf`](models/TEMPLATE_MODEL.conf) and
[`TEMPLATE_README.md`](models/TEMPLATE_README.md). A new backend
type also needs config under `backends/config/` and an adapter under
`backends/scripts/`. Model settings use backend prefixes such as `LLAMACPP_*`
and `DS4_*`; portable runtime overrides retain the `LLM_*` prefix.

`setup` creates ignored source/build trees under `backends/`; `download` stores
ignored weights under each model's `gguf/`. Temporary download and runtime
caches stay in ignored local directories.

## Benchmark

The common benchmark is a greedy single-stream sweep over
`benchmark/prompts/promessi-sposi.txt`: 128–8,192 prompt tokens, doubling each
step, with 128 generated tokens. Each server profile receives one short warm-up
request. Commands print results and create no artifact.
