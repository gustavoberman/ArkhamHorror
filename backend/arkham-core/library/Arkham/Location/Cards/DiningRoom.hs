module Arkham.Location.Cards.DiningRoom
  ( diningRoom
  , DiningRoom(..)
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
import Arkham.Matcher
import Arkham.Message
import Arkham.RequestedTokenStrategy
import Arkham.Target
import Arkham.Token

newtype DiningRoom = DiningRoom LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

diningRoom :: LocationCard DiningRoom
diningRoom =
  location DiningRoom Cards.diningRoom 2 (Static 0) Squiggle [Square, Circle]

instance HasAbilities DiningRoom where
  getAbilities (DiningRoom attrs) = withBaseAbilities
    attrs
    [ restrictedAbility
        attrs
        1
        (Here <> InvestigatorExists (You <> InvestigatorWithAnyHorror))
      $ ActionAbility Nothing
      $ ActionCost 1
    | locationRevealed attrs
    ]

instance LocationRunner env => RunMessage env DiningRoom where
  runMessage msg l@(DiningRoom attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> l <$ pushAll
      [ HealHorror (InvestigatorTarget iid) 1
      , RequestTokens source (Just iid) 1 SetAside
      ]
    RequestedTokens source (Just iid) tokens | isSource attrs source -> do
      tokenFaces <- getModifiedTokenFaces source tokens
      let
        msgs = concatMap
          (\case
            tokenFace | tokenFace `elem` [Skull, AutoFail] ->
              [ InvestigatorAssignDamage iid source DamageAny 0 1
              , PlaceDoom (toTarget attrs) 1
              ]
            _ -> []
          )
          tokenFaces
      l <$ pushAll msgs
    _ -> DiningRoom <$> runMessage msg attrs
