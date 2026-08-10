# infer_llm

> ### ⚠️ Very early work — built for a workshop, not for production
>
> This package was written for the **Goatmire Elixir workshop** on running
> Nerves on Fairphone 3 hardware. It exists for tinkering and teaching.
>
> It is **not an actively maintained project** (yet). There are no
> stability guarantees, APIs will change without notice, and parts of it
> are wired-but-unproven. Treat it as a starting point to hack on, not as
> a dependency to build a product on.
>
> See [`nerves_ai`](https://github.com/mlainez/nerves_ai) for the full
> stack and the workshop context.

Nx-tensor wrappers for LLM and speech-to-text inference, with a
pluggable native backend.

Part of the [`nerves_ai`](https://github.com/mlainez/nerves_ai) edge-AI
stack. This package is the generic API; the native kernels live behind
the `InferLLM.Backend` behaviour.

## What's here

| Module | What it does | Needs a backend? |
|---|---|---|
| `InferLLM.Whisper` | Whisper speech-to-text | yes |
| `InferLLM.Primitives` | RMSNorm, RoPE, linear, causal masks | see caveat |
| `InferLLM.KVCache` | KV cache for autoregressive decode | no — pure Nx |
| `InferLLM.Sampling` | top-k / top-p / temperature / repetition penalty | no — pure Nx |
| `InferLLM.Bench.TinyLM` | Micro-benchmark for a tiny transformer | — |

## Install

```elixir
defp deps do
  [
    {:infer_llm, github: "mlainez/infer_llm"},
    # plus a backend — on ARM:
    {:arm_ai, github: "mlainez/arm_ai"}
  ]
end
```

```elixir
config :infer_llm, backend: ArmAI.LLMBackend
```

If you depend on `nerves_ai`, this wiring happens for you at boot.

## Are you sure you want this package?

For **decoder LLMs** — Llama, TinyLlama, SmolLM, Phi, Qwen — you probably
want `ArmAI.LlamaCandle` in the [`arm_ai`](https://github.com/mlainez/arm_ai)
package instead. It's a raw binary token API: token IDs in, token IDs
out, no Nx tensors anywhere, and considerably less overhead.

Reach for `infer_llm` when you want **Whisper STT**, or when you're
building a model out of Nx primitives yourself and want the sampling and
KV-cache helpers.

## Usage

### Whisper STT

```elixir
{:ok, whisper} = InferLLM.Whisper.load(
  model: "/data/models/whisper-tiny.gguf",
  tokenizer: "/data/models/whisper-tokenizer.json",
  mel_filters: "/data/models/whisper-mel-filters.bin",
  config: "/data/models/whisper-config.json"
)

pcm = InferAudio.Decoder.load_for_whisper("/data/clip.mp3")
{:ok, text} = InferLLM.Whisper.transcribe(whisper, pcm)
```

### Sampling and KV cache (pure Nx — no backend needed)

```elixir
cache = InferLLM.KVCache.new(n_layers, n_heads, max_seq, head_dim)
cache = InferLLM.KVCache.append_layer(cache, 0, k_step, v_step)
cache = InferLLM.KVCache.advance(cache)

token = InferLLM.Sampling.sample(logits, temperature: 0.8, top_p: 0.9)
```

## Caveats

`KVCache` and `Sampling` are pure Nx and run on any backend, including
`Nx.BinaryBackend` — useful for host-side testing.

`InferLLM.Primitives` is still coupled directly to `ArmAI.Native` rather
than going through the `InferLLM.Backend` behaviour. Splitting it out is
outstanding work; until then those functions need `arm_ai` present.

## License

Apache-2.0
