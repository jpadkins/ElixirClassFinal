Name: Jacob Adkins           ID:   39366123

## Proposed Project

I propose to create a MUD (Multi User Dungeon) that will allow users to
1. create characters
2. interact with other characters and items
3. have their state (inventory, stats, location) serialized and recovered
  upon logging in again.

## Outline Structure

This project will consist of two parts:
1. a dumb client that displays information in the terminal
2. a server that the client can issue commands to, and that returns
  state information to the client to be printed


The server will use Phoenix Channels for the connection with the client.
The rooms of the channel will correspond to "rooms" in the game. Actions
taken by the client will be recieved by the server which will broadcast
an event message, that will cause other processes to update themselves,
take actions, or ignore the message according to thier own roles.


I imagine having one GenServer that acts as a "warehouse of items",
keeping track of items' locations, details, etc.. One that acts as a
"warehouse of character information", keeping track of characters'
location, stats, etc. I will also have a GenServer that handles events
and either updates the Item Warehouse or the Character Warehouse
accordingly.


I plan on this application being completely event-driven, instead of
the tradition approach where you "pulse" every second and update state
and flush event queues. I do not know if this is feasible, but in the
event that the event-driven approach does not work out I will provide
a written analysis of why.

