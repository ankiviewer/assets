module Update exposing (update)

import Msg exposing (..)
import Model exposing (..)
import Api exposing (fetchNotes)


handleFilters : String -> Filters -> Filters
handleFilters name { tags, decks, models, columns } =
    case name of
        "tags" ->
            Filters (not tags) decks models columns

        "decks" ->
            Filters tags (not decks) models columns

        "models" ->
            Filters tags decks (not models) columns

        "columns" ->
            Filters tags decks models (not columns)
        _ ->
            Filters tags decks models columns


handleTdmToggle : String -> List (Tdm a) -> List (Tdm a)
handleTdmToggle name tdms =
    List.map
        (\tdm ->
            if tdm.name == name then
                { tdm | showing = not tdm.showing }
            else
                tdm
        )
        tdms


handleTags : List String -> List Tag
handleTags tags =
    List.map
        (\t ->
            Tag t True
        )
        tags


handleModels : List ModelRes -> List Model
handleModels models =
    List.map
        (\{ did, flds, mid, mod, name } ->
            Model did flds mid mod name True
        )
        models


handleDecks : List DeckRes -> List Deck
handleDecks decks =
    List.map
        (\{ did, mod, name } ->
            Deck did mod name True
        )
        decks


update : Msg -> SearchModel -> ( SearchModel, Cmd Msg )
update msg model =
    case msg of
        FetchCollection ->
            ( model, Cmd.none )

        FetchedCollection (Ok collectionRes) ->
            let
                { error, payload } =
                    collectionRes

                { tagsAndCrt, models, decks } =
                    payload

                { crt, tags } =
                    tagsAndCrt
            in
                ( { model
                    | error = error
                    , crt = crt
                    , tags = (handleTags tags)
                    , models = (handleModels models)
                    , decks = (handleDecks decks)
                  }
                , fetchNotes
                )

        FetchedCollection (Err unknownErr) ->
            ( { model | error = (toString unknownErr) }, Cmd.none )

        FetchNotes ->
            ( model, Cmd.none )

        FetchedNotes (Ok notesRes) ->
            ( { model | notes = notesRes.payload }, Cmd.none )

        FetchedNotes (Err unknownErr) ->
            ( { model | error = (toString unknownErr) }, Cmd.none )

        Search str ->
            ( { model | search = str }, Cmd.none )

        ToggleFilter name ->
            let
                filters =
                    handleFilters name model.filters
            in
                ( { model | filters = filters }, Cmd.none )

        ToggleTag name ->
            let
                tags =
                    handleTdmToggle name model.tags
            in
                ( { model | tags = tags }, Cmd.none )

        ToggleDeck name ->
            let
                decks =
                    handleTdmToggle name model.decks
            in
                ( { model | decks = decks }, Cmd.none )

        ToggleModel name ->
            let
                models =
                    handleTdmToggle name model.models
            in
                ( { model | models = models }, Cmd.none )

        ToggleColumn name ->
            let
                columns =
                    handleTdmToggle name model.columns
            in
                ( { model | columns = columns }, Cmd.none )
