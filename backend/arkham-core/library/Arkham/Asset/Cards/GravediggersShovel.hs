module Arkham.Asset.Cards.GravediggersShovel
  ( gravediggersShovel
  , GravediggersShovel(..)
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

newtype GravediggersShovel = GravediggersShovel AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

gravediggersShovel :: AssetCard GravediggersShovel
gravediggersShovel = asset GravediggersShovel Cards.gravediggersShovel

instance HasAbilities GravediggersShovel where
  getAbilities (GravediggersShovel x) =
    [ restrictedAbility x 1 OwnsThis
      $ ActionAbility (Just Action.Fight) (ActionCost 1)
    , restrictedAbility x 2 OwnsThis $ ActionAbility Nothing $ Costs
      [ActionCost 1, DiscardCost (toTarget x)]
    ]

instance AssetRunner env => RunMessage env GravediggersShovel where
  runMessage msg a@(GravediggersShovel attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> a <$ pushAll
      [ skillTestModifier
        attrs
        (InvestigatorTarget iid)
        (SkillModifier SkillCombat 2)
      , ChooseFightEnemy iid source Nothing SkillCombat mempty False
      ]
    UseCardAbility iid source _ 2 _ | isSource attrs source ->
      a <$ push (InvestigatorDiscoverCluesAtTheirLocation iid 1 Nothing)
    _ -> GravediggersShovel <$> runMessage msg attrs
