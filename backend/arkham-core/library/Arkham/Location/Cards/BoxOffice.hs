module Arkham.Location.Cards.BoxOffice
  ( boxOffice
  , BoxOffice(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Location.Cards qualified as Cards
import Arkham.Classes
import Arkham.Cost
import Arkham.Criteria
import Arkham.GameValue
import Arkham.Location.Runner
import Arkham.Location.Helpers
import Arkham.Message
import Arkham.ScenarioLogKey

newtype BoxOffice = BoxOffice LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

boxOffice :: LocationCard BoxOffice
boxOffice = location BoxOffice Cards.boxOffice 2 (Static 0) Plus [Triangle]

instance HasAbilities BoxOffice where
  getAbilities (BoxOffice attrs) = withBaseAbilities
    attrs
    [ restrictedAbility attrs 1 Here $ ActionAbility Nothing $ ActionCost 1
    | locationRevealed attrs
    ]

instance LocationRunner env => RunMessage env BoxOffice where
  runMessage msg l@(BoxOffice attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      l <$ pushAll [TakeResources iid 5 False, Remember StoleFromTheBoxOffice]
    _ -> BoxOffice <$> runMessage msg attrs
