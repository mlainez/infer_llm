# infer_llm

> ### ⚠️ Very early work — built for a workshop, not for production
>
> This package was written for the **Goatmire Elixir workshop** on running
> Nerves on Fairphone 3 hardware. It exists for tinkering and teaching.
>
> There are no stability guarantees and APIs will change without notice.
>
> See [`nerves_ai`](https://github.com/mlainez/nerves_ai) for the full
> stack and the workshop context.

Nx helpers for LLM inference, plus Whisper speech-to-text behind a
pluggable native backend.

Part of the [`nerves_ai`](https://github.com/mlainez/nerves_ai) edge-AI
stack. This package is the generic API; the native kernels live behind
the `InferLLM.Backend` behaviour.

## What's here

| Module | What it does | Needs a backend? |
|---|---|---|
| `InferLLM.Whisper` | Whisper speech-to-text | yes |
| `InferLLM.Primitives` | RMSNorm, RoPE, linear, causal masks | needs `arm_ai` + `nx_arm` |
| `InferLLM.KVCache` | KV cache for autoregressive decode | no — pure Nx |
| `InferLLM.Sampling` | top-k / top-p / temperature / repetition penalty | no — pure Nx |

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

For **decoder LLMs** — Llama, TinyLlama, SmolLM GGUF files — you probably
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
  model: "/data/models/whisper-tiny-en-q80.gguf",
  tokenizer: "/data/models/whisper-tokenizer.json",
  mel_filters: "/data/models/melfilters.bytes",
  config: "/data/models/whisper-config.json"
)

pcm = InferAudio.Decoder.load_for_whisper("/data/clip.mp3")
{:ok, text} = InferLLM.Whisper.transcribe(whisper, pcm)
```

The model files come from candle, not whisper.cpp. whisper.cpp's
`ggml-*.bin` files use a different format and do not load. With
`nerves_ai`'s model hub:

```elixir
config :nerves_ai,
  models: [
    whisper: [source: {:hf, "lmz/candle-whisper", "model-tiny-en-q80.gguf"},
              path: "/data/models/whisper-tiny-en-q80.gguf"],
    whisper_tokenizer: [source: {:hf, "lmz/candle-whisper", "tokenizer-tiny-en.json"},
                        path: "/data/models/whisper-tokenizer.json"],
    whisper_config: [source: {:hf, "lmz/candle-whisper", "config-tiny-en.json"},
                     path: "/data/models/whisper-config.json"],
    whisper_mel: [source: {:url, "https://github.com/huggingface/candle/raw/main/candle-examples/examples/whisper/melfilters.bytes"},
                  path: "/data/models/melfilters.bytes"]
  ]
```

Decoding is greedy without timestamps. Audio longer than 30 s is
transcribed in consecutive 30 s windows.

### Sampling and KV cache (pure Nx — no backend needed)

```elixir
cache = InferLLM.KVCache.new(n_layers, n_heads, max_seq, head_dim)
cache = InferLLM.KVCache.append_layer(cache, 0, k_step, v_step)
cache = InferLLM.KVCache.advance(cache)

token = InferLLM.Sampling.sample(logits, temperature: 0.8, top_p: 0.9)
```

## Toolchain

Built and tested with Erlang/OTP 29.1.1 and Elixir 1.20.4, matching the
official Nerves systems (see `.tool-versions`).

## License

Apache-2.0
