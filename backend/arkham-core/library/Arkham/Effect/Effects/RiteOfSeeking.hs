module Arkham.Effect.Effects.RiteOfSeeking
  ( riteOfSeeking
  , RiteOfSeeking(..)
  ) where

import Arkham.Prelude

import Arkham.Action qualified as Action
import Arkham.Classes
import Arkham.Effect.Attrs
import Arkham.Message
import Arkham.Target
import Arkham.Token

newtype RiteOfSeeking = RiteOfSeeking EffectAttrs
  deriving anyclass (HasAbilities, IsEffect)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

riteOfSeeking :: EffectArgs -> RiteOfSeeking
riteOfSeeking = RiteOfSeeking . uncurry4 (baseAttrs "02028")

instance HasModifiersFor env RiteOfSeeking

instance (HasQueue env) => RunMessage env RiteOfSeeking where
  runMessage msg e@(RiteOfSeeking attrs@EffectAttrs {..}) = case msg of
    RevealToken _ iid token -> case effectTarget of
      InvestigationTarget iid' _ | iid == iid' -> e <$ when
        (tokenFace token `elem` [Skull, Cultist, Tablet, ElderThing, AutoFail])
        (push $ CreateEffect
          "02028"
          Nothing
          (toSource attrs)
          (InvestigatorTarget iid)
        )
      _ -> pure e
    SkillTestEnds _ -> e <$ case effectTarget of
      InvestigatorTarget iid -> pushAll [DisableEffect effectId, EndTurn iid]
      _ -> push (DisableEffect effectId)
    Successful (Action.Investigate, _) iid source _ _
      | effectSource == source -> case effectTarget of
        InvestigationTarget _ lid' ->
          e <$ push
            (InvestigatorDiscoverClues iid lid' 1 (Just Action.Investigate))
        _ -> pure e
    _ -> RiteOfSeeking <$> runMessage msg attrs
