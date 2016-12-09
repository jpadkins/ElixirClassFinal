defmodule MudServer.ItemServer do
  use GenServer
  alias MudServer.Item
  @me :item_server

  #######
  # API #
  #######

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @me)
  end

  def get_loose_items do
    GenServer.call(@me, :get_loose_items)
  end

  def put_loose_items(item) do
    GenServer.call(@me, {:put_loose_items, item})
  end

  def del_loose_items(item) do
    GenServer.call(@me, {:del_loose_items, item})
  end

  def get_player_items(id) do
    GenServer.call(@me, {:get_player_items, id})
  end

  def put_player_items(item, id) do
    GenServer.call(@me, {:put_player_items, item, id})
  end

  def del_player_items(item, id) do
    GenServer.call(@me, {:del_player_items, item, id})
  end

  def pickup(id, item_name) do
    get_loose_items
      |> Enum.find(&(&1.name == item_name))
      |> put_player_items(id)
      |> del_loose_items
  end

  def putdown(id, item_name) do
    get_player_items(id)
      |> Enum.find(&(&1.name == item_name))
      |> del_player_items(id)
      |> put_loose_items
  end

  ##################
  # IMPLEMENTATION #
  ##################

  def init(_args) do
    item1 = %Item{name: "sword", desc: "It's a sword."}
    item2 = %Item{name: "torch", desc: "It's a torch."}
    {:ok, %{loose: [item1, item2], players: %{}}}
  end

  def handle_call(:get_loose_items, _from, state) do
    {:reply, state[:loose], state}
  end

  def handle_call({:put_loose_items, item}, _from, state) do
    {:reply, item, put_in(state[:loose], [item | state[:loose]])}
  end

  def handle_call({:del_loose_items, item}, _from, state) do
    {:reply, item, update_in(state[:loose], &List.delete(&1, item))}
  end

  def handle_call({:get_player_items, id}, _from, state) do
    player_items = get_in(state, [:players, String.to_atom(id)])
    result = if not is_nil(player_items), do: player_items, else: []
    {:reply, result, state}
  end

  def handle_call({:put_player_items, item, id}, _from, state) do
    player = String.to_atom(id)
    new_state = if not Map.has_key?(state[:players], player) do
      put_in(state, [:players, player], [])
    else
      state
    end
    new_inv = [item | get_in(state, [:players, player])]
    {:reply, item, put_in(new_state, [:players, player], new_inv)}
  end

  def handle_call({:del_player_items, item, id}, _from, state) do
    player = String.to_atom(id)
    {:reply, item, update_in(state, [:players, player], &List.delete(&1, item))}
  end
end
