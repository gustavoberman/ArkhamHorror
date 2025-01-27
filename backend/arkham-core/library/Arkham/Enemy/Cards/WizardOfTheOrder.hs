module Arkham.Enemy.Cards.WizardOfTheOrder
  ( WizardOfTheOrder(..)
  , wizardOfTheOrder
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Enemy.Cards qualified as Cards
import Arkham.Classes
import Arkham.Enemy.Runner
import Arkham.Matcher
import Arkham.Message
import Arkham.Phase
import Arkham.Timing qualified as Timing

newtype WizardOfTheOrder = WizardOfTheOrder EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

wizardOfTheOrder :: EnemyCard WizardOfTheOrder
wizardOfTheOrder = enemyWith
  WizardOfTheOrder
  Cards.wizardOfTheOrder
  (4, Static 2, 2)
  (1, 0)
  (spawnAtL ?~ EmptyLocation)

instance HasAbilities WizardOfTheOrder where
  getAbilities (WizardOfTheOrder a) = withBaseAbilities
    a
    [ mkAbility a 1 $ ForcedAbility $ PhaseEnds Timing.After $ PhaseIs
        MythosPhase
    ]

instance EnemyRunner env => RunMessage env WizardOfTheOrder where
  runMessage msg e@(WizardOfTheOrder attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      e <$ push (PlaceDoom (toTarget attrs) 1)
    _ -> WizardOfTheOrder <$> runMessage msg attrs
