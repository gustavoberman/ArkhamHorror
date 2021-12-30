module Arkham.Location.Cards.ExhibitHallAthabaskanExhibit
  ( exhibitHallAthabaskanExhibit
  , ExhibitHallAthabaskanExhibit(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Location.Cards qualified as Cards (exhibitHallAthabaskanExhibit)
import Arkham.Classes
import Arkham.GameValue
import Arkham.Location.Attrs
import Arkham.Location.Helpers
import Arkham.Matcher
import Arkham.Message
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype ExhibitHallAthabaskanExhibit = ExhibitHallAthabaskanExhibit LocationAttrs
  deriving anyclass IsLocation
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

exhibitHallAthabaskanExhibit :: LocationCard ExhibitHallAthabaskanExhibit
exhibitHallAthabaskanExhibit = locationWithRevealedSideConnections
  ExhibitHallAthabaskanExhibit
  Cards.exhibitHallAthabaskanExhibit
  1
  (Static 0)
  NoSymbol
  [Square]
  Plus
  [Square]

instance HasModifiersFor env ExhibitHallAthabaskanExhibit where
  getModifiersFor _ (InvestigatorTarget iid) (ExhibitHallAthabaskanExhibit attrs)
    = pure $ toModifiers attrs [ SkillModifier SkillAgility 2 | iid `on` attrs ]
  getModifiersFor _ _ _ = pure []

instance HasAbilities ExhibitHallAthabaskanExhibit where
  getAbilities (ExhibitHallAthabaskanExhibit x) = withBaseAbilities
    x
    [ mkAbility x 1
      $ ForcedAbility
      $ Enters Timing.After You
      $ LocationWithId
      $ toId x
    | locationRevealed x
    ]

instance LocationRunner env => RunMessage env ExhibitHallAthabaskanExhibit where
  runMessage msg l@(ExhibitHallAthabaskanExhibit attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      l <$ pushAll [SetActions iid source 0, ChooseEndTurn iid]
    _ -> ExhibitHallAthabaskanExhibit <$> runMessage msg attrs