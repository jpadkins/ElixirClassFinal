import {Socket, Presence} from "phoenix";

// Socket
let socket = new Socket("/socket", {});
socket.connect();

// Presence
let presences = {};

let formatTimestamp = (timestamp) => {
    let date = new Date(timestamp);
    return date.toLocaleTimeString();
};
let listBy = (user, {metas: metas}) => {
    return {
        user: user,
        onlineAt: formatTimestamp(metas[0].online_at)
    };
};

let userList = document.getElementById("UserList");
let render = (presences) => {
    userList.innerHTML = Presence.list(presences, listBy)
        .map(presence => `
        <li>
            <b>${presence.user}</b>
            <br><small>online since ${presence.onlineAt}</small>
        </li>
        `).join("");
};

// Channels
let room = socket.channel("room:login", {});
room.on("presence_state", state => {
    presences = Presence.syncState(presences, state);
    render(presences);
});

room.on("presence_diff", diff => {
    presences = Presence.syncDiff(presences, diff);
    render(presences);
});

room.join();

// Chat
let messageInput = document.getElementById("NewMessage");
messageInput.addEventListener("keypress", (e) => {
  if (e.keyCode == 13 && messageInput.value != "") {
      room.push("message:new", messageInput.value);
      messageInput.value = "";
  }
});

let messageList = document.getElementById("MessageList");

let renderUserMessage = (message) => {
    let messageElement = document.createElement("li");
    messageElement.innerHTML = `
        <b>${message.username}</b>
        <i>${formatTimestamp(message.timestamp)}</i>
        <p>${message.body}</p>
    `;
    messageList.insertBefore(messageElement, messageList.firstChild);
    messageList.scrollTop = messageList.scrollHeight;
};

let renderSystemMessage = (message) => {
    let messageElement = document.createElement("li");
    messageElement.innerHTML = `
        <i>${formatTimestamp(message.timestamp)}</i>
        <p>${message.body}</p>
    `;
    messageList.insertBefore(messageElement, messageList.firstChild);
    messageList.scrollTop = messageList.scrollHeight;
};

room.on("message:user", message => renderUserMessage(message));
room.on("message:system", message => renderSystemMessage(message));
