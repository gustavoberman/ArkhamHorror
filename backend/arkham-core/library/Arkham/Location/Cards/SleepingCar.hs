module Arkham.Location.Cards.SleepingCar
  ( sleepingCar
  , SleepingCar(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Location.Cards qualified as Cards (sleepingCar)
import Arkham.Classes
import Arkham.Cost
import Arkham.Criteria
import Arkham.Direction
import Arkham.GameValue
import Arkham.Id
import Arkham.Location.Runner
import Arkham.Location.Helpers
import Arkham.Message
import Arkham.Modifier
import Arkham.Query
import Arkham.ScenarioLogKey

newtype SleepingCar = SleepingCar LocationAttrs
  deriving anyclass IsLocation
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

sleepingCar :: LocationCard SleepingCar
sleepingCar = locationWith
  SleepingCar
  Cards.sleepingCar
  4
  (Static 1)
  NoSymbol
  []
  (connectsToL .~ setFromList [LeftOf, RightOf])

instance HasCount ClueCount env LocationId => HasModifiersFor env SleepingCar where
  getModifiersFor _ target (SleepingCar l@LocationAttrs {..})
    | isTarget l target = case lookup LeftOf locationDirections of
      Just leftLocation -> do
        clueCount <- unClueCount <$> getCount leftLocation
        pure $ toModifiers l [ Blocked | not locationRevealed && clueCount > 0 ]
      Nothing -> pure []
  getModifiersFor _ _ _ = pure []

instance HasAbilities SleepingCar where
  getAbilities (SleepingCar attrs) =
    withBaseAbilities attrs $
      [ restrictedAbility attrs 1 Here (ActionAbility Nothing $ ActionCost 1)
          & (abilityLimitL .~ GroupLimit PerGame 1)
      | locationRevealed attrs
      ]

instance LocationRunner env => RunMessage env SleepingCar where
  runMessage msg l@(SleepingCar attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      l <$ pushAll
        [TakeResources iid 3 False, Remember StolenAPassengersLuggage]
    _ -> SleepingCar <$> runMessage msg attrs
