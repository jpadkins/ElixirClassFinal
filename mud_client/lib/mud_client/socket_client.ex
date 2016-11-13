defmodule MudClient.SocketClient do
  @moduledoc false
  require Logger
  alias Phoenix.Channels.GenSocketClient
  @behaviour GenSocketClient

  #######
  # API #
  #######

  ##################
  # IMPLEMENTATION #
  ##################

  def start_link() do
    GenSocketClient.start_link(
          __MODULE__,
          Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
          "ws://localhost:4000/socket/websocket"
        )
  end

  def init(url) do
    {:connect, url, %{first_join: true, ping_ref: 1}}
  end

  def handle_connected(transport, state) do
    Logger.info("Connected to The Server!")
    GenSocketClient.join(transport, "room:login")
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    Logger.error("disconnected: #{inspect reason}")
    Process.send_after(self(), :connect, :timer.seconds(1))
    {:ok, state}
  end

  def handle_joined(topic, _payload, _transport, state) do
    if state.first_join do
      :timer.send_interval(:timer.seconds(1), self(), :heartbeat)
    end
    {:ok, state}
  end

  def handle_join_error(topic, payload, _transport, state) do
    Logger.error("join error on the topic #{topic}: #{inspect payload}")
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    Logger.error("disconnected from the topic #{topic}: #{inspect payload}")
    Process.send_after(self(), {:join, topic}, :timer.seconds(1))
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    IO.puts "#{topic}:#{event} :: #{inspect payload}"
    {:ok, state}
  end

  def handle_reply("ping", _ref, %{"status" => "ok"} = payload, _transport, state) do
    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, state) do
    IO.puts "Reply-#{topic} :: #{inspect payload}"
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("connecting...")
    {:connect, state}
  end

  def handle_info({:join, topic}, transport, state) do
    IO.puts "joining the topic #{topic}"
    case GenSocketClient.join(transport, topic) do
      {:error, reason} ->
        Logger.error("error joining the topic #{topic}: #{inspect reason}")
        Process.send_after(self(), {:join, topic}, :timer.seconds(1))
      {:ok, _ref} -> :ok
    end

    {:ok, state}
  end

  def handle_info(:heartbeat, transport, state) do
    GenSocketClient.push(transport, "room:login", "message:ping", nil)
    {:ok, state}
  end

  def handle_info(message, _transport, state) do
    Logger.warn("Unhandled message #{inspect message}")
    {:ok, state}
  end

end
