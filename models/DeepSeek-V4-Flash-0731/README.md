# DeepSeek V4 Flash 0731

Local inventory for the 284B-total/13B-active DeepSeek V4 Flash MoE model. The
current profile compares imatrix Q4_K and native MXFP4 weights on a 256 GiB
Apple M3 Ultra. Ordinary target decoding is used; DSpark/MTP is disabled.

## Sources

| Resource | URL |
| --- | --- |
| Official model and model card | <https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash> |
| GGUF repository | <https://huggingface.co/antirez/deepseek-v4-gguf> |
| DS4 backend | <https://github.com/antirez/ds4> |

Review the upstream model and backend licenses before use. Weights are ignored
by Git.

## GGUF inventory

| Variant | GGUF filename | Size (bytes) | SHA-256 | Default |
| --- | --- | ---: | --- | --- |
| `q4` | `DeepSeek-V4-Flash-Q4KExperts-F16HC-F16Compressor-F16Indexer-Q8Attn-Q8Shared-Q8Out-chat-v2-imatrix-0731.gguf` | 164633502592 | `6bb77b5ddcbc2d974c687cfb63d644ecfb295581b4a53fa4c1d810aea538254a` | no |
| `mxfp4` | `DeepSeek-V4-Flash-MXFP4Experts-F16HC-F16Compressor-F16Indexer-Q8Attn-Q8Shared-Q8Out-chat-v2-mxfp4-0731.gguf` | 155976458848 | `0e3a161b670f686128ec5f92a601dfde616a37bf5e7e48999fa2d32471b57ec6` | yes |

The Q4 file uses imatrix Q4_K routed experts. The MXFP4 file preserves the
released native MXFP4 expert weights. Both retain mixed precision for other
components.

## Backend support

| Backend | Status | Revision | Accelerator | Variants | Benchmark |
| --- | --- | --- | --- | --- | --- |
| [`ds4`](https://github.com/antirez/ds4) | tested | `84cc882352757baf628a1776badf7cc54d584e28` | Apple Metal | `q4`, `mxfp4` | [BENCHMARK.md](BENCHMARK.md) |
| [`llama.cpp`](https://github.com/ggml-org/llama.cpp) | planned | — | — | — | Not available |

Planned means no working or tuned repository profile exists yet; the runner
will reject that selection rather than pretend it is supported.

## Setup and download

From the repository root:

```sh
./llm setup deepseek ds4
./llm download deepseek mxfp4
./llm download deepseek q4
```

Setup clones the shared backend into root `backends/ds4`, pins the revision
above, and builds it. The download command requires the Hugging Face `hf` CLI,
honors `HF_TOKEN`, and stores weights in `gguf/`. Disk use is about 165 GB for
Q4 and 156 GB for MXFP4. The tuned resident profile requires 256 GiB unified
memory. The variant is mandatory to prevent accidental large downloads. See
the root README for fresh-machine prerequisites.

## Tuned server

```sh
./llm serve deepseek ds4         # MXFP4 default
./llm serve deepseek ds4 q4      # optional Q4 variant
```

| Setting | Tuned value |
| --- | ---: |
| Model placement | Fully resident Metal |
| Total context | 65,536 tokens |
| Prefill chunk | 8,192 tokens |
| KV prefix-cache budget | 32 GiB |
| Host and port | `127.0.0.1:8000` |
| Kernel geometry | Automatic |
| Speculative decoding | Disabled |

The 8,192-token prefill chunk was the fastest retained long-context tuning
point; 16,384 failed in the tested Metal attention prefill path. Do not expose
the unauthenticated server directly to the internet.

Optional overrides are `LLM_CTX`, `LLM_PREFILL_CHUNK`, `LLM_HOST`, `LLM_PORT`,
and `LLM_KV_DISK_SPACE_MB`.

## Benchmark

```sh
./llm benchmark deepseek ds4 q4
./llm benchmark deepseek ds4 mxfp4
```

The command uses the repository-wide 128–8,192 context sweep and prints DS4's
result table to standard output. It creates no benchmark artifact. An agent
running the benchmark should copy a representative result into
[`BENCHMARK.md`](BENCHMARK.md).

Benchmark overrides are `LLM_BENCH_CTX_START`, `LLM_BENCH_CTX_MAX`,
`LLM_BENCH_CTX_ALLOC`, `LLM_BENCH_STEP_MUL`, `LLM_BENCH_GEN_TOKENS`, and
`LLM_PREFILL_CHUNK`.

## Known limitations

- Only DS4 on the tested Metal machine is currently supported.
- The benchmark measures throughput, not model quality.
- DSpark/MTP and SSD expert streaming are outside the current tuned profile.
