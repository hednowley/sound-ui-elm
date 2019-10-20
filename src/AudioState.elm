module AudioState exposing (State(..))


type State
    = Loading
    | Loaded { duration : Maybe Float }
    | Paused { time : Float, duration : Maybe Float }
    | Playing { time : Float, duration : Maybe Float }
