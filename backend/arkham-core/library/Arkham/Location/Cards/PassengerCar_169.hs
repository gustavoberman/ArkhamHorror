module Arkham.Location.Cards.PassengerCar_169
  ( passengerCar_169
  , PassengerCar_169(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Location.Cards qualified as Cards (passengerCar_169)
import Arkham.Classes
import Arkham.Cost
import Arkham.Direction
import Arkham.GameValue
import Arkham.Id
import Arkham.Location.Runner
import Arkham.Location.Helpers
import Arkham.Matcher
import Arkham.Message
import Arkham.Modifier
import Arkham.Query
import Arkham.SkillType
import Arkham.Timing qualified as Timing
import Arkham.Window

newtype PassengerCar_169 = PassengerCar_169 LocationAttrs
  deriving anyclass IsLocation
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

passengerCar_169 :: LocationCard PassengerCar_169
passengerCar_169 = locationWith
  PassengerCar_169
  Cards.passengerCar_169
  2
  (PerPlayer 2)
  NoSymbol
  []
  (connectsToL .~ setFromList [LeftOf, RightOf])

instance HasCount ClueCount env LocationId => HasModifiersFor env PassengerCar_169 where
  getModifiersFor _ target (PassengerCar_169 l@LocationAttrs {..})
    | isTarget l target = case lookup LeftOf locationDirections of
      Just leftLocation -> do
        clueCount <- unClueCount <$> getCount leftLocation
        pure $ toModifiers l [ Blocked | not locationRevealed && clueCount > 0 ]
      Nothing -> pure []
  getModifiersFor _ _ _ = pure []

instance HasAbilities PassengerCar_169 where
  getAbilities (PassengerCar_169 x) = withBaseAbilities
    x
    [ mkAbility x 1
      $ ForcedAbility
      $ Enters Timing.After You
      $ LocationWithId
      $ toId x
    | locationRevealed x
    ]

instance LocationRunner env => RunMessage env PassengerCar_169 where
  runMessage msg l@(PassengerCar_169 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      let cost = SkillIconCost 2 (singleton SkillWillpower)
      hasSkills <- getCanAffordCost
        iid
        (toSource attrs)
        Nothing
        [Window Timing.When NonFast]
        cost
      l <$ if hasSkills
        then push
          (chooseOne
            iid
            [ Label
              "Take 2 horror"
              [InvestigatorAssignDamage iid (toSource attrs) DamageAny 0 2]
            , Label
              "Discard cards with at least 2 {willpower} icons"
              [ CreatePayAbilityCostEffect
                  (abilityEffect attrs cost)
                  (toSource attrs)
                  (toTarget attrs)
                  []
              ]
            ]
          )
        else push (InvestigatorAssignDamage iid (toSource attrs) DamageAny 0 2)
    _ -> PassengerCar_169 <$> runMessage msg attrs
