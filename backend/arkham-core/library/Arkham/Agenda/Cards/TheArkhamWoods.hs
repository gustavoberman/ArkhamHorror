module Arkham.Agenda.Cards.TheArkhamWoods where

import Arkham.Prelude

import Arkham.Agenda.Cards qualified as Cards
import Arkham.Agenda.Attrs
import Arkham.Agenda.Helpers
import Arkham.Agenda.Runner
import Arkham.Card
import Arkham.Classes
import Arkham.GameValue
import Arkham.Matcher
import Arkham.Message
import Arkham.Source
import Arkham.Target
import Arkham.Trait

newtype TheArkhamWoods = TheArkhamWoods AgendaAttrs
  deriving anyclass (IsAgenda, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

theArkhamWoods :: AgendaCard TheArkhamWoods
theArkhamWoods = agenda (1, A) TheArkhamWoods Cards.theArkhamWoods (Static 4)

instance AgendaRunner env => RunMessage env TheArkhamWoods where
  runMessage msg a@(TheArkhamWoods attrs) = case msg of
    AdvanceAgenda aid | aid == toId a && agendaSequence attrs == Agenda 1 B ->
      a <$ push
        (Run
          [ ShuffleEncounterDiscardBackIn
          , DiscardEncounterUntilFirst
            (AgendaSource aid)
            (CardWithType EnemyType <> CardWithTrait Monster)
          ]
        )
    RequestedEncounterCard source mcard | isSource attrs source -> case mcard of
      Nothing ->
        a <$ push (AdvanceAgendaDeck (agendaDeckId attrs) (toSource attrs))
      Just card -> do
        mainPathId <- getJustLocationIdByName "Main Path"
        a <$ pushAll
          [ SpawnEnemyAt (EncounterCard card) mainPathId
          , PlaceDoom (CardIdTarget $ toCardId card) 1
          , AdvanceAgendaDeck (agendaDeckId attrs) (toSource attrs)
          ]
    _ -> TheArkhamWoods <$> runMessage msg attrs
