{-# LANGUAGE TemplateHaskell #-}
module Arkham.Location
  ( module Arkham.Location
  ) where

import Arkham.Prelude

import Arkham.Card
import Arkham.Card.Id
import Arkham.Classes
import Arkham.Direction
import Arkham.Id
import Arkham.Label qualified as L
import Arkham.Location.Locations
import Arkham.Location.Runner
import Arkham.Matcher
import Arkham.Message
import Arkham.Modifier
import Arkham.Name
import Arkham.Query
import Arkham.SkillTest
import Arkham.Trait (Trait)
import Data.HashSet qualified as HashSet
import Data.UUID (nil)
import Data.Aeson.TH

$(buildEntity "Location")

$(deriveJSON defaultOptions ''Location)

createLocation :: IsCard a => a -> Location
createLocation a = lookupLocation (toCardCode a) (LocationId $ toCardId a)

toLocationSymbol :: Location -> LocationSymbol
toLocationSymbol = locationSymbol . toAttrs

toLocationLabel :: Location -> L.Label
toLocationLabel = L.Label . locationLabel . toAttrs

instance HasCardCode Location where
  toCardCode = toCardCode . toAttrs

instance IsCard Location where
  toCardId = toCardId . toAttrs
  toCardOwner = toCardOwner . toAttrs

instance HasAbilities Location where
  getAbilities = $(entityF "Location" "getAbilities")

instance
  ( HasPhase env
  , HasSkillTest env
  , HasCount CardCount env InvestigatorId
  , HasCount ClueCount env LocationId
  , HasCount ResourceCount env InvestigatorId
  , HasCount HorrorCount env InvestigatorId
  , Query AssetMatcher env
  , Query EnemyMatcher env
  )
  => HasModifiersFor env Location where
  getModifiersFor = $(entityF2 "Location" "getModifiersFor")

instance LocationRunner env => RunMessage env Location where
  runMessage msg l = do
    modifiers' <- getModifiers (toSource l) (toTarget l)
    let msg' = if Blank `elem` modifiers' then Blanked msg else msg
    $(entityRunMessage "Location") msg' l

instance Entity Location where
  type EntityId Location = LocationId
  type EntityAttrs Location = LocationAttrs
  toId = toId . toAttrs
  toAttrs = $(entityF "Location" "toAttrs")

instance Named Location where
  toName = toName . toAttrs

instance Named (Unrevealed Location) where
  toName (Unrevealed l) = toName . Unrevealed $ toAttrs l

instance TargetEntity Location where
  toTarget = toTarget . toAttrs
  isTarget = isTarget . toAttrs

instance SourceEntity Location where
  toSource = toSource . toAttrs
  isSource = isSource . toAttrs

instance HasCardDef Location where
  toCardDef = toCardDef . toAttrs

instance HasName env Location where
  getName = getName . toAttrs

instance HasName env (Unrevealed Location) where
  getName (Unrevealed l) = getName . Unrevealed $ toAttrs l

instance HasVictoryPoints Location where
  getVictoryPoints l =
    let LocationAttrs { locationClues, locationRevealed } = toAttrs l
    in
      if locationClues == 0 && locationRevealed
        then cdVictoryPoints (toCardDef l)
        else Nothing

instance HasCount ResourceCount env Location where
  getCount = pure . ResourceCount . locationResources . toAttrs

instance HasCount HorrorCount env Location where
  getCount = pure . HorrorCount . locationHorror . toAttrs

instance HasCount ClueCount env Location where
  getCount = pure . ClueCount . locationClues . toAttrs

instance HasCount Shroud env Location where
  getCount = pure . Shroud . locationShroud . toAttrs

instance HasModifiersFor env () => HasCount DoomCount env Location where
  getCount l = do
    modifiers <- getModifiers (toSource l) (toTarget l)
    let f = if DoomSubtracts `elem` modifiers then negate else id
    pure . DoomCount . f . locationDoom $ toAttrs l

instance HasList UnderneathCard env Location where
  getList = getList . toAttrs

instance HasModifiersFor env () => HasSet Trait env Location where
  getSet l = do
    additionalTraits <- foldl' applyModifier mempty
      <$> getModifiers (toSource attrs) (toTarget attrs)
    pure $ HashSet.union base (setFromList additionalTraits)
   where
    applyModifier base' (AddTrait t) = t : base'
    applyModifier base' _ = base'
    def = toCardDef l
    attrs = toAttrs l
    base = if locationRevealed attrs
      then cdRevealedCardTraits def
      else cdCardTraits def


instance HasSet EnemyId env Location where
  getSet = pure . locationEnemies . toAttrs

instance HasSet TreacheryId env Location where
  getSet = pure . locationTreacheries . toAttrs

instance HasSet EventId env Location where
  getSet = pure . locationEvents . toAttrs

instance HasSet AssetId env Location where
  getSet = pure . locationAssets . toAttrs

instance HasSet InvestigatorId env Location where
  getSet = pure . locationInvestigators . toAttrs

instance HasId LocationId env Location where
  getId = pure . toId

instance HasId LocationSymbol env Location where
  getId = getId . toAttrs

instance HasId (Maybe LocationId) env (Direction, Location) where
  getId (dir, location') = getId (dir, toAttrs location')

lookupLocationStub :: CardCode -> Location
lookupLocationStub = ($ LocationId (CardId nil)) . lookupLocation

lookupLocation :: CardCode -> (LocationId -> Location)
lookupLocation lid =
  fromJustNote ("Unknown location: " <> show lid) $ lookup lid allLocations

allLocations :: HashMap CardCode (LocationId -> Location)
allLocations =
  mapFromList
    $ map
        (cbCardCode &&& cbCardBuilder)
        $(buildEntityLookupList "Location")

isEmptyLocation :: Location -> Bool
isEmptyLocation =
  and . sequence [noInvestigatorsAtLocation, noEnemiesAtLocation]

noInvestigatorsAtLocation :: Location -> Bool
noInvestigatorsAtLocation l = null investigators'
  where investigators' = locationInvestigators $ toAttrs l

noEnemiesAtLocation :: Location -> Bool
noEnemiesAtLocation l = null enemies'
  where enemies' = locationEnemies $ toAttrs l

getConnectedMatcher
  :: (HasModifiersFor env (), MonadReader env m, Query LocationMatcher env)
  => Location
  -> m LocationMatcher
getConnectedMatcher l = do
  modifiers <- getModifiers (toSource attrs) (toTarget attrs)
  LocationMatchAny <$> foldM applyModifier base modifiers
 where
  applyModifier current (ConnectedToWhen whenMatcher matcher) = do
    matches <- member (toId l) <$> select whenMatcher
    pure $ current <> [ matcher | matches ]
  applyModifier current _ = pure current
  attrs = toAttrs l
  self = LocationWithId $ toId attrs
  base = if isRevealed l
    then locationRevealedConnectedMatchers attrs <> directionalMatchers
    else locationConnectedMatchers attrs <> directionalMatchers
  directionalMatchers =
    map (`LocationInDirection` self) (setToList $ locationConnectsTo attrs)

isRevealed :: Location -> Bool
isRevealed = locationRevealed . toAttrs
