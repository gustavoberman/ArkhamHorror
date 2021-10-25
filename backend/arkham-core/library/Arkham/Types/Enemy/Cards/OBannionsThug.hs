module Arkham.Types.Enemy.Cards.OBannionsThug
  ( oBannionsThug
  , OBannionsThug(..)
  ) where

import Arkham.Prelude

import Arkham.Enemy.Cards qualified as Cards
import Arkham.Types.Classes
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Modifier
import Arkham.Types.Target

newtype OBannionsThug = OBannionsThug EnemyAttrs
  deriving anyclass IsEnemy
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

oBannionsThug :: EnemyCard OBannionsThug
oBannionsThug = enemy OBannionsThug Cards.oBannionsThug (4, Static 2, 2) (2, 0)

instance HasModifiersFor env OBannionsThug where
  getModifiersFor _ (InvestigatorTarget iid) (OBannionsThug a@EnemyAttrs {..})
    | iid `elem` enemyEngagedInvestigators = pure
    $ toModifiers a [CannotGainResources]
  getModifiersFor _ _ _ = pure []

instance (EnemyRunner env) => RunMessage env OBannionsThug where
  runMessage msg (OBannionsThug attrs) = OBannionsThug <$> runMessage msg attrs
