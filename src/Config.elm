module Config exposing (root, ws)

import String exposing (replace)


root =
    "http://www.mywebsite.com/sound"


ws =
    replace "http://" "ws://" root ++ "/ws"
