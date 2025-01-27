module Arkham.Location.Cards.SlaughteredWoods
  ( slaughteredWoods
  , SlaughteredWoods(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Location.Cards qualified as Cards (slaughteredWoods)
import Arkham.Classes
import Arkham.Criteria
import Arkham.GameValue
import Arkham.Location.Runner
import Arkham.Location.Helpers
import Arkham.Matcher
import Arkham.Message hiding (RevealLocation)
import Arkham.Timing qualified as Timing

newtype SlaughteredWoods = SlaughteredWoods LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

slaughteredWoods :: LocationCard SlaughteredWoods
slaughteredWoods = locationWithRevealedSideConnections
  SlaughteredWoods
  Cards.slaughteredWoods
  2
  (PerPlayer 1)
  NoSymbol
  []
  Plus
  [Triangle, Hourglass]

instance HasAbilities SlaughteredWoods where
  getAbilities (SlaughteredWoods attrs) =
    withBaseAbilities attrs
      $ [ restrictedAbility
              attrs
              1
              (InvestigatorExists $ You <> InvestigatorWithoutActionsRemaining)
            $ ForcedAbility
                (RevealLocation Timing.After You $ LocationWithId $ toId attrs)
        | locationRevealed attrs
        ]

instance LocationRunner env => RunMessage env SlaughteredWoods where
  runMessage msg l@(SlaughteredWoods attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      l <$ push (InvestigatorAssignDamage iid source DamageAny 0 2)
    _ -> SlaughteredWoods <$> runMessage msg attrs
