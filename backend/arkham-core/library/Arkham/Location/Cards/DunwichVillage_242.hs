module Arkham.Location.Cards.DunwichVillage_242
  ( dunwichVillage_242
  , DunwichVillage_242(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Location.Cards qualified as Cards (dunwichVillage_242)
import Arkham.Classes
import Arkham.Cost
import Arkham.Criteria
import Arkham.Exception
import Arkham.GameValue
import Arkham.Location.Attrs
import Arkham.Matcher
import Arkham.Message
import Arkham.Target
import Arkham.Trait

newtype DunwichVillage_242 = DunwichVillage_242 LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

dunwichVillage_242 :: LocationCard DunwichVillage_242
dunwichVillage_242 = location
  DunwichVillage_242
  Cards.dunwichVillage_242
  3
  (Static 1)
  Circle
  [Triangle, Square, Diamond]

instance HasAbilities DunwichVillage_242 where
  getAbilities (DunwichVillage_242 attrs) = withResignAction
    attrs
    [ restrictedAbility
          attrs
          1
          (Here
          <> InvestigatorExists (You <> InvestigatorWithAnyClues)
          <> EnemyCriteria (EnemyExists $ EnemyWithTrait Abomination)
          )
          (FastAbility Free)
        & (abilityLimitL .~ GroupLimit PerGame 1)
    | locationRevealed attrs
    ]

instance LocationRunner env => RunMessage env DunwichVillage_242 where
  runMessage msg l@(DunwichVillage_242 attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source -> do
      investigatorsWithClues <- locationInvestigatorsWithClues attrs
      abominations <- locationEnemiesWithTrait attrs Abomination
      when
        (null investigatorsWithClues || null abominations)
        (throwIO $ InvalidState "should not have been able to use this ability")
      l <$ pushAll
        [ chooseOne
            iid
            [ Label
              "Place clue on Abomination"
              [ chooseOne
                  iid
                  [ TargetLabel
                      (EnemyTarget eid)
                      [ PlaceClues (EnemyTarget eid) 1
                      , InvestigatorSpendClues iid 1
                      ]
                  | eid <- abominations
                  ]
              ]
            , Label "Do not place clue on Abomination" []
            ]
        | iid <- investigatorsWithClues
        ]
    _ -> DunwichVillage_242 <$> runMessage msg attrs