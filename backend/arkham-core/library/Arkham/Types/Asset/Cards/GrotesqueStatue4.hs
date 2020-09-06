{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Asset.Cards.GrotesqueStatue4 where

import Arkham.Json
import Arkham.Types.Ability
import qualified Arkham.Types.Action as Action
import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Helpers
import Arkham.Types.Asset.Runner
import Arkham.Types.Asset.Uses (Uses(..), useCount)
import qualified Arkham.Types.Asset.Uses as Resource
import Arkham.Types.AssetId
import Arkham.Types.Classes
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.SkillType
import Arkham.Types.Slot
import Arkham.Types.Source
import Arkham.Types.Target
import qualified Arkham.Types.Token as Token
import Arkham.Types.TokenResponse
import ClassyPrelude
import Lens.Micro

newtype GrotesqueStatue4 = GrotesqueStatue4 Attrs
  deriving stock (Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

grotesqueStatue4 :: AssetId -> GrotesqueStatue4
grotesqueStatue4 uuid =
  GrotesqueStatue4 $ (baseAttrs uuid "01070") { assetSlots = [HandSlot] }

instance (ActionRunner env investigator) => HasActions env investigator GrotesqueStatue4 where
  getActions i window (GrotesqueStatue4 Attrs {..})
    | Just (getId () i) == assetInvestigator = do
      fightAvailable <- hasFightActions i window
      pure
        [ ActivateCardAbilityAction
            (getId () i)
            (mkAbility
              (AssetSource assetId)
              1
              (ActionAbility 1 (Just Action.Fight))
            )
        | useCount assetUses > 0 && fightAvailable
        ]
  getActions _ _ _ = pure []


instance (AssetRunner env) => RunMessage env GrotesqueStatue4 where
  runMessage msg a@(GrotesqueStatue4 attrs@Attrs {..}) = case msg of
    InvestigatorPlayAsset _ aid _ _ | aid == assetId ->
      GrotesqueStatue4
        <$> runMessage msg (attrs & uses .~ Uses Resource.Charge 4)
    UseCardAbility iid _ (AssetSource aid) _ 1 | aid == assetId ->
      case assetUses of
        Uses Resource.Charge n -> do
          when (n == 1) $ unshiftMessage (Discard (AssetTarget aid))
          unshiftMessage
            (ChooseFightEnemy
              iid
              SkillWillpower
              [DamageDealt 1]
              [ OnAnyToken
                  [ Token.Skull
                  , Token.Cultist
                  , Token.Tablet
                  , Token.ElderThing
                  , Token.AutoFail
                  ]
                  [ InvestigatorAssignDamage
                      (getInvestigator attrs)
                      (AssetSource assetId)
                      0
                      1
                  ]
              ]
              False
            )
          pure $ GrotesqueStatue4 $ attrs & uses .~ Uses Resource.Charge (n - 1)
        _ -> pure a
    _ -> GrotesqueStatue4 <$> runMessage msg attrs