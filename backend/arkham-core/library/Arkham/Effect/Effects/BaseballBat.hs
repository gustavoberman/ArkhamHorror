module Arkham.Effect.Effects.BaseballBat
  ( baseballBat
  , BaseballBat(..)
  ) where

import Arkham.Prelude

import Arkham.Classes
import Arkham.Effect.Attrs
import Arkham.Message
import Arkham.Source
import Arkham.Target
import Arkham.Token

newtype BaseballBat = BaseballBat EffectAttrs
  deriving anyclass (HasAbilities, IsEffect)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

baseballBat :: EffectArgs -> BaseballBat
baseballBat = BaseballBat . uncurry4 (baseAttrs "01074")

instance HasModifiersFor env BaseballBat

instance HasQueue env => RunMessage env BaseballBat where
  runMessage msg e@(BaseballBat attrs@EffectAttrs {..}) = case msg of
    RevealToken _ iid token | InvestigatorTarget iid == effectTarget ->
      case effectSource of
        AssetSource assetId -> e <$ when
          (tokenFace token `elem` [Skull, AutoFail])
          (pushAll [Discard (AssetTarget assetId), DisableEffect effectId])
        _ -> error "wrong source"
    SkillTestEnds _ -> e <$ push (DisableEffect effectId)
    _ -> BaseballBat <$> runMessage msg attrs
