module Arkham.Agenda.Cards.TheMawWidens
  ( TheMawWidens(..)
  , theMawWidens
  ) where

import Arkham.Prelude

import Arkham.Agenda.Cards qualified as Cards
import Arkham.Scenarios.TheEssexCountyExpress.Helpers
import Arkham.Agenda.Attrs
import Arkham.Agenda.Helpers
import Arkham.Agenda.Runner
import Arkham.Classes
import Arkham.GameValue
import Arkham.LocationId
import Arkham.Message
import Arkham.Query

newtype TheMawWidens = TheMawWidens AgendaAttrs
  deriving anyclass (IsAgenda, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

theMawWidens :: AgendaCard TheMawWidens
theMawWidens = agenda (2, A) TheMawWidens Cards.theMawWidens (Static 3)

instance AgendaRunner env => RunMessage env TheMawWidens where
  runMessage msg a@(TheMawWidens attrs@AgendaAttrs {..}) = case msg of
    AdvanceAgenda aid | aid == agendaId && agendaSequence == Agenda 2 B -> do
      leadInvestigatorId <- unLeadInvestigatorId <$> getId ()
      investigatorIds <- getInvestigatorIds
      locationId <- getId @LocationId leadInvestigatorId
      lid <- leftmostLocation locationId
      a <$ pushAll
        (RemoveLocation lid
        : [ InvestigatorDiscardAllClues iid | iid <- investigatorIds ]
        <> [AdvanceAgendaDeck agendaDeckId (toSource attrs)]
        )
    _ -> TheMawWidens <$> runMessage msg attrs
