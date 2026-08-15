# Qwen3.6 27B

Dense coding and reasoning model using the official Q4_K_M GGUF. The 19.1 GB
quant leaves enough of the RTX 4090's 24 GB VRAM for an 8,192-token F16 KV
cache. Vision is opt-in.

## Sources

- [Official model](https://huggingface.co/Qwen/Qwen3.6-27B)
- [Official GGUF](https://huggingface.co/ggml-org/Qwen3.6-27B-GGUF)
- [DFlash drafter GGUF](https://huggingface.co/Alittlehammmer/Qwen3.6-27B-DFlash-GGUF-llama.cpp)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)

Model and drafter artifacts are Apache 2.0 and ungated; llama.cpp is MIT.

## Files

| Variant | Size | SHA-256 |
| --- | ---: | --- |
| `q4-k-m` | 19,095,766,304 | `65b753ea835627f7b511143c6ceb976525c7f21f5df8c664bc0a9c23d1c49921` |
| DFlash Q8_0 drafter | 1,849,481,440 | `23b6c8ebcc51b3b4107709342fd2960167e88397af36e394923b8d5895ddf7ea` |
| Q8_0 vision projector | 629,247,104 | `dd184a692287f0d7e8fa56c8744df20c46667818efc04e6d48996d18d9521a4e` |

## Run

```sh
./llm setup qwen3.6-27b
./llm download qwen3.6-27b q4-k-m
./llm download qwen3.6-27b q4-k-m --speculative
./llm download qwen3.6-27b q4-k-m --vision
./llm serve qwen3.6-27b q4-k-m
./llm serve qwen3.6-27b q4-k-m --vision
./llm benchmark speed qwen3.6-27b q4-k-m
./llm benchmark agentic qwen3.6-27b q4-k-m
```

Defaults: 8,192 context, full target CUDA offload, Flash Attention, F16 KV, and
the official thinking-mode sampling values. The tested server used 19,150 MiB
VRAM, while DFlash used 20,702 MiB. DFlash macro-averages 1.60x in the prompt
suite. The vision smoke test identified a red image and used 20,024 MiB;
vision plus DFlash used 21,600 MiB. Both features are opt-in; see
[BENCHMARK.md](BENCHMARK.md).

The `llamacpp-qwen` compatibility profile enables the embedded Jinja template
and tells Pi to use Qwen's per-request chat-template thinking controls.
