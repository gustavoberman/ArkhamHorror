module Arkham.Effect.Effects.WindowModifierEffect
  ( windowModifierEffect
  , WindowModifierEffect(..)
  ) where

import Arkham.Prelude

import Arkham.Classes
import Arkham.Effect.Attrs
import Arkham.Effect.Window
import Arkham.EffectId
import Arkham.EffectMetadata
import Arkham.Message
import Arkham.Source
import Arkham.Target
import Arkham.Window (Window)

newtype WindowModifierEffect = WindowModifierEffect EffectAttrs
  deriving anyclass (HasAbilities, IsEffect)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

windowModifierEffect
  :: EffectId
  -> EffectMetadata Window Message
  -> EffectWindow
  -> Source
  -> Target
  -> WindowModifierEffect
windowModifierEffect eid metadata effectWindow source target =
  WindowModifierEffect $ EffectAttrs
    { effectId = eid
    , effectSource = source
    , effectTarget = target
    , effectCardCode = Nothing
    , effectMetadata = Just metadata
    , effectTraits = mempty
    , effectWindow = Just effectWindow
    }

instance HasModifiersFor env WindowModifierEffect where
  getModifiersFor _ target (WindowModifierEffect EffectAttrs {..})
    | target == effectTarget = case effectMetadata of
      Just (EffectModifiers modifiers) -> pure modifiers
      Just (FailedByEffectModifiers modifiers) -> pure modifiers
      _ -> pure []
  getModifiersFor _ _ _ = pure []

instance HasQueue env => RunMessage env WindowModifierEffect where
  runMessage msg e@(WindowModifierEffect attrs) = case msg of
    CancelFailedByModifierEffects -> case effectMetadata attrs of
      Just (FailedByEffectModifiers _) ->
        e <$ push (DisableEffect $ toId attrs)
      _ -> pure e
    _ -> WindowModifierEffect <$> runMessage msg attrs
