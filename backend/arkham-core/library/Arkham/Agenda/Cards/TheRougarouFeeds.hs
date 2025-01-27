module Arkham.Agenda.Cards.TheRougarouFeeds
  ( TheRougarouFeeds(..)
  , theRougarouFeeds
  ) where

import Arkham.Prelude

import Arkham.Agenda.Cards qualified as Cards
import Arkham.Scenarios.CurseOfTheRougarou.Helpers
import Arkham.Agenda.Attrs
import Arkham.Agenda.Helpers
import Arkham.Agenda.Runner
import Arkham.Classes
import Arkham.GameValue
import Arkham.Message
import Arkham.Query
import Arkham.Target

newtype TheRougarouFeeds = TheRougarouFeeds AgendaAttrs
  deriving anyclass (IsAgenda, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

theRougarouFeeds :: AgendaCard TheRougarouFeeds
theRougarouFeeds =
  agenda (2, A) TheRougarouFeeds Cards.theRougarouFeeds (Static 6)

instance AgendaRunner env => RunMessage env TheRougarouFeeds where
  runMessage msg a@(TheRougarouFeeds attrs@AgendaAttrs {..}) = case msg of
    AdvanceAgenda aid | aid == agendaId && onSide B attrs -> do
      mrougarou <- getTheRougarou
      case mrougarou of
        Nothing -> a <$ pushAll
          [ ShuffleAllInEncounterDiscardBackIn "81034"
          , AdvanceAgendaDeck agendaDeckId (toSource attrs)
          , PlaceDoomOnAgenda
          ]
        Just eid -> do
          leadInvestigatorId <- getLeadInvestigatorId
          targets <- setToList <$> nonBayouLocations
          nonBayouLocationsWithClueCounts <-
            sortOn snd
              <$> traverse (traverseToSnd (fmap unClueCount . getCount)) targets
          let
            moveMessage = case nonBayouLocationsWithClueCounts of
              [] -> error "there has to be such a location"
              ((_, c) : _) ->
                let
                  (matches, _) =
                    span ((== c) . snd) nonBayouLocationsWithClueCounts
                in
                  case matches of
                    [(x, _)] -> MoveUntil x (EnemyTarget eid)
                    xs -> chooseOne
                      leadInvestigatorId
                      [ MoveUntil x (EnemyTarget eid) | (x, _) <- xs ]
          a <$ pushAll
            [ ShuffleAllInEncounterDiscardBackIn "81034"
            , moveMessage
            , AdvanceAgendaDeck agendaDeckId (toSource attrs)
            ]
    _ -> TheRougarouFeeds <$> runMessage msg attrs
