module Arkham.Asset.Cards.KeenEye
  ( keenEye
  , KeenEye(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Effect.Window
import Arkham.EffectMetadata
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target

newtype KeenEye = KeenEye AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

keenEye :: AssetCard KeenEye
keenEye = asset KeenEye Cards.keenEye

instance HasAbilities KeenEye where
  getAbilities (KeenEye a) =
    [ restrictedAbility a idx OwnsThis (FastAbility $ ResourceCost 2)
    | idx <- [1, 2]
    ]

instance AssetRunner env => RunMessage env KeenEye where
  runMessage msg a@(KeenEye attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> a <$ push
      (CreateWindowModifierEffect
        EffectPhaseWindow
        (EffectModifiers $ toModifiers attrs [SkillModifier SkillIntellect 1])
        source
        (InvestigatorTarget iid)
      )
    UseCardAbility iid source _ 2 _ | isSource attrs source -> a <$ push
      (CreateWindowModifierEffect
        EffectPhaseWindow
        (EffectModifiers $ toModifiers attrs [SkillModifier SkillCombat 1])
        source
        (InvestigatorTarget iid)
      )
    _ -> KeenEye <$> runMessage msg attrs
