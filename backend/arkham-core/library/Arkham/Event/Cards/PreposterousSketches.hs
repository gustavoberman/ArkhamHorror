module Arkham.Event.Cards.PreposterousSketches
  ( preposterousSketches
  , PreposterousSketches(..)
  ) where

import Arkham.Prelude

import Arkham.Event.Cards qualified as Cards
import Arkham.Classes
import Arkham.Event.Attrs
import Arkham.Message

newtype PreposterousSketches = PreposterousSketches EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

preposterousSketches :: EventCard PreposterousSketches
preposterousSketches = event PreposterousSketches Cards.preposterousSketches

instance RunMessage env PreposterousSketches where
  runMessage msg e@(PreposterousSketches attrs) = case msg of
    InvestigatorPlayEvent iid eid _ _ _ | eid == toId attrs -> do
      e <$ pushAll [DrawCards iid 3 False, Discard (toTarget attrs)]
    _ -> PreposterousSketches <$> runMessage msg attrs
