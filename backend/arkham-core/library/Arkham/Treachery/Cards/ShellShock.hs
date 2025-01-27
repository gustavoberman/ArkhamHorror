module Arkham.Treachery.Cards.ShellShock
  ( shellShock
  , ShellShock(..)
  ) where

import Arkham.Prelude

import Arkham.Treachery.Cards qualified as Cards
import Arkham.Classes
import Arkham.Message
import Arkham.Query
import Arkham.Treachery.Attrs
import Arkham.Treachery.Runner

newtype ShellShock = ShellShock TreacheryAttrs
  deriving anyclass (IsTreachery, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

shellShock :: TreacheryCard ShellShock
shellShock = treachery ShellShock Cards.shellShock

instance TreacheryRunner env => RunMessage env ShellShock where
  runMessage msg t@(ShellShock attrs) = case msg of
    Revelation iid source | isSource attrs source -> do
      horrorCount <- (`div` 2) . unDamageCount <$> getCount iid
      t <$ push (InvestigatorAssignDamage iid source DamageAny 0 horrorCount)
    _ -> ShellShock <$> runMessage msg attrs
