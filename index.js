"use strict";

require("./index.html");
require("./src/css/reset.css");
require("./src/sass/styles.scss");
var Elm = require("./src/Main.elm");

// Start elm with the possible serialised model from local storage
var stored = localStorage.getItem("sound-ui-elm");
var model = stored ? JSON.parse(stored) : null;
var app = Elm.Elm.Main.init({ flags: {  config: SOUND_CONFIG, model} });

// Port for serialising and storing the elm model
app.ports.setStorage.subscribe(model => 
  localStorage.setItem("sound-ui-elm", JSON.stringify(model))
);

let socket;
window.app = app;

// Port for creating a websocket from elm
app.ports.websocketOpen.subscribe(url => {
  socket = new WebSocket(url);

  // Tell elm the socket is open
  socket.onopen = () => {
    app.ports.websocketOpened.send(null);
  };

  // Forward incoming messages to elm
  socket.onmessage = message => {
    app.ports.websocketIn.send(message.data);
  };
});

// Port for sending messages through the socket from elm
app.ports.websocketOut.subscribe(message => {
  if (socket && socket.readyState === 1) {
    socket.send(JSON.stringify(message));
  }
});

// Port for closing the socket from elm
app.ports.websocketClose.subscribe(() => {
  if (socket == null) {
    return;
  }

  socket.close();
  socket = null;
});
