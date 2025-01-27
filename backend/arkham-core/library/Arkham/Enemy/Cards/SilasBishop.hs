module Arkham.Enemy.Cards.SilasBishop
  ( SilasBishop(..)
  , silasBishop
  ) where

import Arkham.Prelude

import Arkham.Enemy.Cards qualified as Cards
import Arkham.Classes
import Arkham.Enemy.Runner
import Arkham.Modifier

newtype SilasBishop = SilasBishop EnemyAttrs
  deriving anyclass IsEnemy
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

silasBishop :: EnemyCard SilasBishop
silasBishop = enemy SilasBishop Cards.silasBishop (3, PerPlayer 6, 7) (2, 2)

instance HasModifiersFor env SilasBishop where
  getModifiersFor _ target (SilasBishop attrs) | isTarget attrs target =
    pure $ toModifiers attrs [CannotMakeAttacksOfOpportunity]
  getModifiersFor _ _ _ = pure []

instance EnemyRunner env => RunMessage env SilasBishop where
  runMessage msg (SilasBishop attrs) = SilasBishop <$> runMessage msg attrs
