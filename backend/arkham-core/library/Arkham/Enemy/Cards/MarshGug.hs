module Arkham.Enemy.Cards.MarshGug
  ( marshGug
  , MarshGug(..)
  ) where

import Arkham.Prelude

import Arkham.Enemy.Cards qualified as Cards
import Arkham.Classes
import Arkham.Enemy.Runner
import Arkham.Matcher
import Arkham.Trait

newtype MarshGug = MarshGug EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

marshGug :: EnemyCard MarshGug
marshGug = enemyWith
  MarshGug
  Cards.marshGug
  (3, Static 4, 3)
  (2, 1)
  (spawnAtL ?~ LocationWithTrait Bayou)

instance EnemyRunner env => RunMessage env MarshGug where
  runMessage msg (MarshGug attrs) = MarshGug <$> runMessage msg attrs
