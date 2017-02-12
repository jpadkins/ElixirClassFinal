## CSE 5345 Final - _A MUD in Elixir_

Jacob Adkins, 39366123



### Project Details

For my final project I created a simple **MUD** (or multi-user dungeon) in Elixir. Implemented features include:

* Phoenix Framework server
* Networking accomplished over websockets (Phoenix Channels)
* Used Phoenix Presence to track the presence of users in channels
* Web client (part of the **mud_server** project)
* Terminal Client (part of the **mud_client** project)
* GenServer to track items
* Implemented commands for users:
 * **rename** - allows a user to rename themselves (users are initially given names based on the timestamp of when they first connected. This is a placeholder for a full authentication process
 * **look** - allows a user to see what exists around them (lists nearby players and items)
 * **say** - allows a player to broadcast a message to all other nearby players
 * **get** - allows a player to get an item off the ground and place it into their inventory
 * **drop** - allows a player to drop an item from their inventory onto the ground
 * **inv** - displays to the player the current contents of their inventory

Here is a screenshot of an example session, showing off most of the commands from the viewpoint of both the web and terminal clients:
![screenshot](screenshot.png?raw=true)

A majority of my code (and not boilerplate) is in the files
 * **mud_client/lib/mud_client/socket_client.ex**
 * **mud_server/web/channels/room_channel.ex**
 * **mud_server/lib/mux_server/item_server.ex**

### Future Plans

I did not have as much time to work on this project as I had hoped, and so not all of the features I had originally planned made it into the final project, nor are the features I did implement as stable and tested as I would have liked.

I am very much interested in continuing this project as a pet project. Some of the features I plan on implementing are:

 * allow the player to move between rooms
 * implement an authentication system that allows players to create accounts or sign into existing ones
 * add more stats and flesh out existing commands
 * add more actions and items that allow for actions to be done to them
 * add in combat
 * improve stability and add tests

### Conclusion
(omitted on Github)
