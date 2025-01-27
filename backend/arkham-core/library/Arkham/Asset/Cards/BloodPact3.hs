module Arkham.Asset.Cards.BloodPact3
  ( bloodPact3
  , BloodPact3(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target

newtype BloodPact3 = BloodPact3 AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

bloodPact3 :: AssetCard BloodPact3
bloodPact3 = asset BloodPact3 Cards.bloodPact3

instance HasAbilities BloodPact3 where
  getAbilities (BloodPact3 x) =
    [ restrictedAbility x idx OwnsThis (FastAbility $ ResourceCost 2)
      & abilityLimitL
      .~ PlayerLimit PerTestOrAbility 1
    | idx <- [1 .. 2]
    ]

instance AssetRunner env => RunMessage env BloodPact3 where
  runMessage msg a@(BloodPact3 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> a <$ push
      (skillTestModifier
        source
        (InvestigatorTarget iid)
        (SkillModifier SkillIntellect 3)
      )
    UseCardAbility iid source _ 2 _ | isSource attrs source -> a <$ push
      (skillTestModifier
        source
        (InvestigatorTarget iid)
        (SkillModifier SkillIntellect 3)
      )
    _ -> BloodPact3 <$> runMessage msg attrs
