defmodule PhoenixChannelTopicCounterTest do
  use ExUnit.Case
  doctest PhoenixChannelTopicCounter

  test "greets the world" do
    start_counter(:counter1)
    start_counter(:counter2)

    assert PhoenixChannelTopicCounter.inc(:counter1, "topic1") == 1
    assert PhoenixChannelTopicCounter.inc(:counter1, "topic1") == 2
    assert PhoenixChannelTopicCounter.inc(:counter1, "topic2") == 1
    assert PhoenixChannelTopicCounter.dec(:counter1, "topic1") == 1
    assert PhoenixChannelTopicCounter.count(:counter1, "topic1") == 1
    assert PhoenixChannelTopicCounter.counts(:counter1) == %{"topic1" => 1, "topic2" => 1}

    {:ok, pid} = Agent.start_link(fn -> PhoenixChannelTopicCounter.inc(:counter1, "topic1") end)
    assert PhoenixChannelTopicCounter.count(:counter1, "topic1") == 2

    Agent.stop(pid)

    assert PhoenixChannelTopicCounter.count(:counter1, "topic1") == 1
    assert PhoenixChannelTopicCounter.count(:counter2, "topic1") == 0
  end

  defp start_counter(name) do
    start_supervised!(Supervisor.child_spec({PhoenixChannelTopicCounter, name: name}, id: name))
  end

  defmodule TopicCounter do
    use PhoenixChannelTopicCounter
  end

  test "using" do
    start_supervised!(TopicCounter)
    assert TopicCounter.inc("topic1") == 1
    assert TopicCounter.inc("topic1") == 2
    assert TopicCounter.inc("topic2") == 1
    assert TopicCounter.dec("topic1") == 1
    assert TopicCounter.count("topic1") == 1
    assert TopicCounter.counts() == %{"topic1" => 1, "topic2" => 1}

    {:ok, pid} = Agent.start_link(fn -> TopicCounter.inc("topic1") end)
    assert TopicCounter.count("topic1") == 2

    Agent.stop(pid)

    assert TopicCounter.count("topic1") == 1
  end
end
