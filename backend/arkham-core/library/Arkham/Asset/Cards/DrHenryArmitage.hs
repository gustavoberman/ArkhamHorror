module Arkham.Asset.Cards.DrHenryArmitage
  ( DrHenryArmitage(..)
  , drHenryArmitage
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Matcher
import Arkham.Timing qualified as Timing

newtype DrHenryArmitage = DrHenryArmitage AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

drHenryArmitage :: AssetCard DrHenryArmitage
drHenryArmitage = ally DrHenryArmitage Cards.drHenryArmitage (2, 2)

instance HasAbilities DrHenryArmitage where
  getAbilities (DrHenryArmitage a) =
    [ restrictedAbility a 1 OwnsThis
      $ ReactionAbility
          (DrawCard Timing.After You (BasicCardMatch AnyCard) (DeckOf You))
      $ Costs [DiscardDrawnCardCost, ExhaustCost (toTarget a)]
    ]

instance AssetRunner env => RunMessage env DrHenryArmitage where
  runMessage msg a@(DrHenryArmitage attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      a <$ push (TakeResources iid 3 False)
    _ -> DrHenryArmitage <$> runMessage msg attrs
