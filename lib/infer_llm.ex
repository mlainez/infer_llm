defmodule InferLLM do
  @moduledoc """
  Nx helpers for LLM inference, plus Whisper speech-to-text behind a
  pluggable backend.

  * `InferLLM.Whisper` — Whisper STT (delegates to `InferLLM.Backend`)
  * `InferLLM.Sampling` — greedy / temperature / top-k / top-p sampling
    and repetition penalty (pure Elixir + Nx)
  * `InferLLM.KVCache` — preallocated per-layer KV cache (pure Nx)
  * `InferLLM.Primitives` — linear, RMSNorm and RoPE on the `arm_ai`
    NEON kernels (requires `arm_ai` + `nx_arm`), plus causal masks

  ## Backend

      config :infer_llm, backend: ArmAI.LLMBackend

  ## Decoder LLMs

  For quantized decoder LLMs (Llama / TinyLlama / SmolLM GGUF files) use
  `ArmAI.LlamaCandle` from the `arm_ai` package: token ids in, token ids
  out, no Nx tensors involved.
  """
end
