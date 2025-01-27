module Arkham.Asset.Cards.HolyRosary where

import Arkham.Prelude

import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target

newtype HolyRosary = HolyRosary AssetAttrs
  deriving anyclass (IsAsset, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

holyRosary :: AssetCard HolyRosary
holyRosary = assetWith HolyRosary Cards.holyRosary (sanityL ?~ 2)

instance HasModifiersFor env  HolyRosary where
  getModifiersFor _ (InvestigatorTarget iid) (HolyRosary a) =
    pure [ toModifier a (SkillModifier SkillWillpower 1) | ownedBy a iid ]
  getModifiersFor _ _ _ = pure []

instance AssetRunner env => RunMessage env HolyRosary where
  runMessage msg (HolyRosary attrs) = HolyRosary <$> runMessage msg attrs
