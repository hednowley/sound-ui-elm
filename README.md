# sound ui

A work-in-progress front-end for the [sound](https://github.com/hednowley/sound) music server written in [Elm](https://elm-lang.org).

## Prerequisites

You'll need

- [Node](https://nodejs.org) LTS
- [sound](https://github.com/hednowley/sound)

## Building

Edit `root` in [Config.elm](Config.elm) to point to your _sound_ instance.

```shell
$ npm install
$ npm run-script build
```

The static web app assets will be emitted to `./dist` to be deployed wherever you like.
