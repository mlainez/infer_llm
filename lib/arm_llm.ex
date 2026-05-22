defmodule ArmLLM do
  @moduledoc """
  Nx-tensor wrappers for quantized LLM + STT inference on ARM CPUs.

  * `ArmLLM.WhisperCandle` — Whisper STT via candle-transformers
  * `ArmLLM.Primitives` — RMSNorm, RoPE Nx primitives
  * `ArmLLM.KVCache` — Nx-tensor KV cache helper
  * `ArmLLM.Sampling` — top-k / top-p / temperature / repetition penalty
  * `ArmLLM.Bench.TinyLM` — micro-benchmark for a tiny transformer

  For the raw-binary LLM API (token IDs in, token IDs out), see
  `ArmAI.LlamaCandle` in the `:arm_ai` package directly.
  """
end
