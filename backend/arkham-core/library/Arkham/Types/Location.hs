module Arkham.Types.Location
  ( module Arkham.Types.Location
  )
where

import Arkham.Prelude

import Arkham.Types.Modifier
import qualified Arkham.Types.EncounterSet as EncounterSet
import Arkham.Types.AssetId
import Arkham.Types.Direction
import Arkham.Types.GameValue
import Arkham.Types.LocationSymbol
import Arkham.Types.Classes
import Arkham.Types.Card.CardCode
import Arkham.Types.EnemyId
import Arkham.Types.EventId
import Arkham.Types.Helpers
import Arkham.Types.InvestigatorId
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Cards
import Arkham.Types.Message
import Arkham.Types.Name
import Arkham.Types.Location.Runner
import Arkham.Types.LocationId
import Arkham.Types.Query
import Arkham.Types.TreacheryId

data Location
  = Study' Study
  | Hallway' Hallway
  | Attic' Attic
  | Cellar' Cellar
  | Parlor' Parlor
  | YourHouse' YourHouse
  | Rivertown' Rivertown
  | SouthsideHistoricalSociety' SouthsideHistoricalSociety
  | SouthsideMasBoardingHouse' SouthsideMasBoardingHouse
  | StMarysHospital' StMarysHospital
  | MiskatonicUniversity' MiskatonicUniversity
  | DowntownFirstBankOfArkham' DowntownFirstBankOfArkham
  | DowntownArkhamAsylum' DowntownArkhamAsylum
  | Easttown' Easttown
  | Graveyard' Graveyard
  | Northside' Northside
  | MainPath' MainPath
  | ArkhamWoodsUnhallowedGround' ArkhamWoodsUnhallowedGround
  | ArkhamWoodsTwistingPaths' ArkhamWoodsTwistingPaths
  | ArkhamWoodsOldHouse' ArkhamWoodsOldHouse
  | ArkhamWoodsCliffside' ArkhamWoodsCliffside
  | ArkhamWoodsTangledThicket' ArkhamWoodsTangledThicket
  | ArkhamWoodsQuietGlade' ArkhamWoodsQuietGlade
  | MiskatonicQuad' MiskatonicQuad
  | HumanitiesBuilding' HumanitiesBuilding
  | OrneLibrary' OrneLibrary
  | StudentUnion' StudentUnion
  | Dormitories' Dormitories
  | AdministrationBuilding' AdministrationBuilding
  | FacultyOfficesTheNightIsStillYoung' FacultyOfficesTheNightIsStillYoung
  | FacultyOfficesTheHourIsLate' FacultyOfficesTheHourIsLate
  | ScienceBuilding' ScienceBuilding
  | AlchemyLabs' AlchemyLabs
  | LaBellaLuna' LaBellaLuna
  | CloverClubLounge' CloverClubLounge
  | CloverClubBar' CloverClubBar
  | CloverClubCardroom' CloverClubCardroom
  | DarkenedHall' DarkenedHall
  | ArtGallery' ArtGallery
  | VipArea' VipArea
  | BackAlley' BackAlley
  | MuseumEntrance' MuseumEntrance
  | MuseumHalls' MuseumHalls
  | SecurityOffice_128' SecurityOffice_128
  | SecurityOffice_129' SecurityOffice_129
  | AdministrationOffice_130' AdministrationOffice_130
  | AdministrationOffice_131' AdministrationOffice_131
  | ExhibitHallAthabaskanExhibit' ExhibitHallAthabaskanExhibit
  | ExhibitHallMedusaExhibit' ExhibitHallMedusaExhibit
  | ExhibitHallNatureExhibit' ExhibitHallNatureExhibit
  | ExhibitHallEgyptianExhibit' ExhibitHallEgyptianExhibit
  | ExhibitHallHallOfTheDead' ExhibitHallHallOfTheDead
  | ExhibitHallRestrictedHall' ExhibitHallRestrictedHall
  | PassengerCar_167' PassengerCar_167
  | PassengerCar_168' PassengerCar_168
  | PassengerCar_169' PassengerCar_169
  | PassengerCar_170' PassengerCar_170
  | PassengerCar_171' PassengerCar_171
  | SleepingCar' SleepingCar
  | DiningCar' DiningCar
  | ParlorCar' ParlorCar
  | EngineCar_175' EngineCar_175
  | EngineCar_176' EngineCar_176
  | EngineCar_177' EngineCar_177
  | StudyAberrantGateway' StudyAberrantGateway
  | GuestHall' GuestHall
  | Bedroom' Bedroom
  | Bathroom' Bathroom
  | HoleInTheWall' HoleInTheWall
  | ReturnToAttic' ReturnToAttic
  | FarAboveYourHouse' FarAboveYourHouse
  | ReturnToCellar' ReturnToCellar
  | DeepBelowYourHouse' DeepBelowYourHouse
  | EasttownArkhamPoliceStation' EasttownArkhamPoliceStation
  | NorthsideTrainStation' NorthsideTrainStation
  | MiskatonicUniversityMiskatonicMuseum' MiskatonicUniversityMiskatonicMuseum
  | RivertownAbandonedWarehouse' RivertownAbandonedWarehouse
  | ArkhamWoodsGreatWillow' ArkhamWoodsGreatWillow
  | ArkhamWoodsLakeside' ArkhamWoodsLakeside
  | ArkhamWoodsCorpseRiddenClearing' ArkhamWoodsCorpseRiddenClearing
  | ArkhamWoodsWoodenBridge' ArkhamWoodsWoodenBridge
  | RitualSite' RitualSite
  | CursedShores' CursedShores
  | GardenDistrict' GardenDistrict
  | Broadmoor' Broadmoor
  | BrackishWaters' BrackishWaters
  | AudubonPark' AudubonPark
  | FauborgMarigny' FauborgMarigny
  | ForgottenMarsh' ForgottenMarsh
  | TrappersCabin' TrappersCabin
  | TwistedUnderbrush' TwistedUnderbrush
  | FoulSwamp' FoulSwamp
  | RitualGrounds' RitualGrounds
  | OvergrownCairns' OvergrownCairns
  | BaseLocation' BaseLocation
  deriving stock (Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

deriving anyclass instance ActionRunner env => HasActions env Location
deriving anyclass instance
  ( HasPhase env
  , HasCount CardCount env InvestigatorId
  , HasCount ClueCount env LocationId
  , HasCount ResourceCount env InvestigatorId
  , HasId (Maybe StoryEnemyId) env CardCode
  )
  => HasModifiersFor env Location

isBlanked :: Message -> Bool
isBlanked Blanked{} = True
isBlanked _ = False

instance LocationRunner env => RunMessage env Location where
  runMessage msg l = do
    modifiers' <- getModifiersFor (toSource l) (toTarget l) ()
    if any isBlank modifiers' && not (isBlanked msg)
      then runMessage (Blanked msg) l
      else defaultRunMessage msg l

instance Entity Location where
  type EntityId Location = LocationId
  toId = toId . locationAttrs
  toTarget = toTarget . locationAttrs
  isTarget = isTarget . locationAttrs
  toSource = toSource . locationAttrs
  isSource = isSource . locationAttrs

newtype BaseLocation = BaseLocation Attrs
  deriving newtype (Show, ToJSON, FromJSON)

instance HasModifiersFor env BaseLocation where
  getModifiersFor = noModifiersFor

instance HasName env Location where
  getName = getName . locationAttrs

instance ActionRunner env => HasActions env BaseLocation where
  getActions iid window (BaseLocation attrs) = getActions iid window attrs

instance LocationRunner env => RunMessage env BaseLocation where
  runMessage msg (BaseLocation attrs) = BaseLocation <$> runMessage msg attrs

baseLocation
  :: LocationId
  -> Name
  -> Int
  -> GameValue Int
  -> LocationSymbol
  -> [LocationSymbol]
  -> (Attrs -> Attrs)
  -> Location
baseLocation a b c d e f func = BaseLocation' . BaseLocation . func $ baseAttrs
  a
  b
  EncounterSet.TheGathering
  c
  d
  e
  f
  []

instance IsCard Location where
  getCardId = getCardId . locationAttrs
  getCardCode = getCardCode . locationAttrs
  getTraits = getTraits . locationAttrs
  getKeywords = getKeywords . locationAttrs

instance HasVictoryPoints Location where
  getVictoryPoints l =
    let Attrs { locationClues, locationVictory } = locationAttrs l
    in if locationClues == 0 then locationVictory else Nothing

instance HasCount ClueCount env Location where
  getCount = pure . ClueCount . locationClues . locationAttrs

instance HasCount Shroud env Location where
  getCount = pure . Shroud . locationShroud . locationAttrs

instance HasCount DoomCount env Location where
  getCount = pure . DoomCount . locationDoom . locationAttrs

instance HasSet EnemyId env Location where
  getSet = pure . locationEnemies . locationAttrs

instance HasSet TreacheryId env Location where
  getSet = pure . locationTreacheries . locationAttrs

instance HasSet EventId env Location where
  getSet = pure . locationEvents . locationAttrs

instance HasSet AssetId env Location where
  getSet = pure . locationAssets . locationAttrs

instance HasSet InvestigatorId env Location where
  getSet = pure . locationInvestigators . locationAttrs

instance HasSet ConnectedLocationId env Location where
  getSet =
    pure
      . mapSet ConnectedLocationId
      . locationConnectedLocations
      . locationAttrs

instance HasId LocationId env Location where
  getId = pure . getLocationId

instance HasId (Maybe LocationId) env (Direction, Location) where
  getId (dir, location) = getId (dir, locationAttrs location)

getLocationId :: Location -> LocationId
getLocationId = locationId . locationAttrs

getLocationName :: Location -> LocationName
getLocationName = locationName . locationAttrs

lookupLocation :: LocationId -> Location
lookupLocation lid =
  fromJustNote ("Unknown location: " <> show lid) $ lookup lid allLocations

allLocations :: HashMap LocationId Location
allLocations = mapFromList $ map
  (toFst $ locationId . locationAttrs)
  [ Study' study
  , Hallway' hallway
  , Attic' attic
  , Cellar' cellar
  , Parlor' parlor
  , YourHouse' yourHouse
  , Rivertown' rivertown
  , SouthsideHistoricalSociety' southsideHistoricalSociety
  , SouthsideMasBoardingHouse' southsideMasBoardingHouse
  , StMarysHospital' stMarysHospital
  , MiskatonicUniversity' miskatonicUniversity
  , DowntownFirstBankOfArkham' downtownFirstBankOfArkham
  , DowntownArkhamAsylum' downtownArkhamAsylum
  , Easttown' easttown
  , Graveyard' graveyard
  , Northside' northside
  , MainPath' mainPath
  , ArkhamWoodsUnhallowedGround' arkhamWoodsUnhallowedGround
  , ArkhamWoodsTwistingPaths' arkhamWoodsTwistingPaths
  , ArkhamWoodsOldHouse' arkhamWoodsOldHouse
  , ArkhamWoodsCliffside' arkhamWoodsCliffside
  , ArkhamWoodsTangledThicket' arkhamWoodsTangledThicket
  , ArkhamWoodsQuietGlade' arkhamWoodsQuietGlade
  , MiskatonicQuad' miskatonicQuad
  , HumanitiesBuilding' humanitiesBuilding
  , OrneLibrary' orneLibrary
  , StudentUnion' studentUnion
  , Dormitories' dormitories
  , AdministrationBuilding' administrationBuilding
  , FacultyOfficesTheNightIsStillYoung' facultyOfficesTheNightIsStillYoung
  , FacultyOfficesTheHourIsLate' facultyOfficesTheHourIsLate
  , ScienceBuilding' scienceBuilding
  , AlchemyLabs' alchemyLabs
  , LaBellaLuna' laBellaLuna
  , CloverClubLounge' cloverClubLounge
  , CloverClubBar' cloverClubBar
  , CloverClubCardroom' cloverClubCardroom
  , DarkenedHall' darkenedHall
  , ArtGallery' artGallery
  , VipArea' vipArea
  , BackAlley' backAlley
  , MuseumEntrance' museumEntrance
  , MuseumHalls' museumHalls
  , SecurityOffice_128' securityOffice_128
  , SecurityOffice_129' securityOffice_129
  , AdministrationOffice_130' administrationOffice_130
  , AdministrationOffice_131' administrationOffice_131
  , ExhibitHallAthabaskanExhibit' exhibitHallAthabaskanExhibit
  , ExhibitHallMedusaExhibit' exhibitHallMedusaExhibit
  , ExhibitHallNatureExhibit' exhibitHallNatureExhibit
  , ExhibitHallEgyptianExhibit' exhibitHallEgyptianExhibit
  , ExhibitHallHallOfTheDead' exhibitHallHallOfTheDead
  , ExhibitHallRestrictedHall' exhibitHallRestrictedHall
  , PassengerCar_167' passengerCar_167
  , PassengerCar_168' passengerCar_168
  , PassengerCar_169' passengerCar_169
  , PassengerCar_170' passengerCar_170
  , PassengerCar_171' passengerCar_171
  , SleepingCar' sleepingCar
  , DiningCar' diningCar
  , ParlorCar' parlorCar
  , EngineCar_175' engineCar_175
  , EngineCar_176' engineCar_176
  , EngineCar_177' engineCar_177
  , StudyAberrantGateway' studyAberrantGateway
  , GuestHall' guestHall
  , Bedroom' bedroom
  , Bathroom' bathroom
  , HoleInTheWall' holeInTheWall
  , ReturnToAttic' returnToAttic
  , FarAboveYourHouse' farAboveYourHouse
  , ReturnToCellar' returnToCellar
  , DeepBelowYourHouse' deepBelowYourHouse
  , EasttownArkhamPoliceStation' easttownArkhamPoliceStation
  , NorthsideTrainStation' northsideTrainStation
  , MiskatonicUniversityMiskatonicMuseum' miskatonicUniversityMiskatonicMuseum
  , RivertownAbandonedWarehouse' rivertownAbandonedWarehouse
  , ArkhamWoodsGreatWillow' arkhamWoodsGreatWillow
  , ArkhamWoodsLakeside' arkhamWoodsLakeside
  , ArkhamWoodsCorpseRiddenClearing' arkhamWoodsCorpseRiddenClearing
  , ArkhamWoodsWoodenBridge' arkhamWoodsWoodenBridge
  , RitualSite' ritualSite
  , CursedShores' cursedShores
  , GardenDistrict' gardenDistrict
  , Broadmoor' broadmoor
  , BrackishWaters' brackishWaters
  , AudubonPark' audubonPark
  , FauborgMarigny' fauborgMarigny
  , ForgottenMarsh' forgottenMarsh
  , TrappersCabin' trappersCabin
  , TwistedUnderbrush' twistedUnderbrush
  , FoulSwamp' foulSwamp
  , RitualGrounds' ritualGrounds
  , OvergrownCairns' overgrownCairns
  ]

isEmptyLocation :: Location -> Bool
isEmptyLocation l = null enemies' && null investigators'
 where
  enemies' = locationEnemies $ locationAttrs l
  investigators' = locationInvestigators $ locationAttrs l

isRevealed :: Location -> Bool
isRevealed = locationRevealed . locationAttrs

locationAttrs :: Location -> Attrs
locationAttrs = \case
  Study' attrs -> coerce attrs
  Hallway' attrs -> coerce attrs
  Attic' attrs -> coerce attrs
  Cellar' attrs -> coerce attrs
  Parlor' attrs -> coerce attrs
  YourHouse' attrs -> coerce attrs
  Rivertown' attrs -> coerce attrs
  SouthsideHistoricalSociety' attrs -> coerce attrs
  SouthsideMasBoardingHouse' attrs -> coerce attrs
  StMarysHospital' attrs -> coerce attrs
  MiskatonicUniversity' attrs -> coerce attrs
  DowntownFirstBankOfArkham' attrs -> coerce attrs
  DowntownArkhamAsylum' attrs -> coerce attrs
  Easttown' attrs -> coerce attrs
  Graveyard' attrs -> coerce attrs
  Northside' attrs -> coerce attrs
  MainPath' attrs -> coerce attrs
  ArkhamWoodsUnhallowedGround' attrs -> coerce attrs
  ArkhamWoodsTwistingPaths' attrs -> coerce attrs
  ArkhamWoodsOldHouse' attrs -> coerce attrs
  ArkhamWoodsCliffside' attrs -> coerce attrs
  ArkhamWoodsTangledThicket' attrs -> coerce attrs
  ArkhamWoodsQuietGlade' attrs -> coerce attrs
  MiskatonicQuad' attrs -> coerce attrs
  HumanitiesBuilding' attrs -> coerce attrs
  OrneLibrary' attrs -> coerce attrs
  StudentUnion' attrs -> coerce attrs
  Dormitories' attrs -> coerce attrs
  AdministrationBuilding' attrs -> coerce attrs
  FacultyOfficesTheNightIsStillYoung' attrs -> coerce attrs
  FacultyOfficesTheHourIsLate' attrs -> coerce attrs
  ScienceBuilding' attrs -> coerce attrs
  AlchemyLabs' attrs -> coerce attrs
  LaBellaLuna' attrs -> coerce attrs
  CloverClubLounge' attrs -> coerce attrs
  CloverClubBar' attrs -> coerce attrs
  CloverClubCardroom' attrs -> coerce attrs
  DarkenedHall' attrs -> coerce attrs
  ArtGallery' attrs -> coerce attrs
  VipArea' attrs -> coerce attrs
  BackAlley' attrs -> coerce attrs
  MuseumEntrance' attrs -> coerce attrs
  MuseumHalls' attrs -> coerce attrs
  SecurityOffice_128' attrs -> coerce attrs
  SecurityOffice_129' attrs -> coerce attrs
  AdministrationOffice_130' attrs -> coerce attrs
  AdministrationOffice_131' attrs -> coerce attrs
  ExhibitHallAthabaskanExhibit' attrs -> coerce attrs
  ExhibitHallMedusaExhibit' attrs -> coerce attrs
  ExhibitHallNatureExhibit' attrs -> coerce attrs
  ExhibitHallEgyptianExhibit' attrs -> coerce attrs
  ExhibitHallHallOfTheDead' attrs -> coerce attrs
  ExhibitHallRestrictedHall' attrs -> coerce attrs
  PassengerCar_167' attrs -> coerce attrs
  PassengerCar_168' attrs -> coerce attrs
  PassengerCar_169' attrs -> coerce attrs
  PassengerCar_170' attrs -> coerce attrs
  PassengerCar_171' attrs -> coerce attrs
  SleepingCar' attrs -> coerce attrs
  DiningCar' attrs -> coerce attrs
  ParlorCar' attrs -> coerce attrs
  EngineCar_175' attrs -> coerce attrs
  EngineCar_176' attrs -> coerce attrs
  EngineCar_177' attrs -> coerce attrs
  StudyAberrantGateway' attrs -> coerce attrs
  GuestHall' attrs -> coerce attrs
  Bedroom' attrs -> coerce attrs
  Bathroom' attrs -> coerce attrs
  HoleInTheWall' attrs -> coerce attrs
  ReturnToAttic' attrs -> coerce attrs
  FarAboveYourHouse' attrs -> coerce attrs
  ReturnToCellar' attrs -> coerce attrs
  DeepBelowYourHouse' attrs -> coerce attrs
  EasttownArkhamPoliceStation' attrs -> coerce attrs
  NorthsideTrainStation' attrs -> coerce attrs
  MiskatonicUniversityMiskatonicMuseum' attrs -> coerce attrs
  RivertownAbandonedWarehouse' attrs -> coerce attrs
  ArkhamWoodsGreatWillow' attrs -> coerce attrs
  ArkhamWoodsLakeside' attrs -> coerce attrs
  ArkhamWoodsCorpseRiddenClearing' attrs -> coerce attrs
  ArkhamWoodsWoodenBridge' attrs -> coerce attrs
  RitualSite' attrs -> coerce attrs
  CursedShores' attrs -> coerce attrs
  GardenDistrict' attrs -> coerce attrs
  Broadmoor' attrs -> coerce attrs
  BrackishWaters' attrs -> coerce attrs
  AudubonPark' attrs -> coerce attrs
  FauborgMarigny' attrs -> coerce attrs
  ForgottenMarsh' attrs -> coerce attrs
  TrappersCabin' attrs -> coerce attrs
  TwistedUnderbrush' attrs -> coerce attrs
  FoulSwamp' attrs -> coerce attrs
  RitualGrounds' attrs -> coerce attrs
  OvergrownCairns' attrs -> coerce attrs
  BaseLocation' attrs -> coerce attrs
