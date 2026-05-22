defmodule InferLLM.Whisper do
  @moduledoc """
  Speech-to-text — generic API delegating to an `InferLLM.Backend`.

  Today the only implementation is `ArmAI.LLMBackend` (candle-transformers
  via the `arm_ai` NIF). Other backends can register by implementing
  the `InferLLM.Backend` behaviour.

      {:ok, w} = InferLLM.Whisper.load(
        model:        "/root/whisper-tiny.gguf",
        tokenizer:    "/root/whisper-tokenizer.json",
        mel_filters:  "/root/mel_filters.bin",
        config:       "/root/whisper-config.json"
      )

      pcm = Audio.Decoder.load_for_whisper("/root/clip.mp3")
      {:ok, text} = InferLLM.Whisper.transcribe(w, pcm)

  Greedy decode covers the first 30 s only — chunked / timestamp-based
  decoding is future work.
  """

  defstruct [:handle, :backend]

  @doc """
  Load a Whisper checkpoint with its tokenizer + mel filters + config.

  Required keys (forwarded to the backend):

    * `:model` — path to the `.gguf` or safetensors checkpoint
    * `:tokenizer` — path to the matching `tokenizer.json`
    * `:mel_filters` — path to the precomputed mel filter banks
    * `:config` — path to `config.json`
  """
  @spec load(keyword()) :: {:ok, %__MODULE__{}} | {:error, term()}
  def load(opts) do
    backend = InferLLM.Backend.resolve(opts)

    case backend.whisper_load(opts) do
      {:ok, handle} -> {:ok, %__MODULE__{handle: handle, backend: backend}}
      {:error, _} = err -> err
    end
  end

  @doc """
  Transcribe a 16 kHz mono f32 audio tensor (or raw f32 binary) to
  text. Backends are expected to scope the call under a performance
  governor when appropriate.
  """
  @spec transcribe(%__MODULE__{}, Nx.Tensor.t() | binary(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def transcribe(%__MODULE__{handle: handle, backend: backend}, pcm, opts \\ []) do
    backend.whisper_transcribe(handle, pcm, opts)
  end
end
