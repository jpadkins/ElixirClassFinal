defmodule MudServer.RoomChannel do
  use MudServer.Web, :channel
  alias MudServer.Presence
  alias MudServer.ItemServer

  def join("room:login", _, socket) do
    send self, :after_join
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.username,
      %{online_at: :os.system_time(:milli_seconds)})
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end

  def handle_in("message:new", message, socket) do
    case String.split(message, " ") do
      ["say" | body ] -> handle_say(body, socket)
      ["look" | _ ] -> handle_look(socket)
      ["rename", new_name | _ ] -> handle_rename(new_name, socket)
      ["inv" | _ ] -> handle_inv(socket)
      ["get", item | _ ] -> handle_get(item, socket)
      ["drop", item | _ ] -> handle_drop(item, socket)
      _ ->
        push socket, "message:user", %{
          username: "<The Server>",
          body: "I could not understand that command",
          timestamp: :os.system_time(:milli_seconds)}
        {:noreply, socket}
    end
  end

  def handle_in("message:ping", _payload, socket) do
    IO.puts "received ping from #{inspect socket.transport_pid}"
    {:noreply, socket}
  end

  defp handle_say(body, socket) do
    broadcast! socket, "message:user", %{
      username: socket.assigns.username,
      body: Enum.join(body, " "),
      timestamp: :os.system_time(:milli_seconds)}
    {:noreply, socket}
  end

  defp handle_look(socket) do
    people_list = Presence.list(socket)
      |> Map.keys
      |> Enum.map(fn str -> str <> "(player)" end)
      |> Enum.join(", ")
    item_list = ItemServer.get_loose_items
      |> Enum.map(fn item -> item.name <> "(item)" end)
      |> Enum.join(", ")
    push socket, "message:user", %{
      username: "<The Server>",
      body: "You see #{people_list}, #{item_list}",
      timestamp: :os.system_time(:milli_seconds)}
    {:noreply, socket}
  end

  defp handle_inv(socket) do
    items = ItemServer.get_player_items(socket.assigns.username)
      |> Enum.map(fn item -> item.name <> "(item)" end)
      |> Enum.join(", ")
    push socket, "message:user", %{
      username: "<The Server>",
      body: "You are carrying: #{items}",
      timestamp: :os.system_time(:milli_seconds)}
    {:noreply, socket}
  end

  defp handle_get(item, socket) do
    item_exists = ItemServer.get_loose_items
      |> Enum.any?(fn i -> i.name == item end)
    if item_exists do
      ItemServer.pickup(socket.assigns.username, item)
      broadcast! socket, "message:user", %{
        username: socket.assigns.username,
        body: "I picked up a #{item}",
        timestamp: :os.system_time(:milli_seconds)}
    else
      push socket, "message:user", %{
        username: "<The Server>",
        body: "There isn't a #{item} to pick up",
        timestamp: :os.system_time(:milli_seconds)}
    end
    {:noreply, socket}
  end

  defp handle_drop(item, socket) do
    item_exists = ItemServer.get_player_items(socket.assigns.username)
    |> Enum.any?(fn i -> i.name == item end)
    if item_exists do
      ItemServer.putdown(socket.assigns.username, item)
      broadcast! socket, "message:user", %{
        username: socket.assigns.username,
        body: "I dropped up a #{item}",
        timestamp: :os.system_time(:milli_seconds)}
    else
      push socket, "message:user", %{
        username: "<The Server>",
        body: "There isn't a #{item} to drop",
        timestamp: :os.system_time(:milli_seconds)}
    end
    {:noreply, socket}
  end

  defp handle_rename(new_name, socket) do
    Presence.untrack(socket, socket.assigns.username)
    old_name = socket.assigns.username
    socket = assign socket, :username, new_name
    Presence.track(socket, socket.assigns.username,
      %{online_at: :os.system_time(:milli_seconds)})
    broadcast! socket, "message:user", %{
      username: socket.assigns.username,
      body: "I have renamed myself from #{old_name}",
      timestamp: :os.system_time(:milli_seconds)}
    {:noreply, socket}
  end

end
