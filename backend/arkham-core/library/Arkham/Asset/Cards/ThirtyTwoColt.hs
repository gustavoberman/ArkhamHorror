module Arkham.Asset.Cards.ThirtyTwoColt
  ( thirtyTwoColt
  , ThirtyTwoColt(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Action qualified as Action
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target

newtype ThirtyTwoColt = ThirtyTwoColt AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

thirtyTwoColt :: AssetCard ThirtyTwoColt
thirtyTwoColt = asset ThirtyTwoColt Cards.thirtyTwoColt

instance HasAbilities ThirtyTwoColt where
  getAbilities (ThirtyTwoColt a) =
    [ restrictedAbility a 1 OwnsThis $ ActionAbility
        (Just Action.Fight)
        (Costs [ActionCost 1, UseCost (toId a) Ammo 1])
    ]

instance AssetRunner env => RunMessage env ThirtyTwoColt where
  runMessage msg a@(ThirtyTwoColt attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> a <$ pushAll
      [ skillTestModifier attrs (InvestigatorTarget iid) (DamageDealt 1)
      , ChooseFightEnemy iid source Nothing SkillCombat mempty False
      ]
    _ -> ThirtyTwoColt <$> runMessage msg attrs
