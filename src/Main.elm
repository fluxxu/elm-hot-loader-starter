port module Main exposing (..)

import Html exposing (div, button, text, h2, input, ul, li)
import Html.App exposing (programWithFlags)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Time


type alias Flags = {
  swapCount : Int
}

main : Program Flags
main =
  programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL


type alias Model = 
  { count : Int
  , swapCount: Int -- this will be updated by elm-hot callback. See index.js
  , elapsed : Int
  , alertText : String
  , logs : List String
  }

init : Flags -> (Model, Cmd msg)
init flags =
  (Model 0 0 0 "It works!" [], Cmd.none)


-- UPDATE


type Msg = Increment | Decrement | Tick | Alert | ChangeAlertText String | Log String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Increment ->
      ({ model | count = model.count + 1 }, Cmd.none)

    Decrement ->
      ({ model | count = model.count - 1 }, Cmd.none)

    Tick ->
      ({ model | elapsed = model.elapsed + 1}, Cmd.none)

    Alert ->
      (model, alert model.alertText)

    ChangeAlertText text ->
      ({ model | alertText = text }, Cmd.none)

    Log text ->
      ({ model | logs = text :: model.logs }, Cmd.none)

port alert : String -> Cmd msg
port log : (String -> msg) -> Sub msg


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every Time.second <| always Tick
    , log Log
    ]


-- VIEW

boxStyle : List ( String, String )
boxStyle =
  [ ("border", "1px solid #ccc")
  , ("border-radius", "4px")
  , ("padding", "10px")
  , ("margin", "10px")
  ]

view : Model -> Html.Html Msg
view model =
  div []
    [ div [ style boxStyle ]
        [ text <| "This app has been hot-swapped " ++ (toString model.swapCount) ++ " times." ]
    , div [ style boxStyle ]
        [ h2 [] [ text "Counter" ]
        , button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (toString model.count) ]
        , button [ onClick Increment ] [ text "+" ]
        ]
    , div [ style boxStyle ]
        [ h2 [] [ text "Time.every second" ]
        , text <| "elapsed seconds: " ++ (toString model.elapsed)
        ]
    , div [ style boxStyle ]
        [ h2 [] [ text "Outgoing Port" ]
        , input [ type' "text", value model.alertText, onInput ChangeAlertText ] []
        , button [ onClick Alert ] [ text "call alert" ]
        ]
    , div [ style boxStyle ]
        [ h2 [] [ text "Incoming Port" ]
        , ul [] <|
            List.map (\t -> li [] [ text t]) model.logs
        ]
    ]