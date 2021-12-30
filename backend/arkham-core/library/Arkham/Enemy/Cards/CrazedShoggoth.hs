module Arkham.Enemy.Cards.CrazedShoggoth
  ( CrazedShoggoth(..)
  , crazedShoggoth
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Enemy.Cards qualified as Cards
import Arkham.Classes
import Arkham.Enemy.Attrs
import Arkham.Matcher
import Arkham.Message hiding (InvestigatorDefeated)
import Arkham.Source
import Arkham.Timing qualified as Timing
import Arkham.Trait

newtype CrazedShoggoth = CrazedShoggoth EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

crazedShoggoth :: EnemyCard CrazedShoggoth
crazedShoggoth = enemyWith
  CrazedShoggoth
  Cards.crazedShoggoth
  (3, Static 6, 4)
  (2, 2)
  (spawnAtL ?~ NearestLocationToYou (LocationWithTrait Altered))

instance HasAbilities CrazedShoggoth where
  getAbilities (CrazedShoggoth attrs) = withBaseAbilities
    attrs
    [ mkAbility attrs 1 $ ForcedAbility $ InvestigatorDefeated
        Timing.When
        (SourceIs $ AttackSource $ toId attrs)
        You
    ]

instance EnemyRunner env => RunMessage env CrazedShoggoth where
  runMessage msg e@(CrazedShoggoth attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      e <$ push (InvestigatorKilled source iid)
    _ -> CrazedShoggoth <$> runMessage msg attrs