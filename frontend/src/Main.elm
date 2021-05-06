port module Main exposing (Model, Msg(..), init, main, toJs, update, view)

import Browser
import Graphql.Http
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import HasuraClient.Enum.Order_by exposing (Order_by(..))
import HasuraClient.Enum.Post_status_enum exposing (Post_status_enum)
import HasuraClient.InputObject exposing (buildPosts_order_by)
import HasuraClient.Object
import HasuraClient.Object.Posts
import HasuraClient.Query exposing (PostsOptionalArguments)
import Html as H
import Html.Attributes as HA
import Html.Events exposing (onClick)


port toJs : String -> Cmd msg


type alias Model =
    { counter : Int
    , posts : List Post
    }

type alias Post =
    { title : String
    , body : String
    , status : Post_status_enum
    }


type Msg
    = Inc
    | TestServer
    | OnServerResponse (Result (Graphql.Http.Error (List Post)) (List Post))


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Inc -> ( { model | counter = model.counter + 1 }, toJs "Inc" )

        TestServer -> ( model, postsQuery OnServerResponse )

        OnServerResponse res -> case res of
            Ok r -> ( { model | posts = r }, Cmd.none )
            Err _ -> ( { model | posts = [] }, Cmd.none )


-- Writing GraphQL requests with `elm-graphql` is a little tricky at first.
-- But the type system and documentation are there to help.
-- Read more about `elm-graphql` here:
-- https://package.elm-lang.org/packages/dillonkearns/elm-graphql/latest
postsQuery : (Result (Graphql.Http.Error (List Post)) (List Post) -> Msg ) -> Cmd Msg
postsQuery onResponse =
    HasuraClient.Query.posts orderPostsById postSelection
        |> Graphql.Http.queryRequest "/v1/graphql"
        |> Graphql.Http.send onResponse

-- An `order_by` query argument to: ascending on `id`
orderPostsById : PostsOptionalArguments -> PostsOptionalArguments
orderPostsById args =
    { args
    | order_by = Present <|
        [ buildPosts_order_by (\args2 -> { args2 | id = OptionalArgument.Present Asc }) ]
    }

-- Selects and maps the fields from server-side `posts` to the `Post` record in Elm.
postSelection : SelectionSet Post HasuraClient.Object.Posts
postSelection =
    SelectionSet.map3 Post
        HasuraClient.Object.Posts.title
        HasuraClient.Object.Posts.body
        HasuraClient.Object.Posts.status


view : Model -> H.Html Msg
view model =
    H.div [ HA.class "container" ]
        [ H.h1 [] [ H.text "Fully dockered Elm-Hasura starter kit" ]
        , H.p [] [ H.text "Click on the buttons below to demonstrate interactivity." ]
        , H.div []
                [ H.button
                    [ onClick Inc ]
                    [ H.text "+ 1" ]
                , H.span [] [ H.text " -> " ]
                , H.text <| String.fromInt model.counter
                ]
        , H.br [] []
        , H.div []
                [ H.button
                    [ onClick TestServer ]
                    [ H.text "fire GraphQL query" ]
                , H.div [] ( List.map viewPost model.posts )
                ]
        , H.p [] [ H.text "Change the source code (elm/scss) and see how it reloads while retaining the state!" ]
        ]


viewPost : Post -> H.Html Msg
viewPost post = H.div []
    [ H.h3 [] [H.text post.title]
    , H.p [] [H.text post.body]
    , H.br [] []
    ]


init : Int -> ( Model, Cmd Msg )
init flags =
    ( { counter = flags, posts = [] }, Cmd.none )


main : Program Int Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Fully dockered Elm-Hasura starter kit"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        }

