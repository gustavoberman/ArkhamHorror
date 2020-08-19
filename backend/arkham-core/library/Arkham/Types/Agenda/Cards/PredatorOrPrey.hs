{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Agenda.Cards.PredatorOrPrey where

import Arkham.Json
import Arkham.Types.Ability
import qualified Arkham.Types.Action as Action
import Arkham.Types.Agenda.Attrs
import Arkham.Types.Agenda.Runner
import Arkham.Types.Classes
import Arkham.Types.GameValue
import Arkham.Types.Message
import Arkham.Types.Source
import ClassyPrelude hiding (sequence)

newtype PredatorOrPrey = PredatorOrPrey Attrs
  deriving newtype (Show, ToJSON, FromJSON)

predatorOrPrey :: PredatorOrPrey
predatorOrPrey = PredatorOrPrey $ (baseAttrs
                                    "01121"
                                    "Predator or Prey?"
                                    "Agenda 1a"
                                    (Static 6)
                                  )
  { agendaAbilities =
    [mkAbility (AgendaSource "01121") 1 (ActionAbility 1 (Just Action.Resign))]
  }

instance (AgendaRunner env) => RunMessage env PredatorOrPrey where
  runMessage msg a@(PredatorOrPrey attrs@Attrs {..}) = case msg of
    AdvanceAgenda aid | aid == agendaId && agendaSequence == "Agenda 1a" -> do
      void $ error "Need to spawn the masked hunter"
      pure a
    UseCardAbility iid _ (AgendaSource aid) 1 | aid == agendaId -> do
      unshiftMessage (Resign iid)
      PredatorOrPrey <$> runMessage msg attrs
    _ -> PredatorOrPrey <$> runMessage msg attrs