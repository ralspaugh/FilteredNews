import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (..)
import WebSocket


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- JSON

articleDecoder : Decoder Article
articleDecoder = map2 Article (field "text" string) (field "url" string)

jsonToArticle : String -> Maybe Article
jsonToArticle json = Result.toMaybe (decodeString articleDecoder json)

-- MODEL

type alias Model =
  { articles : List Article
  }

init : ( Model, Cmd Msg )
init = ({articles= []}, Cmd.none)


-- UPDATE

type alias Article = { text: String, url: String }

type Msg = NewMessage String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg {articles} =
  case msg of
    NewMessage json ->
      case jsonToArticle json of
        Just article ->
          (Model (article :: articles), Cmd.none)
        Nothing ->
          (Model articles, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:8080" NewMessage


-- VIEW

view : Model -> Html Msg
view model =
  div [ class "page-container" ]
    [ div [ class "header" ] [ h1 [] [ text "Filtered News" ], small [] [ text "'cause sometimes you just need to relax." ]],
      div [ class "main-content" ] (List.map viewArticle model.articles)
    ]

viewArticle : Article -> Html article
viewArticle article =
  div [ class "article" ] [ a [ href article.url, target "_blank" ] [ text article.text ] ]
