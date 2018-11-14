defmodule Shortler.Clicks.Sender do
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

  def send(data) do
    GenServer.cast(__MODULE__, {:send, data})
  end

  def init(context) do
    {:ok, %State{context: context}}
  end

  def handle_call({:swap_context, context}, _from, state) do
    {:reply, context, %State{state | context: context}}
  end

  def handle_cast({:send, data}, state) do
    Shortler.Clicks.Writer.write(state.context, data)
    {:noreply, state}
  end
end
