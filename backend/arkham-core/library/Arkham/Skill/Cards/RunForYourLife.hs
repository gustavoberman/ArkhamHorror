module Arkham.Skill.Cards.RunForYourLife
  ( runForYourLife
  , RunForYourLife(..)
  ) where

import Arkham.Prelude

import Arkham.Skill.Cards qualified as Cards
import Arkham.Classes
import Arkham.Skill.Attrs
import Arkham.Skill.Runner

newtype RunForYourLife = RunForYourLife SkillAttrs
  deriving anyclass (IsSkill, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

runForYourLife :: SkillCard RunForYourLife
runForYourLife = skill RunForYourLife Cards.runForYourLife

instance SkillRunner env => RunMessage env RunForYourLife where
  runMessage msg (RunForYourLife attrs) =
    RunForYourLife <$> runMessage msg attrs
