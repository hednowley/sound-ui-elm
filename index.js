"use strict";

require("./index.html");
require("./src/css/reset.css");
require("./src/sass/styles.scss");
var Elm = require("./src/Main.elm");

// Start elm with the possible serialised model from local storage
var stored = localStorage.getItem("sound-ui-elm");
var model = stored ? JSON.parse(stored) : null;
var app = Elm.Elm.Main.init({ flags: { config: SOUND_CONFIG, model } });

// Port for serialising and storing the elm model
app.ports.setCache.subscribe(model =>
  localStorage.setItem("sound-ui-elm", JSON.stringify(model))
);

let audio;

let socket;
window.app = app;

app.ports.playAudio.subscribe(() => {
  if (audio) {
    audio.play();
  }
});

app.ports.pauseAudio.subscribe(() => {
  if (audio) {
    audio.pause();
  }
});

app.ports.loadAudio.subscribe(url => {
  if (audio) {
    audio.pause();
    audio.oncanplay = null;
    audio.ondurationchange = null;
    audio.onended = null;
  }
  var a = new Audio(url);
  a.oncanplay = () => app.ports.canPlayAudio.send(null);
  a.ondurationchange = () => console.log("ondurationchange");
  a.onended = () => console.log("onended");
  audio = a;
});

// Port for creating a websocket from elm
app.ports.websocketOpen.subscribe(url => {
  socket = new WebSocket(url);

  // Tell elm the socket is open
  socket.onopen = () => {
    // Let elm know when port closes
    socket.onclose = () => {
      app.ports.websocketClosed.send(null);
    };

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

  // Don't tell elm about a close which it instigated
  socket.onclose = null;

  socket.close();
  socket = null;
});

/*
fetch(SOUND_CONFIG.root + "/api/authenticate", {
  method: "POST", // *GET, POST, PUT, DELETE, etc.
  mode: "cors", // no-cors, *cors, same-origin
  cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
  credentials: "include", // include, *same-origin, omit
  headers: {
    "Content-Type": "application/json"
    // 'Content-Type': 'application/x-www-form-urlencoded',
  },
  redirect: "follow", // manual, *follow, error
  referrer: "no-referrer", // no-referrer, *client
  body: JSON.stringify({ username: "gertrude", password: "changeme" }) // body data type must match "Content-Type" header
});
*/
