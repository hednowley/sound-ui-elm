"use strict";

require('./index.html');
require("./src/sass/styles.scss")
var Elm = require("./src/Main.elm");

var storedState = localStorage.getItem("sound-ui-elm");
var startingState = storedState ? JSON.parse(storedState) : null;
var app = Elm.Elm.Main.init({ flags: startingState });
app.ports.setStorage.subscribe(function(state) {
    localStorage.setItem("sound-ui-elm", JSON.stringify(state));
});
