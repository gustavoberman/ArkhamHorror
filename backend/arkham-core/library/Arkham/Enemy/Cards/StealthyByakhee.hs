module Arkham.Enemy.Cards.StealthyByakhee
  ( stealthyByakhee
  , StealthyByakhee(..)
  ) where

import Arkham.Prelude

import Arkham.Classes
import Arkham.Modifier
import qualified Arkham.Enemy.Cards as Cards
import Arkham.Enemy.Runner

newtype StealthyByakhee = StealthyByakhee EnemyAttrs
  deriving anyclass IsEnemy
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

stealthyByakhee :: EnemyCard StealthyByakhee
stealthyByakhee =
  enemy StealthyByakhee Cards.stealthyByakhee (5, Static 2, 3) (2, 1)

instance HasModifiersFor env StealthyByakhee where
  getModifiersFor _ target (StealthyByakhee attrs) | isTarget attrs target =
    pure $ toModifiers attrs [ EnemyFight (-3) | enemyExhausted attrs ]
  getModifiersFor _ _ _ = pure []

instance EnemyRunner env => RunMessage env StealthyByakhee where
  runMessage msg (StealthyByakhee attrs) =
    StealthyByakhee <$> runMessage msg attrs
