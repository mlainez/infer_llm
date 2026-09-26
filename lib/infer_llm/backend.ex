defmodule InferLLM.Backend do
  @moduledoc """
  Behaviour for speech-to-text backends (Whisper load + transcribe).

  ## Configuring the active backend

      config :infer_llm, backend: ArmAI.LLMBackend

  Override per call with the `backend:` option.
  """

  @doc "Load a Whisper model. Returns an opaque handle the backend will recognise."
  @callback whisper_load(opts :: keyword()) :: {:ok, term()} | {:error, term()}

  @doc "Transcribe PCM (binary or Nx tensor) using a previously-loaded Whisper handle."
  @callback whisper_transcribe(handle :: term(), pcm :: binary() | Nx.Tensor.t(), opts :: keyword()) ::
              {:ok, String.t()} | {:error, term()}

  @doc """
  Return the configured backend module. Reads the `:backend`
  option, falling back to `Application.get_env(:infer_llm, :backend)`.
  Raises if neither is set.
  """
  @spec resolve(keyword()) :: module()
  def resolve(opts) do
    case Keyword.get(opts, :backend) || Application.get_env(:infer_llm, :backend) do
      nil ->
        raise """
        No InferLLM backend configured. Add one to your config:

            config :infer_llm, backend: ArmAI.LLMBackend

        Or pass `backend:` explicitly to the call.
        """

      backend when is_atom(backend) ->
        backend
    end
  end
end
