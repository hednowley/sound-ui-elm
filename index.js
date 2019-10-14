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

let audioCtx = new (window.AudioContext || window.webkitAudioContext)();
let source;

let socket;
window.app = app;

app.ports.stream.subscribe(({ url, token }) => {
  if (source) {
    source.stop();
  }

  let s = audioCtx.createBufferSource();
  s.connect(audioCtx.destination);

  // prepare request
  let request = new XMLHttpRequest();
  request.open("GET", url, true);
  request.responseType = "arraybuffer";

  request.onload = async () => {
    let audioData = request.response;

    try {
      const buffer = await audioCtx.decodeAudioData(audioData);
      s.buffer = buffer;
      s.start(0);
      source = s;
    } catch (e) {
      console.log(e);
    }
  };

  request.setRequestHeader("Authorization", `Bearer ${token}`);
  request.send();
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
