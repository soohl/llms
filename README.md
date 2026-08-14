# Local LLM Directory

A local directory of GGUF models, tuned backends, and comparable benchmarks.
Weights and backend checkouts stay untracked.

## Commands

```sh
./llm list
./llm setup <model>
./llm download <model> <variant>
./llm download <model> <variant> --speculative
./llm serve <model> [variant]
./llm benchmark speed <model> [variant]
./llm benchmark agentic <model> [variant]
```

Muse example:

```sh
./llm setup muse-glimmer-30b
./llm download muse-glimmer-30b kquant-17gb
./llm download muse-glimmer-30b kquant-17gb --speculative
./llm serve muse-glimmer-30b
./llm benchmark speed muse-glimmer-30b
```

`serve` uses tuned values from the model's `model.conf`. `LLM_*` environment
variables override them.

Use `--speculative on|off` for serving. Speed benchmarks also accept
`--speculative compare` to report target-only and model-specific speculative
decoding over `benchmarks/speed/speculative.json`. Backend adapters own the
runtime details; the top-level `llm` command discovers configuration variables
dynamically and contains no backend-specific variable list.

## Models

| Model | Variant | Backend | Hardware | Docs |
| --- | --- | --- | --- | --- |
| DeepSeek V4 Flash 0731 | `q4`, `mxfp4` | `ds4` | Apple M3 Ultra, 256 GiB | [Guide](models/DeepSeek-V4-Flash-0731/README.md) · [Results](models/DeepSeek-V4-Flash-0731/BENCHMARK.md) |
| Gemma 4 31B | `q4-0` | `llamacpp` | NVIDIA RTX 4090, 24 GB | [Guide](models/Gemma-4-31B/README.md) · [Results](models/Gemma-4-31B/BENCHMARK.md) |
| Muse Glimmer 30B | `kquant-17gb` + DFlash | `llamacpp` | NVIDIA RTX 4090, 24 GB | [Guide](models/Muse-Glimmer-30B/README.md) · [Results](models/Muse-Glimmer-30B/BENCHMARK.md) |
| Qwen3.6 27B | `q4-k-m` | `llamacpp` | NVIDIA RTX 4090, 24 GB | [Guide](models/Qwen3.6-27B/README.md) · [Results](models/Qwen3.6-27B/BENCHMARK.md) |

## Layout

```text
backends/scripts/       backend setup, serve, and benchmark adapters
backends/config/        pinned backend revisions and build settings
compat/                 reusable local API and chat-template profiles
benchmarks/speed/       shared speed benchmark inputs
benchmarks/scripts/     speed benchmark helpers
benchmarks/agentic/     containerized long-horizon agent benchmark
models/<Model>/         model.conf, docs, results, and ignored gguf/
llm                     model discovery and command dispatch
```

Models are discovered from `models/*/model.conf`; model paths are not
hard-coded in `llm`. Add a model by copying
[`TEMPLATE_MODEL.conf`](models/TEMPLATE_MODEL.conf) and
[`TEMPLATE_README.md`](models/TEMPLATE_README.md). A new backend
type also needs config under `backends/config/` and an adapter under
`backends/scripts/`. Each model selects a reusable `COMPAT_PROFILE` from
`compat/`; the resolver configures Pi's API dialect and any chat-template
server settings. Model settings use backend prefixes such as `LLAMACPP_*` and
`DS4_*`; portable runtime overrides retain the `LLM_*` prefix.

Downloads pin the source repository revision and verify size and SHA-256. The
variant name is uppercased and
non-alphanumeric characters become underscores: variant `q4-k-m`, for example,
uses `DOWNLOAD_Q4_K_M_FILE`, `DOWNLOAD_Q4_K_M_SIZE`, and
`DOWNLOAD_Q4_K_M_SHA256`. Optional speculative
artifacts shared by all variants use `DOWNLOAD_SPECULATIVE_FILE` and
corresponding size/SHA variables; a variant can override them with, for example,
`DOWNLOAD_Q4_K_M_SPECULATIVE_FILE` and
`DOWNLOAD_Q4_K_M_SPECULATIVE_SIZE`.

`setup` creates ignored source/build trees under `backends/`; `download` stores
ignored weights under each model's `gguf/`. Temporary download and runtime
caches stay in ignored local directories.

## Benchmarks

See [`benchmarks/README.md`](benchmarks/README.md) for fairness rules,
comparability limits, and the shared benchmark methodology.

### Speed

The speed benchmark is a greedy single-stream sweep over
`benchmarks/speed/promessi-sposi.txt`, with 128 generated tokens. llama.cpp
sweeps 128–16,384 prompt tokens after one short warm-up request; DS4 performs
its native 128–8,192 incremental-prefix sweep. Commands print results and create
no artifact.

```sh
./llm benchmark speed muse-glimmer-30b
./llm benchmark speed muse-glimmer-30b kquant-17gb --speculative compare
```

### Agentic ability

The outcome-graded agent suite accepts the same local `<model> [variant]`
identity as the speed suite; the model configuration selects the backend. Every task gets a
fresh Docker `sbx` sandbox; Pi, its tools, the task workspace, and the hidden
grader all execute in that sandbox. The standard profile fixes context at
65,536 tokens, maximum output at 4,096, temperature at zero, and compaction
settings across models. Reasoning uses each model's compatibility-profile
definition of `native-strong`; it is not a normalized reasoning-token budget.

```sh
# Docker Sandboxes prerequisite (macOS)
brew install --cask docker/tap/sbx
sbx diagnose
pi install npm:pi-web-search@1.3.1
pi auth check --provider openai-codex

./llm benchmark agentic deepseek-v4-flash-0731 mxfp4
./llm benchmark agentic report
```

The runner starts the selected backend and variant on an ephemeral local port,
then creates an isolated, temporary Pi provider for it. Candidate inference
stays local; `pi-web-search` uses `openai-codex/gpt-5.6-luna` only when the
local agent calls `web_search`. The local server URL is rewritten to
`host.docker.internal` for `sbx`, and the server is stopped after the suite.
Temporary workspaces, sessions, logs, and credentials are deleted after each
task. Only `benchmarks/agentic/results.jsonl` and its generated `REPORT.md`
remain. See
[`benchmarks/agentic/README.md`](benchmarks/agentic/README.md) for task
selection and model-limit overrides.
