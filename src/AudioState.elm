module AudioState exposing (State(..))


type State
    = Loading
    | Loaded
    | Paused Float
    | Playing Float
