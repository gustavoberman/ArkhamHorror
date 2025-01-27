module Arkham.Location.Cards.HistoricalSocietyHistoricalMuseum_130
  ( historicalSocietyHistoricalMuseum_130
  , HistoricalSocietyHistoricalMuseum_130(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Location.Cards qualified as Cards
import Arkham.Action qualified as Action
import Arkham.Classes
import Arkham.GameValue
import Arkham.Location.Runner
import Arkham.Location.Helpers
import Arkham.Matcher hiding (RevealLocation)
import Arkham.Message
import Arkham.Modifier
import Arkham.SkillTest
import Arkham.SkillType
import Arkham.Source
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype HistoricalSocietyHistoricalMuseum_130 = HistoricalSocietyHistoricalMuseum_130 LocationAttrs
  deriving anyclass IsLocation
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

historicalSocietyHistoricalMuseum_130
  :: LocationCard HistoricalSocietyHistoricalMuseum_130
historicalSocietyHistoricalMuseum_130 = locationWithRevealedSideConnections
  HistoricalSocietyHistoricalMuseum_130
  Cards.historicalSocietyHistoricalMuseum_130
  2
  (PerPlayer 1)
  NoSymbol
  [Square]
  Heart
  [Square, Hourglass]

instance HasSkillTest env => HasModifiersFor env HistoricalSocietyHistoricalMuseum_130 where
  getModifiersFor (SkillTestSource _ _ _ (Just Action.Investigate)) (InvestigatorTarget _) (HistoricalSocietyHistoricalMuseum_130 attrs) = do
    mtarget <- getSkillTestTarget
    case mtarget of
      Just target | isTarget attrs target -> pure $ toModifiers attrs [SkillCannotBeIncreased SkillIntellect]
      _ -> pure []
  getModifiersFor _ _ _ = pure []

instance HasAbilities HistoricalSocietyHistoricalMuseum_130 where
  getAbilities (HistoricalSocietyHistoricalMuseum_130 attrs) =
    withBaseAbilities
      attrs
      [ mkAbility attrs 1 $ ForcedAbility $ EnemySpawns
          Timing.When
          (LocationWithId $ toId attrs)
          AnyEnemy
      | not (locationRevealed attrs)
      ]

instance LocationRunner env => RunMessage env HistoricalSocietyHistoricalMuseum_130 where
  runMessage msg l@(HistoricalSocietyHistoricalMuseum_130 attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      l <$ push (RevealLocation Nothing $ toId attrs)
    _ -> HistoricalSocietyHistoricalMuseum_130 <$> runMessage msg attrs
