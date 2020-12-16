# PhoenixChannelTopicCounter

Expose the number of users connected to a topic per host.

I'm 100% convinced this problem is solved by Phoenix but for the life of me I
couldn't see it and haven't read about.

## Usage

```elixir
{:ok, _pid} = PhoenixChannelTopicCounter.start_link(name: :counter)

defmodule MyAppWeb.AppChannel do
  use MyAppWeb, :channel

  @impl Phoenix.Channel
  def join("app", _payload, socket) do
    PhoenixChannelTopicCounter.inc(:counter, "app")

    {:ok, socket}
  end
end

PhoenixChannelTopicCounter.count(:counter, "app") # => 1
PhoenixChannelTopicCounter.counts(:counter)       # => %{"app" => 1}
```

Also, you'll probably only run one of these so you can `use` it instead of
passing around the name:

```elixir
defmodule MyAppWeb.TopicCounter do
  use PhoenixChannelTopicCounter
end

{:ok, _pid} = MyAppWeb.TopicCounter.start_link()
MyAppWeb.TopicCounter.inc("app")
MyAppWeb.TopicCounter.count("app") # => 1
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `phoenix_channel_topic_counter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phoenix_channel_topic_counter, github: "coop/phoenix_channel_topic_counter"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/phoenix_channel_topic_counter](https://hexdocs.pm/phoenix_channel_topic_counter).

