module Arkham.Treachery.Cards.CollapsingReality
  ( collapsingReality
  , CollapsingReality(..)
  ) where

import Arkham.Prelude

import Arkham.Treachery.Cards qualified as Cards
import Arkham.Classes
import Arkham.Id
import Arkham.Message
import Arkham.Target
import Arkham.Trait
import Arkham.Treachery.Attrs
import Arkham.Treachery.Runner

newtype CollapsingReality = CollapsingReality TreacheryAttrs
  deriving anyclass (IsTreachery, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

collapsingReality :: TreacheryCard CollapsingReality
collapsingReality = treachery CollapsingReality Cards.collapsingReality

instance TreacheryRunner env => RunMessage env CollapsingReality where
  runMessage msg t@(CollapsingReality attrs) = case msg of
    Revelation iid source | isSource attrs source -> do
      lid <- getId @LocationId iid
      isExtradimensional <- member Extradimensional <$> getSet lid
      let
        revelationMsgs = if isExtradimensional
          then
            [ Discard (LocationTarget lid)
            , InvestigatorAssignDamage iid source DamageAny 1 0
            ]
          else [InvestigatorAssignDamage iid source DamageAny 2 0]
      t <$ pushAll revelationMsgs
    _ -> CollapsingReality <$> runMessage msg attrs
