module Ws.Response exposing (Response, ResponseBody, decode)

import Json.Decode exposing (Decoder, Value, decodeString, field, int, map3, maybe, string, value)


{-| A reply received through a websocket.
-}
type alias Response =
    { id : Int
    , body : ResponseBody
    }


{-| A result which represents either the success JSON or error JSON of a response.
-}
type alias ResponseBody =
    Result Value Value


type alias RawResponse =
    { id : Int
    , result : Maybe Value
    , error : Maybe Value
    }


{-| Try to convert a message into a response.
-}
decode : String -> Maybe Response
decode =
    decodeString decoder >> Result.toMaybe >> Maybe.andThen convert


{-| Decodes JSON into a RawResponse.
-}
decoder : Decoder RawResponse
decoder =
    map3 RawResponse
        (field "id" int)
        (maybe (field "result" value))
        (maybe (field "error" value))


{-| Parses a raw response.
-}
convert : RawResponse -> Maybe Response
convert raw =
    case raw.error of
        Just error ->
            Response raw.id (Result.Err error) |> Just

        -- If no error then look for a response
        Nothing ->
            raw.result
                |> Maybe.map (Response raw.id << Result.Ok)
