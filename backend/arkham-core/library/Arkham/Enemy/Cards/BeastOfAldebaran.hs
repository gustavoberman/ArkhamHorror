module Arkham.Enemy.Cards.BeastOfAldebaran
  ( beastOfAldebaran
  , BeastOfAldebaran(..)
  ) where

import Arkham.Prelude

import Arkham.Enemy.Cards qualified as Cards
import Arkham.Classes
import Arkham.Enemy.Attrs
import Arkham.Strategy

newtype BeastOfAldebaran = BeastOfAldebaran EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

beastOfAldebaran :: EnemyCard BeastOfAldebaran
beastOfAldebaran = enemyWith
  BeastOfAldebaran
  Cards.beastOfAldebaran
  (3, Static 7, 5)
  (2, 1)
  (damageStrategyL .~ SingleTarget)

instance EnemyRunner env => RunMessage env BeastOfAldebaran where
  runMessage msg (BeastOfAldebaran attrs) =
    BeastOfAldebaran <$> runMessage msg attrs