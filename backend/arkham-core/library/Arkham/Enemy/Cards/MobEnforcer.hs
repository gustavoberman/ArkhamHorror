module Arkham.Enemy.Cards.MobEnforcer
  ( MobEnforcer(..)
  , mobEnforcer
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Action
import Arkham.Classes
import Arkham.Cost
import Arkham.Criteria
import Arkham.Enemy.Cards qualified as Cards
import Arkham.Enemy.Runner
import Arkham.Matcher
import Arkham.Message
import Arkham.Source

newtype MobEnforcer = MobEnforcer EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

mobEnforcer :: EnemyCard MobEnforcer
mobEnforcer = enemyWith
  MobEnforcer
  Cards.mobEnforcer
  (4, Static 3, 3)
  (1, 0)
  (preyL .~ Bearer)

instance HasAbilities MobEnforcer where
  getAbilities (MobEnforcer attrs) = withBaseAbilities
    attrs
    [ restrictedAbility attrs 1 OnSameLocation
        $ ActionAbility (Just Parley) (Costs [ActionCost 1, ResourceCost 4])
    ]

instance EnemyRunner env => RunMessage env MobEnforcer where
  runMessage msg e@(MobEnforcer attrs@EnemyAttrs {..}) = case msg of
    UseCardAbility _ (EnemySource eid) _ 1 _ | eid == enemyId ->
      e <$ push (Discard $ toTarget attrs)
    _ -> MobEnforcer <$> runMessage msg attrs
