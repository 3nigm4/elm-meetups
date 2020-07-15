module Game exposing (..)

import List.Extra



-- Features: Symbol, Shading, Color and Number
-- all the same or all different on a feature level


type Symbol
    = Oval
    | Diamond
    | Squiggle


symbols =
    [ Oval, Diamond, Squiggle ]


type Shading
    = Solid
    | Striped
    | Empty


shadings =
    [ Solid, Striped, Empty ]


type Color
    = Red
    | Green
    | Purple


colors =
    [ Red, Green, Purple ]


type Number
    = One
    | Two
    | Three


numbers : List Number
numbers =
    [ One, Two, Three ]


type Card
    = Card CardData


type alias CardData =
    { symbol : Symbol
    , color : Color
    , number : Number
    , shading : Shading
    }


initCard : Symbol -> Color -> Number -> Shading -> Card
initCard symbol color number shading =
    Card
        { symbol = symbol
        , color = color
        , number = number
        , shading = shading
        }


deck : List Card
deck =
    List.Extra.lift4 initCard symbols colors numbers shadings


type Set
    = Set Card Card Card


allSame : (CardData -> b) -> Card -> Card -> Card -> Bool
allSame getter (Card c1) (Card c2) (Card c3) =
    getter c1 == getter c2 && getter c1 == getter c3


allDiff : (CardData -> b) -> Card -> Card -> Card -> Bool
allDiff getter (Card c1) (Card c2) (Card c3) =
    getter c1 /= getter c2 && getter c1 /= getter c3 && getter c2 /= getter c3


isFeatureSet : (CardData -> b) -> Card -> Card -> Card -> Bool
isFeatureSet getter a b c =
    allSame getter a b c || allDiff getter a b c


isValidSet : Set -> Bool
isValidSet (Set a b c) =
    List.all
        identity
        [ isFeatureSet .symbol a b c
        , isFeatureSet .number a b c
        , isFeatureSet .color a b c
        , isFeatureSet .shading a b c
        ]


symbolsAllSame : Card -> Card -> Card -> Bool
symbolsAllSame =
    allSame .symbol
