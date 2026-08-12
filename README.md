# Local LLM Inventory

A clean inventory of local models, their GGUF files, tuned inference backends,
and comparable benchmark results. Model weights and backend source trees stay
local; configuration, documentation, and selected results stay in Git.

## Interface

One script handles the repository:

```sh
./llm list
./llm setup <model> <backend>
./llm download <model> <variant>
./llm serve <model> <backend> [variant]
./llm benchmark <model> <backend> [variant]
```

Short names work, so the current model can be started with:

```sh
./llm setup deepseek ds4
./llm download deepseek mxfp4
./llm serve deepseek ds4
```

DeepSeek serving and benchmarking default to `mxfp4`. Downloads always require
an explicit `mxfp4` or `q4` variant to prevent accidental 150+ GB downloads.

`serve` applies the best known tuning for that exact model/backend combination.
`LLM_*` environment variables can override it for experiments.

## Requirements

The current tested combination requires:

- Apple Silicon macOS with enough memory for the selected model (256 GiB for
  the tuned resident DeepSeek profile);
- Git, Make, and a C compiler (install Apple's Xcode Command Line Tools with
  `xcode-select --install` if needed);
- the Hugging Face CLI for model downloads (`brew install hf`); and
- roughly 165 GB of free disk space per GGUF, plus backend build and cache
  space.

Public files do not require authentication. Set `HF_TOKEN` if Hugging Face
requires authentication in your environment.

## Inventory

| Model | GGUF variants | Tested backend | Results | Guide |
| --- | --- | --- | --- | --- |
| DeepSeek V4 Flash 0731 | `q4`, `mxfp4` | `ds4` | [BENCHMARK.md](models/DeepSeek-V4-Flash-0731/BENCHMARK.md) | [README](models/DeepSeek-V4-Flash-0731/README.md) |

`llama.cpp` is planned for DeepSeek but is not marked supported until a working,
tuned server profile and comparable benchmark exist.

## Structure

```text
.
├── llm
├── backends/
│   ├── ds4/                         ignored shared backend checkout
│   └── llamacpp/                    added once supported
├── benchmark/prompts/               shared benchmark input
└── models/
    └── <Model-Name>/
        ├── README.md                sources, support and tuning
        ├── BENCHMARK.md             results grouped by backend
        └── gguf/                    ignored model files
```

Each model has one readable benchmark document with a section for each tested
backend. The benchmark command prints results to the terminal and creates no
result artifact. An agent can copy a representative result into `BENCHMARK.md`.

## Common benchmark

The default benchmark is a greedy, single-stream context sweep over the shared
`benchmark/prompts/promessi-sposi.txt` input:

| Setting | Default |
| --- | ---: |
| Context range | 128–8,192 tokens |
| Step multiplier | 2 |
| Generated tokens | 128 |
| Prefill chunk | 8,192 tokens |

Use the same workload for every supported model/backend combination. Summaries
must expose context, prefill throughput, generated tokens, and decode
throughput. Hardware, backend revision, and deviations from the common workload
belong in `BENCHMARK.md`.

## Adding a model or backend

Use [`models/MODEL_README.template.md`](models/MODEL_README.template.md) for
every model README. Add `models/<Model-Name>/gguf/` and reuse a checkout under
root `backends/`. Then add the small model/backend case to `llm`, including
pinned setup, tuned server arguments, and the common benchmark command. Do not
add separate launchers or raw result files.
