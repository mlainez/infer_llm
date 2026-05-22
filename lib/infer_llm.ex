defmodule InferLLM do
  @moduledoc """
  Generic Nx-tensor wrappers for LLM + STT inference, with a
  pluggable native backend.

  * `InferLLM.Whisper` — Whisper STT (delegates to `InferLLM.Backend`)
  * `InferLLM.Primitives` — RMSNorm, RoPE Nx primitives (currently
    coupled to `ArmAI.Native`; backend split is TODO)
  * `InferLLM.KVCache` — Nx-tensor KV cache helper (pure Nx, no NIF)
  * `InferLLM.Sampling` — top-k / top-p / temperature / repetition
    penalty (pure Nx)
  * `InferLLM.Bench.TinyLM` — micro-benchmark for a tiny transformer

  ## Backend

      config :llm, backend: ArmAI.LLMBackend

  ## Raw-binary LLM (no Nx)

  For decoder LLMs (Llama / TinyLlama / SmolLM / Phi / Qwen) the
  binary token API `ArmAI.LlamaCandle` is the right home — token
  IDs in, token IDs out, no Nx tensors involved. It lives in the
  `:arm_ai` package directly.
  """
end
