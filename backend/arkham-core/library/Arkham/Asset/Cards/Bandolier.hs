module Arkham.Asset.Cards.Bandolier
  ( Bandolier(..)
  , bandolier
  ) where

import Arkham.Prelude

import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Slot
import Arkham.Trait

newtype Bandolier = Bandolier AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

bandolier :: AssetCard Bandolier
bandolier = assetWith Bandolier Cards.bandolier (healthL ?~ 1)

slot :: AssetAttrs -> Slot
slot attrs = TraitRestrictedSlot (toSource attrs) Weapon Nothing

instance AssetRunner env => RunMessage env Bandolier where
  runMessage msg (Bandolier attrs) = case msg of
    InvestigatorPlayAsset iid aid _ _ | aid == assetId attrs -> do
      push $ AddSlot iid HandSlot (slot attrs)
      Bandolier <$> runMessage msg attrs
    _ -> Bandolier <$> runMessage msg attrs
