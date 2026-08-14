#!/usr/bin/env python3

"""Run the repository's common context sweep through llama-server."""

import argparse
import json
import socket
import subprocess
import time
import urllib.error
import urllib.request


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--server", required=True)
    parser.add_argument("--model", required=True)
    parser.add_argument("--projector-file", default="")
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--ctx-start", type=int, required=True)
    parser.add_argument("--ctx-max", type=int, required=True)
    parser.add_argument("--step", type=int, required=True)
    parser.add_argument("--generated", type=int, required=True)
    parser.add_argument("--batch", required=True)
    parser.add_argument("--ubatch", required=True)
    parser.add_argument("--speculative-batch")
    parser.add_argument("--speculative-ubatch")
    parser.add_argument("--threads", required=True)
    parser.add_argument("--cache-type", required=True)
    parser.add_argument("--device", required=True)
    parser.add_argument("--gpu-layers", required=True)
    parser.add_argument(
        "--speculative", choices=("off", "on", "compare"), default="off"
    )
    parser.add_argument("--speculative-kind", default="")
    parser.add_argument("--speculative-file", default="")
    parser.add_argument("--speculative-gpu-layers", default="99")
    parser.add_argument("--speculative-max-tokens", default="4")
    parser.add_argument("--speculative-context", type=int, default=32768)
    parser.add_argument("--speculative-prompts")
    return parser.parse_args()


def context_sweep(start, maximum, step):
    if start <= 0 or maximum < start or step <= 1:
        raise SystemExit("invalid benchmark context or step setting")
    contexts = []
    value = start
    while value <= maximum:
        contexts.append(value)
        value *= step
    if contexts[-1] != maximum:
        raise SystemExit("context maximum is not reached by the step multiplier")
    return contexts


def free_port():
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def server_command(args, port, context_size, speculative):
    batch = args.speculative_batch if speculative else args.batch
    ubatch = args.speculative_ubatch if speculative else args.ubatch
    command = [
        args.server,
        "--model",
        args.model,
        "--device",
        args.device,
        "--n-gpu-layers",
        args.gpu_layers,
        "--ctx-size",
        str(context_size),
        "--parallel",
        "1",
        "--batch-size",
        batch,
        "--ubatch-size",
        ubatch,
        "--threads",
        args.threads,
        "--threads-batch",
        args.threads,
        "--cache-type-k",
        args.cache_type,
        "--cache-type-v",
        args.cache_type,
        "--flash-attn",
        "on",
        "--host",
        "127.0.0.1",
        "--port",
        str(port),
    ]
    if args.projector_file:
        command.extend(["--mmproj", args.projector_file])
    if speculative:
        if args.speculative_kind != "dflash":
            raise SystemExit(
                f"unsupported llama.cpp speculative type: "
                f"{args.speculative_kind or 'none'}"
            )
        if not args.speculative_file:
            raise SystemExit("speculative model file is not configured")
        command.extend(
            [
                "--spec-type",
                "draft-dflash",
                "--spec-draft-model",
                args.speculative_file,
                "--spec-draft-device",
                args.device,
                "--spec-draft-ngl",
                args.speculative_gpu_layers,
                "--spec-draft-n-max",
                args.speculative_max_tokens,
            ]
        )
    return command


def run_server(args, context_size, speculative, workload):
    port = free_port()
    base_url = f"http://127.0.0.1:{port}"
    process = subprocess.Popen(
        server_command(args, port, context_size, speculative),
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    def request(path, payload=None):
        data = None if payload is None else json.dumps(payload).encode()
        request_object = urllib.request.Request(
            base_url + path,
            data=data,
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(request_object, timeout=600) as response:
            return json.load(response)

    try:
        deadline = time.monotonic() + 120
        while True:
            if process.poll() is not None:
                raise SystemExit("llama-server exited while loading the model")
            try:
                request("/health")
                break
            except (OSError, urllib.error.URLError):
                if time.monotonic() >= deadline:
                    raise SystemExit("timed out waiting for llama-server")
                time.sleep(0.25)
        request(
            "/completion",
            {
                "prompt": "Warm up.",
                "n_predict": 8,
                "temperature": 0,
                "seed": 42,
                "ignore_eos": True,
                "cache_prompt": False,
            },
        )
        return workload(request)
    finally:
        process.terminate()
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()


def run_profile(args, contexts, speculative):
    def workload(request):
        with open(args.prompt, encoding="utf-8") as prompt_file:
            prompt = prompt_file.read()
        tokens = request(
            "/tokenize", {"content": prompt, "add_special": True}
        )["tokens"]
        if len(tokens) < args.ctx_max:
            raise SystemExit(
                f"shared prompt has only {len(tokens)} tokens; "
                f"need {args.ctx_max}"
            )

        rows = []
        for context in contexts:
            result = request(
                "/completion",
                {
                    "prompt": tokens[:context],
                    "n_predict": args.generated,
                    "temperature": 0,
                    "seed": 42,
                    "ignore_eos": True,
                    "cache_prompt": False,
                },
            )
            timings = result["timings"]
            rows.append(
                {
                    "context": context,
                    "prefill": timings["prompt_per_second"],
                    "generated": timings["predicted_n"],
                    "decode": timings["predicted_per_second"],
                }
            )
        return rows

    return run_server(
        args, args.ctx_max + args.generated + 1, speculative, workload
    )


def run_speculative_suite(args, speculative):
    with open(args.speculative_prompts, encoding="utf-8") as prompt_file:
        prompts = json.load(prompt_file)

    def workload(request):
        rows = []
        for item in prompts:
            result = request(
                "/completion",
                {
                    "prompt": item["prompt"],
                    "n_predict": args.generated,
                    "temperature": 0,
                    "seed": 42,
                    "ignore_eos": True,
                    "cache_prompt": False,
                },
            )
            timings = result["timings"]
            rows.append(
                {
                    "name": item["name"],
                    "prompt_tokens": timings["prompt_n"],
                    "generated": timings["predicted_n"],
                    "prefill": timings["prompt_per_second"],
                    "decode": timings["predicted_per_second"],
                    "drafted": timings.get("draft_n", 0),
                    "accepted": timings.get("draft_n_accepted", 0),
                }
            )
        return rows

    return run_server(
        args, max(args.speculative_context, args.generated + 4096),
        speculative, workload
    )


def print_single(rows):
    print("| Context | Prefill | Generated | Decode |")
    print("| ---: | ---: | ---: | ---: |")
    for row in rows:
        print(
            f"| {row['context']:,} | {row['prefill']:.2f} t/s "
            f"| {row['generated']:,} | {row['decode']:.2f} t/s |"
        )


def print_comparison(target_rows, speculative_rows):
    print(
        "| Context | Target prefill | Spec prefill | Generated "
        "| Target decode | Spec decode | Speedup |"
    )
    print("| ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
    for target, speculative in zip(target_rows, speculative_rows, strict=True):
        speedup = speculative["decode"] / target["decode"]
        print(
            f"| {target['context']:,} | {target['prefill']:.2f} t/s "
            f"| {speculative['prefill']:.2f} t/s "
            f"| {target['generated']:,} | {target['decode']:.2f} t/s "
            f"| {speculative['decode']:.2f} t/s | {speedup:.2f}x |"
        )


def print_speculative_suite(target_rows, speculative_rows):
    print(
        "| Prompt | Prompt tokens | Generated | Target decode "
        "| Spec decode | Speedup | Acceptance |"
    )
    print("| --- | ---: | ---: | ---: | ---: | ---: | ---: |")
    for target, speculative in zip(target_rows, speculative_rows, strict=True):
        speedup = speculative["decode"] / target["decode"]
        drafted = speculative["drafted"]
        acceptance = speculative["accepted"] / drafted if drafted else 0
        print(
            f"| {target['name']} | {target['prompt_tokens']:,} "
            f"| {target['generated']:,} | {target['decode']:.2f} t/s "
            f"| {speculative['decode']:.2f} t/s | {speedup:.2f}x "
            f"| {acceptance:.1%} |"
        )
    target_average = sum(row["decode"] for row in target_rows) / len(target_rows)
    spec_average = sum(row["decode"] for row in speculative_rows) / len(
        speculative_rows
    )
    accepted = sum(row["accepted"] for row in speculative_rows)
    drafted = sum(row["drafted"] for row in speculative_rows)
    print(
        f"| **Macro average** | — | — | **{target_average:.2f} t/s** "
        f"| **{spec_average:.2f} t/s** | **{spec_average / target_average:.2f}x** "
        f"| **{accepted / drafted:.1%}** |"
    )


def main():
    args = parse_args()
    if args.generated <= 0:
        raise SystemExit("generated token count must be positive")
    contexts = context_sweep(args.ctx_start, args.ctx_max, args.step)
    if args.speculative == "compare":
        if args.speculative_prompts:
            target = run_speculative_suite(args, speculative=False)
            speculative = run_speculative_suite(args, speculative=True)
            print_speculative_suite(target, speculative)
        else:
            target = run_profile(args, contexts, speculative=False)
            speculative = run_profile(args, contexts, speculative=True)
            print_comparison(target, speculative)
    else:
        rows = run_profile(
            args, contexts, speculative=args.speculative == "on"
        )
        print_single(rows)


if __name__ == "__main__":
    main()
