# Web research benchmark

This suite measures whether a local model can gather, reconcile, and record
facts from the web. It is separate from the offline agentic suite.

The three tasks cover:

1. **Easy — standards lookup:** verify Python packaging metadata and name
   normalization against official specifications.
2. **Medium — standards synthesis:** combine three HTTP RFCs into one retry and
   redirect policy.
3. **Hard — incident triangulation:** reconcile primary and vendor sources for
   the XZ Utils supply-chain compromise.

Each task has a hidden outcome grader and a minimum number of `web_search`
calls. A run also has to use multiple distinct tools, so an answer based on one
search response is invalid even when its facts happen to be correct. The
requirements are stored in `tasks.json` and reported with every result.

The runner uses the same local model, native-strong reasoning, 65,536-token
context, 4,096-token output limit, fresh Docker `sbx` workspace, temporary
artifacts, and sequential execution as the agentic suite. Internet access is
available only through `pi-web-search@1.3.1` using
`openai-codex/gpt-5.6-luna`; shell commands cannot reach the public internet.
The sandbox network allowlist contains the local model endpoint plus
`chatgpt.com:443` and `auth.openai.com:443`.

## Run

```sh
./llm benchmark research self-test
./llm benchmark research deepseek-v4-flash-0731 mxfp4
./llm benchmark research deepseek-v4-flash-0731 mxfp4 \
  --task 03-xz-incident
./llm benchmark research report
```

Only compact metrics and scores are retained in `results.jsonl` and
`REPORT.md`. Workspaces, search output, sessions, logs, sandbox configuration,
and credentials are deleted after every task.
