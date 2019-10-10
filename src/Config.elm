module Config exposing (Config, getWebsocketUrl)

import String exposing (replace)


getWebsocketUrl : Config -> String
getWebsocketUrl config =
    replace "http://" "ws://" config.root ++ "/ws"


type alias Config =
    { root : String }
