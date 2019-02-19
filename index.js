"use strict";

require("./index.html");
require("./src/css/reset.css");
require("./src/sass/styles.scss");
var Elm = require("./src/Main.elm");

var storedState = localStorage.getItem("sound-ui-elm");
var startingState = storedState ? JSON.parse(storedState) : null;
var app = Elm.Elm.Main.init({ flags: startingState });
app.ports.setStorage.subscribe(function(state) {
    localStorage.setItem("sound-ui-elm", JSON.stringify(state));
});

let socket;

window.app = app;

app.ports.websocketOpen.subscribe(url => {
    socket = new WebSocket(url);
    socket.onopen = () => {
        app.ports.websocketOpened.send(true);
    }
    socket.onmessage = message => {
        console.log("in")
        console.log(message.data)
        app.ports.websocketIn.send(message.data);
    }
});

app.ports.websocketOut.subscribe(message => {
    if (socket && socket.readyState === 1) {
        console.log("out")
        console.log(message)
        socket.send(JSON.stringify(message));
    }
});
