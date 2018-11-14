defmodule Shortler.Store.Maintenance do
  use GenServer

  defmodule State do
    defstruct context: %Shortler.Context{}
  end

  def start_link(context \\ %Shortler.Context{}) do
    GenServer.start_link(__MODULE__, context, name: __MODULE__)
  end

  def swap_context(context) do
    {:ok, GenServer.call(__MODULE__, {:swap_context, context})}
  end

  def update_expire(short, expire) do
    GenServer.cast(__MODULE__, {:update_expire, short, expire})
  end

  def init(context) do
    {:ok, %State{context: context}}
  end

  def handle_call({:swap_context, context}, _from, state) do
    {:reply, context, %State{state | context: context}}
  end

  def handle_cast({:update_expire, short, expire}, state) do
    Shortler.Store.UpdateExpire.update(state.context, short, expire)
    {:noreply, state}
  end
end
