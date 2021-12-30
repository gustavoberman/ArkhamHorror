module Arkham.Asset.Cards.Shrivelling5
  ( Shrivelling5(..)
  , shrivelling5
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Action qualified as Action
import Arkham.Asset.Attrs
import Arkham.Cost
import Arkham.Criteria
import Arkham.EffectMetadata
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target

newtype Shrivelling5 = Shrivelling5 AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, Generic, ToJSON, FromJSON, Entity)

shrivelling5 :: AssetCard Shrivelling5
shrivelling5 = asset Shrivelling5 Cards.shrivelling5

instance HasAbilities Shrivelling5 where
  getAbilities (Shrivelling5 a) =
    [ restrictedAbility a 1 OwnsThis $ ActionAbility
        (Just Action.Fight)
        (Costs [ActionCost 1, UseCost (toId a) Charge 1])
    ]

instance AssetRunner env => RunMessage env Shrivelling5 where
  runMessage msg a@(Shrivelling5 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> a <$ pushAll
      [ skillTestModifiers
        attrs
        (InvestigatorTarget iid)
        [SkillModifier SkillWillpower 3, DamageDealt 2]
      , CreateEffect
        "01060"
        (Just $ EffectInt 2)
        source
        (InvestigatorTarget iid)
      -- ^ reusing shrivelling(0)'s effect with a damage override
      , ChooseFightEnemy iid source Nothing SkillWillpower mempty False
      ]
    _ -> Shrivelling5 <$> runMessage msg attrs