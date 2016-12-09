defmodule MudServer.ItemServer do
  use GenServer
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
    GenServer.cast(@me, {:put_loose_items, item})
  end

  def del_loose_items(item) do
    GenServer.cast(@me, {:del_loose_items, item})
  end

  def get_player_items(id) do
    GenServer.call(@me, {:get_player_items, id})
  end

  def put_player_items(id, item) do
    GenServer.cast(@me, {:put_player_items, id, item})
  end

  def del_player_items(id, item) do
    GenServer.cast(@me, {:del_player_items, id, item})
  end

  ##################
  # IMPLEMENTATION #
  ##################

  def init(_args) do
    {:ok, %{loose: [], players: %{}}}
  end

  # CALLS

  def handle_call(:get_loose_items, _from, state) do
    {:reply, state[:loose], state}
  end

  def handle_call({:get_player_items, id}, _from, state) do
    {:reply, get_in(state, [:players, String.to_atom(id)]), state}
  end

  # CASTS

  def handle_cast({:put_loose_items, item}, state) do
    {:noreply, put_in(state[:loose], [item | state[:loose]])}
  end

  def handle_cast({:del_loose_items, item}, state) do
    {:noreply, update_in(state[:loose], &List.delete(&1, item))}
  end

  def handle_cast({:put_player_items, id, item}, state) do
    player = String.to_atom(id)
    new_state = if not Map.has_key?(state[:players], player) do
      put_in(state, [:players, player], [])
    else
      state
    end
    new_inv = [ item | get_in(state, [:players, player])]
    {:noreply, put_in(new_state, [:players, player], new_inv)}
  end

  def handle_cast({:del_player_items, id, item}, state) do
    player = String.to_atom(id)
    {:noreply, update_in(state, [:players, player], &List.delete(&1, item))}
  end
end
