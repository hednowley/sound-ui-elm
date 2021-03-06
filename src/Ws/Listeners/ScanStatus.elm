module Ws.Listeners.ScanStatus exposing (listener)

import Json.Decode exposing (Decoder, Value, bool, int)
import Model exposing (Model)
import Msg exposing (Msg)
import Types exposing (Update)
import Ws.NotificationListener exposing (NotificationListener, makeListenerWithParams)


type alias Params =
    { count : Int
    , scanning : Bool
    }


paramsDecoder : Json.Decode.Decoder Params
paramsDecoder =
    Json.Decode.map2
        Params
        (Json.Decode.field "count" int)
        (Json.Decode.field "scanning" bool)


listener : NotificationListener Model Msg
listener =
    makeListenerWithParams paramsDecoder updater


updater : Params -> Update Model Msg
updater params model =
    ( { model
        | isScanning = params.scanning
        , scanCount = params.count
      }
    , Cmd.none
    )
