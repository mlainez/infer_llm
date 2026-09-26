defmodule InferLLM.Whisper do
  @moduledoc """
  Speech-to-text — generic API delegating to an `InferLLM.Backend`.

  The only implementation today is `ArmAI.LLMBackend` (candle-transformers
  via the `arm_ai` NIF). It loads candle's quantized GGUF Whisper
  checkpoints, for example from the `lmz/candle-whisper` Hugging Face
  repo, together with the matching tokenizer and config, and candle's
  `melfilters.bytes` (80 raw little-endian f32 mel filter banks).
  whisper.cpp `ggml-*.bin` files are a different format and do not load.

      {:ok, w} = InferLLM.Whisper.load(
        model:       "/data/models/whisper-tiny-en-q80.gguf",
        tokenizer:   "/data/models/whisper-tokenizer.json",
        mel_filters: "/data/models/melfilters.bytes",
        config:      "/data/models/whisper-config.json"
      )

      pcm = InferAudio.Decoder.load_for_whisper("/data/clip.mp3")
      {:ok, text} = InferLLM.Whisper.transcribe(w, pcm)

  Decoding is greedy, without timestamps. Audio longer than 30 s is
  transcribed in consecutive 30 s windows.
  """

  defstruct [:handle, :backend]

  @doc """
  Load a Whisper checkpoint with its tokenizer + mel filters + config.

  Required keys (forwarded to the backend):

    * `:model` — path to the `.gguf` (quantized) or `.safetensors` checkpoint
    * `:tokenizer` — path to the matching `tokenizer.json`
    * `:mel_filters` — path to the mel filter banks as raw f32 bytes
    * `:config` — path to the model's `config.json`
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
  Transcribe 16 kHz mono audio (an Nx tensor or a raw f32 binary) to
  text. Passing through the `{:error, reason}` from
  `InferAudio.Decoder.load_for_whisper/1` returns it unchanged.
  """
  @spec transcribe(%__MODULE__{}, Nx.Tensor.t() | binary() | {:error, term()}, keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def transcribe(%__MODULE__{handle: handle, backend: backend}, pcm, opts \\ []) do
    backend.whisper_transcribe(handle, pcm, opts)
  end
end
