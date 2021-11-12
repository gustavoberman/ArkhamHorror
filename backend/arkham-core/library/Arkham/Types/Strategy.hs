module Arkham.Types.Strategy where

import Arkham.Prelude
import Arkham.Types.Card.CardDef
import Arkham.Types.Id
import Arkham.Types.Target
import Arkham.Types.Zone

data DamageStrategy = DamageAny | DamageAssetsFirst | DamageFirst CardDef
    deriving stock (Show, Eq, Generic)
    deriving anyclass (ToJSON, FromJSON)

data ZoneReturnStrategy = PutBackInAnyOrder | ShuffleBackIn | PutBack
    deriving stock (Show, Eq, Generic)
    deriving anyclass (ToJSON, FromJSON)

data FoundCardsStrategy = PlayFound InvestigatorId Int | DrawFound InvestigatorId Int | DeferSearchedToTarget Target | ReturnCards
    deriving stock (Show, Eq, Generic)
    deriving anyclass (ToJSON, FromJSON)

fromTopOfDeck :: Int -> (Zone, ZoneReturnStrategy)
fromTopOfDeck n = (FromTopOfDeck n, ShuffleBackIn)

fromDeck :: (Zone, ZoneReturnStrategy)
fromDeck = (FromDeck, ShuffleBackIn)
