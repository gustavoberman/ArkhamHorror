module Arkham.Location.Cards.OsbornsGeneralStore_207
  ( osbornsGeneralStore_207
  , OsbornsGeneralStore_207(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Location.Cards qualified as Cards (osbornsGeneralStore_207)
import Arkham.Card.CardType
import Arkham.Classes
import Arkham.Cost
import Arkham.Criteria
import Arkham.GameValue
import Arkham.Location.Attrs
import Arkham.Matcher
import Arkham.Message
import Arkham.Target
import Arkham.Trait

newtype OsbornsGeneralStore_207 = OsbornsGeneralStore_207 LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

osbornsGeneralStore_207 :: LocationCard OsbornsGeneralStore_207
osbornsGeneralStore_207 = location
  OsbornsGeneralStore_207
  Cards.osbornsGeneralStore_207
  3
  (PerPlayer 1)
  Circle
  [Moon, Square]

instance HasAbilities OsbornsGeneralStore_207 where
  getAbilities (OsbornsGeneralStore_207 attrs) = do
    let rest = withDrawCardUnderneathAction attrs
    [ restrictedAbility attrs 1 Here $ ActionAbility Nothing $ Costs
            [ActionCost 1, ResourceCost 1]
        | locationRevealed attrs
        ]
      <> rest

instance LocationRunner env => RunMessage env OsbornsGeneralStore_207 where
  runMessage msg l@(OsbornsGeneralStore_207 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> l <$ push
      (Search
        iid
        source
        (InvestigatorTarget iid)
        [fromTopOfDeck 3]
        (CardWithType AssetType <> CardWithTrait Item)
        (DrawFound iid 1)
      )
    _ -> OsbornsGeneralStore_207 <$> runMessage msg attrs