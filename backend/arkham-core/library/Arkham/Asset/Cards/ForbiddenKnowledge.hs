module Arkham.Asset.Cards.ForbiddenKnowledge where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Target

newtype ForbiddenKnowledge = ForbiddenKnowledge AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

forbiddenKnowledge :: AssetCard ForbiddenKnowledge
forbiddenKnowledge = assetWith
  ForbiddenKnowledge
  Cards.forbiddenKnowledge
  (discardWhenNoUsesL .~ True)

instance HasAbilities ForbiddenKnowledge where
  getAbilities (ForbiddenKnowledge a) =
    [ restrictedAbility
        (toSource a)
        1
        OwnsThis
        (FastAbility $ Costs
          [ UseCost (toId a) Secret 1
          , HorrorCost (toSource a) YouTarget 1
          , ExhaustCost (toTarget a)
          ]
        )
    ]

instance (AssetRunner env) => RunMessage env ForbiddenKnowledge where
  runMessage msg a@(ForbiddenKnowledge attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      a <$ push (TakeResources iid 1 False)
    _ -> ForbiddenKnowledge <$> runMessage msg attrs
