module Arkham.Skill.Cards.DoubleOrNothing
  ( doubleOrNothing
  , DoubleOrNothing(..)
  ) where

import Arkham.Prelude

import Arkham.Skill.Cards qualified as Cards
import Arkham.Classes
import Arkham.Game.Helpers
import Arkham.Modifier
import Arkham.Skill.Attrs
import Arkham.Target

newtype DoubleOrNothing = DoubleOrNothing SkillAttrs
  deriving anyclass (IsSkill, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

doubleOrNothing :: SkillCard DoubleOrNothing
doubleOrNothing = skill DoubleOrNothing Cards.doubleOrNothing

instance HasModifiersFor env DoubleOrNothing where
  getModifiersFor _ SkillTestTarget (DoubleOrNothing attrs) =
    pure $ toModifiers attrs [DoubleDifficulty, DoubleSuccess]
  getModifiersFor _ _ _ = pure []

instance RunMessage env DoubleOrNothing where
  runMessage msg (DoubleOrNothing attrs) =
    DoubleOrNothing <$> runMessage msg attrs
