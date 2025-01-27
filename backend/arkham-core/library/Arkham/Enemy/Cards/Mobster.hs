module Arkham.Enemy.Cards.Mobster
  ( mobster
  , Mobster(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Enemy.Cards qualified as Cards
import Arkham.Classes
import Arkham.Enemy.Runner
import Arkham.Matcher
import Arkham.Message hiding (EnemyAttacks)
import Arkham.Timing qualified as Timing

newtype Mobster = Mobster EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

mobster :: EnemyCard Mobster
mobster = enemy Mobster Cards.mobster (2, Static 2, 2) (1, 0)

instance HasAbilities Mobster where
  getAbilities (Mobster x) = withBaseAbilities
    x
    [ mkAbility x 1
      $ ForcedAbility
      $ EnemyAttacks Timing.After You
      $ EnemyWithId
      $ toId x
    ]

instance EnemyRunner env => RunMessage env Mobster where
  runMessage msg e@(Mobster attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      e <$ push (SpendResources iid 1)
    _ -> Mobster <$> runMessage msg attrs
