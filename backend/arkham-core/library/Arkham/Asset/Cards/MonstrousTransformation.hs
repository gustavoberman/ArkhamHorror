module Arkham.Asset.Cards.MonstrousTransformation
  ( MonstrousTransformation(..)
  , monstrousTransformation
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

newtype MonstrousTransformation = MonstrousTransformation AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

monstrousTransformation :: AssetCard MonstrousTransformation
monstrousTransformation = assetWith
  MonstrousTransformation
  Cards.monstrousTransformation
  (isStoryL .~ True)

instance HasModifiersFor env MonstrousTransformation where
  getModifiersFor _ (InvestigatorTarget iid) (MonstrousTransformation a)
    | ownedBy a iid = pure $ toModifiers
      a
      [ BaseSkillOf SkillWillpower 2
      , BaseSkillOf SkillIntellect 2
      , BaseSkillOf SkillCombat 5
      , BaseSkillOf SkillAgility 5
      ]
  getModifiersFor _ _ _ = pure []

instance HasAbilities MonstrousTransformation where
  getAbilities (MonstrousTransformation a) =
    [ restrictedAbility a 1 OwnsThis $ ActionAbility
        (Just Action.Fight)
        (Costs [ExhaustCost (toTarget a), ActionCost 1])
    ]

instance (AssetRunner env) => RunMessage env MonstrousTransformation where
  runMessage msg a@(MonstrousTransformation attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> a <$ pushAll
      [ skillTestModifier attrs (InvestigatorTarget iid) (DamageDealt 1)
      , ChooseFightEnemy iid source Nothing SkillCombat mempty False
      ]
    _ -> MonstrousTransformation <$> runMessage msg attrs
