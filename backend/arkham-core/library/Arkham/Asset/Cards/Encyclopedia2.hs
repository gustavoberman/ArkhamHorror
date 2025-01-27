module Arkham.Asset.Cards.Encyclopedia2
  ( Encyclopedia2(..)
  , encyclopedia2
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Effect.Window
import Arkham.EffectMetadata
import Arkham.LocationId
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target

newtype Encyclopedia2 = Encyclopedia2 AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

encyclopedia2 :: AssetCard Encyclopedia2
encyclopedia2 = asset Encyclopedia2 Cards.encyclopedia2

instance HasAbilities Encyclopedia2 where
  getAbilities (Encyclopedia2 a) =
    [ restrictedAbility a 1 OwnsThis $ ActionAbility Nothing $ Costs
        [ActionCost 1, ExhaustCost $ toTarget a]
    ]

instance (AssetRunner env) => RunMessage env Encyclopedia2 where
  runMessage msg (Encyclopedia2 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      locationId <- getId @LocationId iid
      investigatorTargets <- map InvestigatorTarget <$> getSetList locationId
      push $ chooseOne
        iid
        [ TargetLabel
            target
            [ chooseOne
                iid
                [ Label
                    label
                    [ CreateWindowModifierEffect
                        EffectPhaseWindow
                        (EffectModifiers
                        $ toModifiers attrs [SkillModifier skill 2]
                        )
                        source
                        target
                    ]
                | (label, skill) <-
                  [ ("Willpower", SkillWillpower)
                  , ("Intellect", SkillIntellect)
                  , ("Combat", SkillCombat)
                  , ("Agility", SkillAgility)
                  ]
                ]
            ]
        | target <- investigatorTargets
        ]
      pure $ Encyclopedia2 $ attrs & exhaustedL .~ True
    _ -> Encyclopedia2 <$> runMessage msg attrs
