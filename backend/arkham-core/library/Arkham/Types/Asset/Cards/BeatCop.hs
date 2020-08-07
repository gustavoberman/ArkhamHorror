{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Asset.Cards.BeatCop where

import Arkham.Json
import Arkham.Types.Ability
import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Runner
import Arkham.Types.AssetId
import Arkham.Types.Classes
import Arkham.Types.LocationId
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.SkillType
import Arkham.Types.Slot
import Arkham.Types.Source
import Arkham.Types.Target
import ClassyPrelude
import qualified Data.HashSet as HashSet

newtype BeatCop = BeatCop Attrs
  deriving newtype (Show, ToJSON, FromJSON)

beatCop :: AssetId -> BeatCop
beatCop uuid = BeatCop $ (baseAttrs uuid "01018")
  { assetSlots = [AllySlot]
  , assetHealth = Just 2
  , assetSanity = Just 2
  , assetAbilities =
    [(AssetSource uuid, Nothing, 1, FreeAbility AnyWindow, NoLimit)]
  }

instance (AssetRunner env) => RunMessage env BeatCop where
  runMessage msg a@(BeatCop attrs@Attrs {..}) = case msg of
    InvestigatorPlayAsset iid aid _ _ | aid == assetId -> do
      unshiftMessage
        (AddModifier
          (InvestigatorTarget iid)
          (SkillModifier SkillCombat 1 (AssetSource aid))
        )
      pure a
    UseCardAbility iid (AssetSource aid, _, 1, _, _) | aid == assetId -> do
      locationId <- asks (getId @LocationId (getInvestigator attrs))
      locationEnemyIds <- HashSet.toList <$> asks (getSet locationId)
      unshiftMessages
        [ DiscardAsset aid
        , Ask $ ChooseOne
          [ EnemyDamage eid iid (AssetSource assetId) 1
          | eid <- locationEnemyIds
          ]
        ]
      pure a
    _ -> BeatCop <$> runMessage msg attrs