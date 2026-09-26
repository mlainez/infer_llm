defmodule InferLLM.WhisperModelTest do
  # Needs, in $NERVES_AI_MODELS (from lmz/candle-whisper and candle's repo):
  #   whisper-tiny-en-q80.gguf   model-tiny-en-q80.gguf
  #   whisper-tokenizer.json     tokenizer-tiny-en.json
  #   whisper-config.json        config-tiny-en.json
  #   melfilters.bytes           candle-examples/examples/whisper/melfilters.bytes
  #   jfk.wav                    whisper.cpp samples/jfk.wav
  use ExUnit.Case, async: false

  @moduletag :models
  @moduletag timeout: 300_000

  test "transcribes the JFK sample" do
    dir = System.fetch_env!("NERVES_AI_MODELS")

    {:ok, whisper} =
      InferLLM.Whisper.load(
        model: Path.join(dir, "whisper-tiny-en-q80.gguf"),
        tokenizer: Path.join(dir, "whisper-tokenizer.json"),
        mel_filters: Path.join(dir, "melfilters.bytes"),
        config: Path.join(dir, "whisper-config.json")
      )

    pcm = ArmAI.AudioBackend.load_for_whisper(Path.join(dir, "jfk.wav"))
    assert {:ok, text} = InferLLM.Whisper.transcribe(whisper, pcm)
    assert text =~ ~r/ask not what your country can do for you/i
  end
end
