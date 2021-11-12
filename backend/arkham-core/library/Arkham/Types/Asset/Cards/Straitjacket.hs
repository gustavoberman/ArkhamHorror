module Arkham.Types.Asset.Cards.Straitjacket
  ( straitjacket
  , Straitjacket(..)
  ) where

import Arkham.Prelude

import Arkham.Asset.Cards qualified as Cards
import Arkham.Types.Ability
import Arkham.Types.Asset.Attrs
import Arkham.Types.Card
import Arkham.Types.Cost
import Arkham.Types.Criteria

newtype Straitjacket = Straitjacket AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

straitjacket :: AssetCard Straitjacket
straitjacket = assetWith
  Straitjacket
  Cards.straitjacket
  (canLeavePlayByNormalMeansL .~ False)

instance HasAbilities Straitjacket where
  getAbilities (Straitjacket a) =
    [ restrictedAbility a 1 OnSameLocation $ ActionAbility Nothing $ ActionCost
        2
    ]

instance AssetRunner env => RunMessage env Straitjacket where
  runMessage msg a@(Straitjacket attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source -> do
      a <$ push (Discarded (toTarget attrs) (toCard attrs))
    _ -> Straitjacket <$> runMessage msg attrs