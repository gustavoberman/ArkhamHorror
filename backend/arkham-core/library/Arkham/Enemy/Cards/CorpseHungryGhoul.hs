module Arkham.Enemy.Cards.CorpseHungryGhoul
  ( corpseHungryGhoul
  , CorpseHungryGhoul(..)
  ) where

import Arkham.Prelude

import Arkham.Enemy.Cards qualified as Cards
import Arkham.Classes
import Arkham.Enemy.Runner
import Arkham.Matcher

newtype CorpseHungryGhoul = CorpseHungryGhoul EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

corpseHungryGhoul :: EnemyCard CorpseHungryGhoul
corpseHungryGhoul = enemyWith
  CorpseHungryGhoul
  Cards.corpseHungryGhoul
  (4, Static 3, 3)
  (2, 2)
  (spawnAtL ?~ LocationWithTitle "Bedroom")

instance EnemyRunner env => RunMessage env CorpseHungryGhoul where
  runMessage msg (CorpseHungryGhoul attrs) =
    CorpseHungryGhoul <$> runMessage msg attrs
