defmodule MudServer.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "room:*", MudServer.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    socket = socket
    |> assign(:username, :os.system_time(:milli_seconds))
    |> assign(:timestamp, :os.system_time(:milli_seconds))
    {:ok, socket}
  end

  def id(_socket), do: nil
end
