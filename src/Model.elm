module Model exposing (Model)

import Browser
import Http
import Url


type alias Model =
    { username : String
    , password : String
    , message : String
    , isLoggedIn : Bool
    , token : Maybe String
    , isScanning : Bool
    , scanCount : Maybe Int
    }
