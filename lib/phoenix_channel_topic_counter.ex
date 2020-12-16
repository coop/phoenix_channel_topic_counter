defmodule PhoenixChannelTopicCounter do
  defmacro __using__(_opts) do
    quote do
      def child_spec(opts) do
        opts = Keyword.put_new(opts, :name, __MODULE__)
        PhoenixChannelTopicCounter.child_spec(opts)
      end

      def start_link(opts) do
        opts = Keyword.put_new(opts, :name, __MODULE__)
        PhoenixChannelTopicCounter.start_link(opts)
      end

      def inc(topic), do: PhoenixChannelTopicCounter.inc(__MODULE__, topic)

      def dec(topic), do: PhoenixChannelTopicCounter.dec(__MODULE__, topic)

      def count(topic), do: PhoenixChannelTopicCounter.count(__MODULE__, topic)

      def counts(), do: PhoenixChannelTopicCounter.counts(__MODULE__)
    end
  end

  use Supervisor

  alias __MODULE__.ExitHandler

  def start_link(opts \\ []) do
    name = opts[:name] || raise "You must supply a name"

    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  def inc(server, topic) do
    Process.link(get_pid_for(server, topic))

    :ets.update_counter(ets_name(server), topic, 1, {1, 0})
  end

  def dec(server, topic) do
    :ets.update_counter(ets_name(server), topic, {2, -1, 0, 0})
  end

  def counts(server) do
    Enum.into(:ets.tab2list(ets_name(server)), %{})
  end

  def count(server, topic) do
    case :ets.lookup(ets_name(server), topic) do
      [{^topic, count}] -> count
      [] -> 0
    end
  end

  defp get_pid_for(server, topic) do
    case Registry.lookup(registry_name(server), topic) do
      [{pid, nil}] -> pid
      [] -> start_child(server, topic)
    end
  end

  defp start_child(server, topic) do
    case DynamicSupervisor.start_child(
           sup_name(server),
           {ExitHandler, topic: topic, parent: server, name: via(server, topic)}
         ) do
      {:error, {:already_started, pid}} -> pid
      {:ok, pid} -> pid
    end
  end

  defp via(server, topic), do: {:via, Registry, {registry_name(server), topic}}

  @impl Supervisor
  def init(opts) do
    name = opts[:name]
    :ets.new(ets_name(name), [:set, :public, :named_table, read_concurrency: true])

    children = [
      {Registry, keys: :unique, name: registry_name(name)},
      {DynamicSupervisor, strategy: :one_for_one, name: sup_name(name)}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp ets_name(name), do: :"#{name}_ets"
  defp registry_name(name), do: :"#{name}_Registry"
  defp sup_name(name), do: :"#{name}_DynamicSupervisor"
end
