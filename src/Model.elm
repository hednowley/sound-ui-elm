module Model exposing (Model)

import Browser
import Url
import Http

type alias Model =
    { username : String
    , password : String
    , message : String
    , isLoggedIn : Bool
    , token : Maybe String
    }