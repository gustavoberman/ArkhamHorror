module Arkham.Agenda.Cards.TheFirstNight (
  TheFirstNight,
  theFirstNight,
) where

import Arkham.Prelude

import Arkham.Agenda.Attrs
import Arkham.Agenda.Cards qualified as Cards
import Arkham.Agenda.Helpers
import Arkham.Agenda.Runner
import Arkham.Classes
import Arkham.GameValue
import Arkham.Message
import Arkham.Modifier
import Arkham.Scenarios.APhantomOfTruth.Helpers

newtype TheFirstNight = TheFirstNight AgendaAttrs
  deriving anyclass (IsAgenda, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

theFirstNight :: AgendaCard TheFirstNight
theFirstNight = agenda (1, A) TheFirstNight Cards.theFirstNight (Static 6)

instance HasRecord env () => HasModifiersFor env TheFirstNight where
  getModifiersFor _ target (TheFirstNight a) | not (isTarget a target) = do
    moreConvictionThanDoubt <- getMoreConvictionThanDoubt
    pure $ toModifiers a $ [DoomSubtracts | moreConvictionThanDoubt ]
  getModifiersFor _ _ _ = pure []

instance AgendaRunner env => RunMessage env TheFirstNight where
  runMessage msg a@(TheFirstNight attrs) = case msg of
    AdvanceAgenda aid | aid == toId attrs && onSide B attrs -> do
      msgs <- disengageEachEnemyAndMoveToConnectingLocation
      pushAll $ msgs <> [NextAdvanceAgendaStep (toId attrs) 2]
      pure a
    NextAdvanceAgendaStep aid 2 | aid == toId attrs && onSide B attrs -> do
      organistMsg <- moveOrganistAwayFromNearestInvestigator
      pushAll (organistMsg : [AdvanceAgendaDeck (agendaDeckId attrs) (toSource attrs)])
      pure a
    _ -> TheFirstNight <$> runMessage msg attrs
