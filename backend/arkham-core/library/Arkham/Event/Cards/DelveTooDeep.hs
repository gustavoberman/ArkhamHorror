module Arkham.Event.Cards.DelveTooDeep
  ( delveTooDeep
  , DelveTooDeep(..)
  ) where

import Arkham.Prelude

import Arkham.Event.Cards qualified as Cards
import Arkham.Classes
import Arkham.Event.Attrs
import Arkham.Message

newtype DelveTooDeep = DelveTooDeep EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

delveTooDeep :: EventCard DelveTooDeep
delveTooDeep = event DelveTooDeep Cards.delveTooDeep

instance HasQueue env => RunMessage env DelveTooDeep where
  runMessage msg e@(DelveTooDeep attrs@EventAttrs {..}) = case msg of
    InvestigatorPlayEvent _ eid _ _ _ | eid == eventId -> do
      e <$ pushAll [AllDrawEncounterCard, AddToVictory (toTarget attrs)]
    _ -> DelveTooDeep <$> runMessage msg attrs
