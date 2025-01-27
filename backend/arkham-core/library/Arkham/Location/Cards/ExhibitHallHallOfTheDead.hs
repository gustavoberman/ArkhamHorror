module Arkham.Location.Cards.ExhibitHallHallOfTheDead
  ( exhibitHallHallOfTheDead
  , ExhibitHallHallOfTheDead(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Location.Cards qualified as Cards (exhibitHallHallOfTheDead)
import Arkham.Classes
import Arkham.GameValue
import Arkham.Location.Runner
import Arkham.Location.Helpers
import Arkham.Matcher
import Arkham.Message
import Arkham.Timing qualified as Timing

newtype ExhibitHallHallOfTheDead = ExhibitHallHallOfTheDead LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

exhibitHallHallOfTheDead :: LocationCard ExhibitHallHallOfTheDead
exhibitHallHallOfTheDead = locationWithRevealedSideConnections
  ExhibitHallHallOfTheDead
  Cards.exhibitHallHallOfTheDead
  3
  (PerPlayer 2)
  NoSymbol
  [Square]
  Squiggle
  [Square, Hourglass]

instance HasAbilities ExhibitHallHallOfTheDead where
  getAbilities (ExhibitHallHallOfTheDead x) = withBaseAbilities
    x
    [ mkAbility x 1
      $ ForcedAbility
      $ SkillTestResult
          Timing.After
          You
          (WhileInvestigating $ LocationWithId $ toId x)
      $ FailureResult AnyValue
    | locationRevealed x
    ]

instance LocationRunner env => RunMessage env ExhibitHallHallOfTheDead where
  runMessage msg l@(ExhibitHallHallOfTheDead attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      l <$ push (InvestigatorAssignDamage iid source DamageAny 0 1)
    _ -> ExhibitHallHallOfTheDead <$> runMessage msg attrs
