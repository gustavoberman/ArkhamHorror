module Arkham.Act.Cards.SearchingForTheTome
  ( SearchingForTheTome(..)
  , searchingForTheTome
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Act.Attrs
import Arkham.Act.Cards qualified as Cards
import Arkham.Act.Helpers
import Arkham.Act.Runner
import Arkham.Classes
import Arkham.Criteria
import Arkham.Location.Cards qualified as Cards
import Arkham.Matcher
import Arkham.Message
import Arkham.Resolution

newtype SearchingForTheTome = SearchingForTheTome ActAttrs
  deriving anyclass (IsAct, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

searchingForTheTome :: ActCard SearchingForTheTome
searchingForTheTome =
  act (3, A) SearchingForTheTome Cards.searchingForTheTome Nothing

instance HasAbilities SearchingForTheTome where
  getAbilities (SearchingForTheTome x) =
    [ restrictedAbility
        x
        1
        (LocationExists
        $ locationIs Cards.exhibitHallRestrictedHall
        <> LocationWithoutClues
        )
      $ Objective
      $ ForcedAbility AnyWindow
    ]

instance ActRunner env => RunMessage env SearchingForTheTome where
  runMessage msg a@(SearchingForTheTome attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      a <$ push (AdvanceAct (toId attrs) source AdvancedWithOther)
    AdvanceAct aid _ _ | aid == toId attrs && onSide B attrs -> do
      leadInvestigatorId <- getLeadInvestigatorId
      a <$ push
        (chooseOne
          leadInvestigatorId
          [ Label
            "It's too dangerous to keep around. We have to destroy it. (-> R1)"
            [ScenarioResolution $ Resolution 1]
          , Label
            "It's too valuable to destroy. We have to keep it safe. (-> R2)"
            [ScenarioResolution $ Resolution 2]
          ]
        )
    _ -> SearchingForTheTome <$> runMessage msg attrs
