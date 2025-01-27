module Arkham.Skill.Cards.TheHomeFront
  ( theHomeFront
  , TheHomeFront(..)
  ) where

import Arkham.Prelude

import Arkham.Skill.Cards qualified as Cards
import Arkham.Action
import Arkham.Classes
import Arkham.DamageEffect
import Arkham.Game.Helpers
import Arkham.Message
import Arkham.Query
import Arkham.Skill.Attrs
import Arkham.Skill.Runner
import Arkham.SkillTest
import Arkham.Target

newtype TheHomeFront = TheHomeFront SkillAttrs
  deriving anyclass (IsSkill, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

theHomeFront :: SkillCard TheHomeFront
theHomeFront = skill TheHomeFront Cards.theHomeFront

instance SkillRunner env => RunMessage env TheHomeFront where
  runMessage msg s@(TheHomeFront attrs@SkillAttrs {..}) = case msg of
    PassedSkillTest _ (Just Fight) _ target _ _ | isTarget attrs target -> do
      mSkillTestTarget <- getSkillTestTarget
      damageCount <- unDamageCount <$> getCount skillOwner
      s <$ case mSkillTestTarget of
        Just (EnemyTarget eid) -> do
          canDamage <- sourceCanDamageEnemy eid (toSource attrs)
          when
            (canDamage && damageCount > 0)
            do
              pushAll
                [ HealDamage (InvestigatorTarget skillOwner) 1
                , EnemyDamage eid skillOwner (toSource attrs) NonAttackDamageEffect 1
                ]
        _ -> pure ()
    _ -> TheHomeFront <$> runMessage msg attrs
