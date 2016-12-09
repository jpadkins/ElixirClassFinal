defmodule MudClient.SocketClient do
  @moduledoc """
  This module implements a behavior that allows
  for easy connecting to a phoenix channel using the
  erland websocket library.

  The super implementation of the behavior is from
  this repository:

  https://github.com/Aircloak/phoenix_gen_socket_client

  Most of the callbacks here are self-explanatory or
  easy to understand by reading the IO.puts line.
  """
  alias Phoenix.Channels.GenSocketClient
  @behaviour GenSocketClient

  ##################
  # Initialization #
  ##################

  def start_link() do
    GenSocketClient.start_link(
      __MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      "ws://localhost:4000/socket/websocket"
    )
  end

  def init(url) do
    {:connect, url, %{}}
  end

  #def message_loop do
  #  message = IO.gets "command> "
  #  case String.trim(message) do
  #    "quit" -> {:quit}
  #    message when message != "" ->
  #      send self, {:send_message, message}
  #  end
  #  message_loop
  #end

  ########################
  # Connection Callbacks #
  ########################

  def handle_connected(transport, state) do
    IO.puts "Connected to The Server!"
    GenSocketClient.join(transport, "room:login")
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    IO.puts "disconnected: #{inspect reason}"
    {:ok, state}
  end

  def handle_joined(topic, _payload, transport, state) do
    :timer.send_interval(:timer.seconds(10), self, :ping_server)
    send self, {:get_message}
    {:ok, state}
  end

  def handle_join_error(topic, payload, _transport, state) do
    IO.puts "join error on the topic #{topic}: #{inspect payload}"
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    IO.puts "disconnected from the topic #{topic}: #{inspect payload}"
    {:ok, state}
  end

  ####################
  # Message Handlers #
  ####################

  @doc """
  Right now the presence events don't tie into anything. Finding
  the local users is handled on the server side via the "look" command
  that checks the Presence.
  """
  def handle_message(topic, event, payload, _transport, state) do
    case event do
      "presence_diff" -> IO.puts "presence diff"
      "presence_state" -> IO.puts "presence state"
      "message:user" ->
        IO.puts Enum.join([payload["username"],
                           " says \"",
                           payload["body"],
                           "\""])
    end
    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, state) do
    IO.puts "Reply-#{topic}: #{inspect payload}"
    {:ok, state}
  end

  def handle_info({:join, topic}, transport, state) do
    IO.puts "joining the topic #{topic}"
    case GenSocketClient.join(transport, topic) do
      {:error, reason} ->
        IO.puts "error joining the topic #{topic}: #{inspect reason}"
      {:ok, _ref} -> :ok
    end
    {:ok, state}
  end

  @doc """
  TODO: Better, non-blocking I/O
  """
  def handle_info({:get_message}, _transport, state) do
    message = Task.async(fn -> IO.gets "command> " end)
    |> Task.await(:infinity)
    |> String.trim

    if message != "" do
      send self, {:send_message, message}
    end

    send self, {:get_message}
    {:ok, state}
  end

  def handle_info({:send_message, message}, transport, state) do
    GenSocketClient.push(transport, "room:login", "message:new", message)
    {:ok, state}
  end

  @doc """
  Prevents the client from timing out and being disconnected
  """
  def handle_info(:ping_server, transport, state) do
    IO.puts "sending stay-alive ping..."
    GenSocketClient.push(transport, "room:login", "message:ping", "ping")
    {:ok, state}
  end

  def handle_info(message, _transport, state) do
    IO.puts "Unhandled message #{inspect message}"
    {:ok, state}
  end
end
