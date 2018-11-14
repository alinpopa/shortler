defmodule Shortler.Store.Cleaner do
  @behaviour :gen_statem
  alias Shortler.Conf
  require Logger

  defmodule State do
    defstruct context: nil
  end

  def start_link(context \\ %Shortler.Context{}) do
    :gen_statem.start_link({:local, __MODULE__}, __MODULE__, %State{context: context}, [])
  end

  def swap_context(context) do
    :gen_statem.call(__MODULE__, {:swap_context, context})
  end

  def cleanup() do
    :gen_statem.cast(__MODULE__, :clean)
  end

  def init(state) do
    {:ok, :cleaning, state, [{:state_timeout, 0, :clean}]}
  end

  def callback_mode() do
    :handle_event_function
  end

  def handle_event(:state_timeout, :clean, :cleaning, state) do
    Shortler.Store.Clean.clean_expired(state.context)
    {:next_state, :ready, state, [{:state_timeout, Conf.cleanup_ms(), :clean}]}
  end

  def handle_event(:state_timeout, :clean, :ready, state) do
    {:next_state, :cleaning, state, [{:state_timeout, 0, :clean}]}
  end

  def handle_event(:cast, :clean, :ready, state) do
    {:next_state, :cleaning, state, [{:state_timeout, 0, :clean}]}
  end

  def handle_event({:call, from}, {:swap_context, context}, _, state) do
    {:keep_state, %State{state | context: context}, [{:reply, from, {:ok, context}}]}
  end

  def handle_event(event_type, event, state_name, state) do
    Logger.warn(
      "Ignoring event type #{inspect(event_type)}, event #{inspect(event)}, while in state #{
        inspect(state_name)
      }"
    )

    {:keep_state, state}
  end
end
