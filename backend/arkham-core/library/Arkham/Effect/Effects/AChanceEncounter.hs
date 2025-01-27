module Arkham.Effect.Effects.AChanceEncounter
  ( aChanceEncounter
  , AChanceEncounter(..)
  ) where

import Arkham.Prelude

import Arkham.Classes
import Arkham.Effect.Attrs
import Arkham.Message
import Arkham.Target

newtype AChanceEncounter = AChanceEncounter EffectAttrs
  deriving anyclass (HasAbilities, IsEffect)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

aChanceEncounter :: EffectArgs -> AChanceEncounter
aChanceEncounter = AChanceEncounter . uncurry4 (baseAttrs "02270")

instance HasModifiersFor env AChanceEncounter

instance HasQueue env => RunMessage env AChanceEncounter where
  runMessage msg e@(AChanceEncounter attrs@EffectAttrs {..}) = case msg of
    EndRoundWindow -> case effectTarget of
      CardIdTarget cardId ->
        e <$ pushAll [Discard $ CardIdTarget cardId, DisableEffect effectId]
      _ -> error "Wrong target type"
    _ -> AChanceEncounter <$> runMessage msg attrs
