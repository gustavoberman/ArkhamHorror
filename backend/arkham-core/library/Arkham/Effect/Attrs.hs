module Arkham.Effect.Attrs
  ( module Arkham.Effect.Attrs
  ) where

import Arkham.Prelude

import Arkham.Json
import Arkham.Card
import Arkham.Classes
import Arkham.Effect.Window
import Arkham.EffectId
import Arkham.EffectMetadata
import Arkham.Message
import Arkham.Source
import Arkham.Target
import Arkham.Trait
import Arkham.Window (Window)

class IsEffect a

data EffectAttrs = EffectAttrs
  { effectId :: EffectId
  , effectCardCode :: Maybe CardCode
  , effectTarget :: Target
  , effectSource :: Source
  , effectTraits :: HashSet Trait
  , effectMetadata :: Maybe (EffectMetadata Window Message)
  , effectWindow :: Maybe EffectWindow
  }
  deriving stock (Show, Eq, Generic)

type EffectArgs = (EffectId, Maybe (EffectMetadata Window Message), Source, Target)

baseAttrs
  :: CardCode
  -> EffectId
  -> Maybe (EffectMetadata Window Message)
  -> Source
  -> Target
  -> EffectAttrs
baseAttrs cardCode eid meffectMetadata source target = EffectAttrs
  { effectId = eid
  , effectSource = source
  , effectTarget = target
  , effectCardCode = Just cardCode
  , effectMetadata = meffectMetadata
  , effectTraits = mempty
  , effectWindow = Nothing
  }

instance ToJSON EffectAttrs where
  toJSON = genericToJSON $ aesonOptions $ Just "effect"
  toEncoding = genericToEncoding $ aesonOptions $ Just "effect"

instance FromJSON EffectAttrs where
  parseJSON = genericParseJSON $ aesonOptions $ Just "effect"

instance HasAbilities EffectAttrs

instance HasQueue env => RunMessage env EffectAttrs where
  runMessage msg a@EffectAttrs {..} = case msg of
    EndSetup | EffectSetupWindow `elem` effectWindow ->
      a <$ push (DisableEffect effectId)
    EndPhase | EffectPhaseWindow `elem` effectWindow ->
      a <$ push (DisableEffect effectId)
    EndTurn _ | EffectTurnWindow `elem` effectWindow ->
      a <$ push (DisableEffect effectId)
    EndRound | EffectRoundWindow `elem` effectWindow ->
      a <$ push (DisableEffect effectId)
    SkillTestEnds _ | EffectSkillTestWindow `elem` effectWindow ->
      a <$ push (DisableEffect effectId)
    CancelSkillEffects -> case effectSource of
      (SkillSource _) -> a <$ push (DisableEffect effectId)
      _ -> pure a
    _ -> pure a

instance Entity EffectAttrs where
  type EntityId EffectAttrs = EffectId
  type EntityAttrs EffectAttrs = EffectAttrs
  toId = effectId
  toAttrs = id

instance TargetEntity EffectAttrs where
  toTarget = EffectTarget . toId
  isTarget EffectAttrs { effectId } (EffectTarget eid) = effectId == eid
  isTarget _ _ = False

instance SourceEntity EffectAttrs where
  toSource = EffectSource . toId
  isSource EffectAttrs { effectId } (EffectSource eid) = effectId == eid
  isSource _ _ = False
