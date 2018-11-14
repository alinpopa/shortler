defmodule Shortler.Cache.EtsCache do
  use GenServer
  alias Shortler.Conf

  defmodule State do
    defstruct context: %Shortler.Cache.Context{}, timer: nil
  end

  def start_link(context) do
    GenServer.start_link(__MODULE__, %State{context: context}, name: __MODULE__)
  end

  def swap_context(context) do
    GenServer.call(__MODULE__, {:swap_context, context})
  end

  def get(short, context \\ %Shortler.Cache.Context{}) do
    case Shortler.Cache.Ops.get(context, short) do
      nil ->
        nil

      value ->
        put(short, value)
        value
    end
  end

  def put(short, url) do
    GenServer.cast(__MODULE__, {:write, short, url})
  end

  def remove(short) do
    GenServer.cast(__MODULE__, {:remove, short})
  end

  def expire() do
    GenServer.cast(__MODULE__, :expire)
  end

  def init(state) do
    context = Shortler.Cache.Ops.init(state.context)
    state = %State{state | context: context}
    {:ok, reset_timer(state)}
  end

  def handle_call({:swap_context, context}, _from, state) do
    {:reply, context, %State{state | context: context}}
  end

  def handle_cast({:write, short, url}, state) do
    Shortler.Cache.Ops.put(state.context, short, url)
    {:noreply, state}
  end

  def handle_cast({:remove, short}, state) do
    Shortler.Cache.Ops.remove(state.context, short)
    {:noreply, state}
  end

  def handle_cast(:expire, state),
    do: check_expire(state)

  def handle_info(:expire, state) do
    check_expire(state)
  end

  defp check_expire(state) do
    Shortler.Cache.Ops.expire(state.context)
    {:noreply, reset_timer(state)}
  end

  defp reset_timer(state = %State{timer: nil}) do
    freq = Conf.cache_expire_frequency_sec() * 1000
    timer = Process.send_after(self(), :expire, freq * 1000)
    %State{state | timer: timer}
  end

  defp reset_timer(state) do
    Process.cancel_timer(state.timer)
    reset_timer(%State{state | timer: nil})
  end
end
