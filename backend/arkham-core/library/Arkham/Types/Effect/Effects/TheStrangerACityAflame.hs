module Arkham.Types.Effect.Effects.TheStrangerACityAflame
  ( TheStrangerACityAflame(..)
  , theStrangerACityAflame
  ) where

import Arkham.Prelude

import Arkham.Types.Ability
import Arkham.Types.Classes
import Arkham.Types.Effect.Attrs
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.SkillType
import Arkham.Types.Source
import Arkham.Types.Target
import qualified Arkham.Types.Timing as Timing

newtype TheStrangerACityAflame = TheStrangerACityAflame EffectAttrs
  deriving anyclass (HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

theStrangerACityAflame :: EffectArgs -> TheStrangerACityAflame
theStrangerACityAflame = TheStrangerACityAflame . uncurry4 (baseAttrs "03047a")

instance HasAbilities TheStrangerACityAflame where
  getAbilities (TheStrangerACityAflame attrs) =
    [ mkAbility
          (ProxySource
            (LocationMatcherSource LocationWithAnyHorror)
            (toSource attrs)
          )
          1
          (ForcedAbility $ OrWindowMatcher
            [ Enters Timing.After You ThisLocation
            , TurnEnds Timing.When (You <> InvestigatorAt ThisLocation)
            ]
          )
        & abilityLimitL
        .~ PlayerLimit PerRound 1
    ]

instance HasQueue env => RunMessage env TheStrangerACityAflame where
  runMessage msg e@(TheStrangerACityAflame attrs) = case msg of
    UseCardAbility iid (ProxySource _ source) _ 1 _ | isSource attrs source ->
      e
        <$ push
             (BeginSkillTest
               iid
               source
               (InvestigatorTarget iid)
               Nothing
               SkillAgility
               3
             )
    FailedSkillTest _ _ source (SkillTestInitiatorTarget (InvestigatorTarget iid)) _ _
      | isSource attrs source
      -> e <$ push (InvestigatorAssignDamage iid source DamageAny 1 0)
    _ -> TheStrangerACityAflame <$> runMessage msg attrs