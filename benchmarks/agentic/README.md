# Local agentic ability benchmark

This suite has three outcome-graded tasks with graders hidden from the agent:

1. **Easy — focused Python repair:** diagnose a compact library regression and
   pass behavioral tests.
2. **Medium — data reconciliation:** normalize messy CSV/JSON exports and
   generate exact artifacts.
3. **Hard — dependency planner:** implement a deterministic CLI and algorithms
   from a behavioral contract.

The design follows useful aspects of SWE-bench and Terminal-Bench: realistic
workspace state, outcome-based hidden verification, fresh sandboxes, and
observable final artifacts. It remains small and locally reproducible.

The runner accepts one repository-local `<model> [variant]` per invocation,
matching the speed benchmark CLI. The model configuration selects the backend.
The benchmark candidate must be local; the separate search tool uses OpenAI.
All models use:

- the currently installed Pi runtime;
- native-strong reasoning, resolved to each model's native control;
- a 65,536-token context and 4,096-token maximum output;
- temperature zero for OpenAI-compatible local models;
- a 2,048-token compaction reserve and 1,024 recent tokens;
- identical prompts, tools, and agent settings;
- `pi-web-search` pinned to `openai-codex/gpt-5.6-luna`;
- speculative decoding disabled;
- a fresh Docker `sbx` sandbox for every task;
- Pi, tools, task commands, and hidden grading inside the sandbox;
- network access limited to the host's local model endpoint and OpenAI search
  and authentication endpoints;
- sequential execution.

Only the selected local provider configuration, fixed benchmark/search
settings, placeholder local credential, and OpenAI Codex search credential are
placed in the sandbox with `sbx cp`. The private staging directory is deleted
after setup. Saved configuration is redacted and no credential is retained in
run artifacts. No `sbx secret` is used. Custom provider loopback URLs are
rewritten to `host.docker.internal`.

## Prerequisites

Install and initialize Docker Sandboxes. On macOS:

```sh
brew install --cask docker/tap/sbx
sbx diagnose
pi install npm:pi-web-search@1.3.1
pi auth check --provider openai-codex
```

The runner starts the selected backend and variant on an ephemeral local port,
creates a temporary Pi provider, rewrites localhost to
`host.docker.internal` for the sandbox, and stops the server after the suite.
The candidate model remains local. OpenAI Codex is available only behind
`web_search` and does not answer the benchmark task directly.

`native-strong` means DS4 `effort=high`, Qwen and Gemma thinking enabled, and
Muse `strength=high`. These are native recommended/strong modes, not equal
internal reasoning-token budgets. The resolved control is saved in
`results.jsonl`.

## CLI

```sh
./llm benchmark agentic self-test

# Run all tasks with the same model/backend/variant identity as speed.
./llm benchmark agentic deepseek-v4-flash-0731 mxfp4

# Run one task or override model limits for a controlled comparison.
./llm benchmark agentic deepseek-v4-flash-0731 mxfp4 \
  --task 03-dependency-planner \
  --context-window 65536 --max-output 16384

./llm benchmark agentic report
```

The workspace, Pi session, event stream, stderr, credentials, and server log
exist only in temporary directories and are deleted after every run, including
failures. One compact line is appended to `results.jsonl`; `REPORT.md` is
regenerated from that ledger. Run `./llm benchmark agentic --help` for all
controls.

Reports include exact generated/output tokens summed across model turns.
Reasoning tokens are marked as estimates and use Pi's conservative
`ceil(reasoning characters / 4)` heuristic because the local OpenAI-compatible
servers do not provide a reliable reasoning-token usage breakdown.

`REPORT.md` also retains GPT-5.6 Luna as a historical ability baseline. Luna is
not exposed by the local-only CLI, and its older 65K configuration is clearly
marked as non-identical to the current local 64K profile.
