module Ws.Methods.StreamSong exposing (streamSong)

import Json.Decode exposing (int)
import Json.Encode
import Loadable exposing (Loadable(..))
import Ws.Types exposing (RequestData)


streamSong : Int -> RequestData
streamSong id =
    { method = "streamSong"
    , params = makeRequest id |> Just
    , listener = Nothing
    }


makeRequest : Int -> Json.Encode.Value
makeRequest id =
    Json.Encode.object
        [ ( "id", Json.Encode.int id ) ]
