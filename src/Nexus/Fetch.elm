
module Nexus.Fetch exposing (NexusObject)

type alias NexusObject a = {
    getId: a -> Int
}


type alias NexusRepo a = Dict Int a

