module Config exposing (root, ws)

import String exposing (replace)


root =
    --"http://hednowley.synology.me:171"
    "http://localhost:3684"


ws =
    replace "http://" "ws://" root ++ "/ws"
