module Arkham.Agenda.Cards.BeckoningForPower
  ( BeckoningForPower
  , beckoningForPower
  ) where

import Arkham.Prelude

import Arkham.Agenda.Cards qualified as Cards
import Arkham.Agenda.Attrs
import Arkham.Agenda.Runner
import Arkham.Classes
import Arkham.GameValue
import Arkham.Message
import Arkham.Resolution

newtype BeckoningForPower = BeckoningForPower AgendaAttrs
  deriving anyclass (IsAgenda, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

beckoningForPower :: AgendaCard BeckoningForPower
beckoningForPower =
  agenda (2, A) BeckoningForPower Cards.beckoningForPower (Static 10)

instance AgendaRunner env => RunMessage env BeckoningForPower where
  runMessage msg a@(BeckoningForPower attrs@AgendaAttrs {..}) = case msg of
    AdvanceAgenda aid | aid == agendaId && agendaSequence == Agenda 2 B ->
      a <$ push (ScenarioResolution $ Resolution 2)
    _ -> BeckoningForPower <$> runMessage msg attrs
