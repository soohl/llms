# Benchmark methodology

The three suites share one CLI but measure different properties. Do not combine
their numbers into one score.

## Speed

`./llm benchmark speed` measures local runtime throughput:

- one model and backend at a time;
- one request stream (`parallel=1`);
- greedy generation with a fixed seed and EOS ignored;
- the same 128–8,192 prompt-token rows and 128 generated tokens; llama.cpp
  additionally records a 16,384-token row;
- llama.cpp evaluates each full prefix with prompt caching disabled and one
  short warm-up request;
- DS4 uses its native incremental-prefix sweep, so its prefill rows measure only
  tokens added since the previous frontier.

Decode results are comparable only when hardware, backend revision,
quantization, context settings, speculative mode, and background load are
equivalent. Prefill results are comparable within one backend methodology, not
between DS4 and llama.cpp. The current suite records one measured pass rather
than a statistical distribution, so rerun small differences before drawing
conclusions. Speculative suite summaries are macro averages across prompts.
Speed results are printed to stdout and create no files.

## Agentic ability

`./llm benchmark agentic` measures outcome quality on three fixed tasks:

- one local `<model> [variant]` per invocation and sequential task
  execution;
- the selected backend is started on an ephemeral local port and stopped after
  the suite;
- speculative decoding is disabled for the standard ability profile;
- a fresh copied workspace and fresh Docker `sbx` per task;
- hidden outcome grading after the agent finishes;
- identical prompts and offline tool definitions;
- no internet, web-search extension, or external credential;
- sandbox network access restricted to the local candidate endpoint;
- fixed 65,536 context, 16,384 maximum output per turn, temperature zero for
  OpenAI-compatible local models, native-strong reasoning, and fixed compaction
  settings;
- one compact `results.jsonl` record containing score, generated-token usage,
  estimated reasoning tokens, elapsed time, and tool/compaction counts.

The 64K profile gives agentic work enough room for long tool sessions. A model
or hardware profile that cannot support the requested context or tool-calling
contract should fail preflight or the run rather than silently receive an
easier profile.

Agentic scores remain a small three-task sample and each command currently
performs one trial. Use repeated invocations when evaluating stochastic or
close results. Native-strong reasoning resolves through each compatibility
profile: the exact control and value are recorded, but internal reasoning
tokens and compute are not normalized across model families.

The report retains GPT-5.6 Luna as a historical baseline only. It is not
runnable from the local benchmark CLI and used an older, non-identical 65K
profile, so use it as context rather than a controlled head-to-head result.

## Web research

`./llm benchmark research` measures sourced web-research quality on three
separate fixed tasks. It retains the agentic suite's local model controls,
sandbox isolation, hidden grading, context, and cleanup policy, but adds the
pinned OpenAI-backed `web_search` tool. Each task requires multiple searches
and multiple distinct tools in addition to an exact research artifact and
official-source citations.

The sandbox cannot access arbitrary public endpoints: only the candidate model
and OpenAI search/authentication endpoints are allowed. Search results can
change over time, so research scores are less reproducible than the offline
agentic suite and should be compared using runs made close together.

## Fair-comparison checklist

1. Run all candidates on the same otherwise-idle host.
2. Use the same model quantization and speculative policy being compared.
3. Keep benchmark defaults unchanged; overrides create a different profile.
4. Run one model at a time and stop unrelated inference workloads.
5. Record backend/model revisions and rerun close outcomes.
6. For research comparisons, use the same pinned search extension/model and
   run date.
