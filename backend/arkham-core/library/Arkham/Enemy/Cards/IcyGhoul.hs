module Arkham.Enemy.Cards.IcyGhoul
  ( icyGhoul
  , IcyGhoul(..)
  ) where

import Arkham.Prelude

import Arkham.Enemy.Cards qualified as Cards
import Arkham.Classes
import Arkham.Enemy.Runner
import Arkham.Matcher

newtype IcyGhoul = IcyGhoul EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

icyGhoul :: EnemyCard IcyGhoul
icyGhoul = enemyWith
  IcyGhoul
  Cards.icyGhoul
  (3, Static 4, 4)
  (2, 1)
  (spawnAtL ?~ LocationWithTitle "Cellar")

instance EnemyRunner env => RunMessage env IcyGhoul where
  runMessage msg (IcyGhoul attrs) = IcyGhoul <$> runMessage msg attrs
