defmodule MudServer.RoomChannel do
  use MudServer.Web, :channel
  alias MudServer.Presence
  require Logger

  def join("room:login", _, socket) do
    send self, :after_join
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.timestamp,
      %{online_at: :os.system_time(:milli_seconds)})
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end

  def handle_in("message:new", message, socket) do
    broadcast! socket, "message:user", %{
      username: socket.assigns.timestamp,
      body: message,
      timestamp: :os.system_time(:milli_seconds)
    }
    {:noreply, socket}
  end

  def handle_in("message:ping", _message, socket) do
    Logger.warn "PING from #{socket.assigns.timestamp}"
    {:noreply, socket}
  end
end
