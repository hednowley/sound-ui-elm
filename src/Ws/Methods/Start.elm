module Ws.Methods.Start exposing (start)

import Json.Decode exposing (field, int, list, string)
import Json.Encode
import Model exposing (Model)
import Msg exposing (Msg)
import Types exposing (Update)
import Ws.Core as Ws
import Ws.Types exposing (RequestData)


{-| This should be run once the websocket handshake is complete.
-}
start : Update Model Msg
start model =
    Ws.sendMessage model sayHello


sayHello : RequestData
sayHello =
    { method = "getArtists"
    , params = Nothing
    , listener = Nothing
    }


type alias Body =
    { artists : List Artist }


type alias Artist =
    { id : Int, name : String }


responseDecoder : Json.Decode.Decoder Body
responseDecoder =
    Json.Decode.map Body
        (field "artists" (list artistDecoder))


artistDecoder : Json.Decode.Decoder Artist
artistDecoder =
    Json.Decode.map2 Artist
        (field "id" int)
        (field "name" string)
