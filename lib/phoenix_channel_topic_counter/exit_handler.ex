defmodule PhoenixChannelTopicCounter.ExitHandler do
  use GenServer, restart: :transient

  def start_link(opts \\ []) do
    name = opts[:name] || raise "You must supply a name"

    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl GenServer
  def init(opts) do
    Process.flag(:trap_exit, true)

    {:ok, %{topic: opts[:topic], parent: opts[:parent]}}
  end

  @impl GenServer
  def handle_info({:EXIT, _pid, _reason}, state) do
    PhoenixChannelTopicCounter.dec(state.parent, state.topic)

    {:stop, :normal, state}
  end
end
