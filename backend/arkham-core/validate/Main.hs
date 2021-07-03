module Main where

import ClassyPrelude

import Arkham.Asset.Cards
import Arkham.Types.Card.CardCode
import Arkham.Types.Card.CardDef
import Arkham.Types.Card.Cost
import Arkham.Types.ClassSymbol
import Arkham.Types.EncounterSet
import Arkham.Types.Name
import Control.Exception
import Data.Aeson
import Data.Maybe (fromJust)

data CardJson = CardJson
  { code :: CardCode
  , name :: Text
  , subname :: Maybe Text
  , cost :: Maybe Int
  , exceptional :: Bool
  , is_unique :: Bool
  , traits :: Maybe Text
  , skill_agility :: Maybe Int
  , skill_combat :: Maybe Int
  , skill_intellect :: Maybe Int
  , skill_willpower :: Maybe Int
  , skill_wild :: Maybe Int
  , faction_name :: String
  }
  deriving stock (Show, Generic)
  deriving anyclass FromJSON

data InternalCardCodeMismatch = InternalCardCodeMismatch CardCode CardCode
  deriving stock Show

newtype UnknownCard = UnknownCard CardCode
  deriving stock Show

data NameMismatch = NameMismatch CardCode Name Name
  deriving stock Show

data UniqueMismatch = UniqueMismatch CardCode Name
  deriving stock Show

data CardCostMismatch = CostMismatch
  CardCode
  Name
  (Maybe Int)
  (Maybe CardCost)
  deriving stock Show

data ClassMismatch = ClassMismatch CardCode Name String (Maybe ClassSymbol)
  deriving stock Show

instance Exception InternalCardCodeMismatch
instance Exception UnknownCard
instance Exception NameMismatch
instance Exception UniqueMismatch
instance Exception CardCostMismatch
instance Exception ClassMismatch

encounterJson :: IO (HashMap EncounterSet (HashMap CardCode CardJson))
encounterJson = mapFromList
  <$> for [minBound .. maxBound] (\set -> (set, ) <$> encounterMap set)

encounterMap :: EncounterSet -> IO (HashMap CardCode CardJson)
encounterMap set = do
  eresult <- eitherDecodeFileStrict @[CardJson] (toCardFile set)
  case eresult of
    Left err -> error err
    Right cards -> pure . mapFromList $ map (code &&& id) cards

toCardFile :: EncounterSet -> FilePath
toCardFile set = "data" </> "packs" </> toDir set </> "cards.json"
 where
  toDir = \case
    TheGathering -> "core"
    TheMidnightMasks -> "core"
    TheDevourerBelow -> "core"
    CultOfUmordhoth -> "core"
    Rats -> "core"
    Ghouls -> "core"
    StrikingFear -> "core"
    AncientEvils -> "core"
    ChillingCold -> "core"
    Nightgaunts -> "core"
    DarkCult -> "core"
    LockedDoors -> "core"
    AgentsOfHastur -> "core"
    AgentsOfYogSothoth -> "core"
    AgentsOfShubNiggurath -> "core"
    AgentsOfCthulhu -> "core"
    ExtracurricularActivity -> "dwl"
    TheHouseAlwaysWins -> "dwl"
    ArmitagesFate -> "dwl"
    TheMiskatonicMuseum -> "tmm"
    TheEssexCountyExpress -> "tece"
    BloodOnTheAltar -> "bota"
    UndimensionedAndUnseen -> "uau"
    WhereDoomAwaits -> "wda"
    LostInTimeAndSpace -> "litas"
    Sorcery -> "dwl"
    BishopsThralls -> "dwl"
    Dunwich -> "dwl"
    Whippoorwills -> "dwl"
    BadLuck -> "dwl"
    BeastThralls -> "dwl"
    NaomisCrew -> "dwl"
    TheBeyond -> "dwl"
    HideousAbominations -> "dwl"
    ReturnToTheGathering -> "rtnotz"
    ReturnToTheMidnightMasks -> "rtnotz"
    ReturnToTheDevourerBelow -> "rtnotz"
    GhoulsOfUmordhoth -> "rtnotz"
    TheDevourersCult -> "rtnotz"
    ReturnCultOfUmordhoth -> "rtnotz"
    TheBayou -> "cotr"
    CurseOfTheRougarou -> "cotr"
    Test -> "test"

filterTest :: [(CardCode, CardDef)] -> [(CardCode, CardDef)]
filterTest =
  filter (\(code, cdef) -> code /= "asset" && cdEncounterSet cdef /= Just Test)

toClassSymbol :: String -> Maybe ClassSymbol
toClassSymbol = \case
  "Guardian" -> Just Guardian
  "Seeker" -> Just Seeker
  "Survivor" -> Just Survivor
  "Rogue" -> Just Rogue
  "Mystic" -> Just Mystic
  "Neutral" -> Just Neutral
  _ -> Nothing

normalizeName :: Text -> Text
normalizeName "Powder of Ibn Ghazi" = "Powder of Ibn-Ghazi"
normalizeName a = a

normalizeCost :: Maybe Int -> Maybe CardCost
normalizeCost (Just (-2)) = Just DynamicCost
normalizeCost (Just n) = Just (StaticCost n)
normalizeCost Nothing = Nothing

main :: IO ()
main = do
  ecards <- eitherDecodeFileStrict @[CardJson] ("data" </> "cards.json")
  case ecards of
    Left err -> error err
    Right cards -> do
      let
        jsonMap :: HashMap CardCode CardJson =
          mapFromList $ map (code &&& id) cards
      encounterMaps <- encounterJson
      for_ (filterTest $ mapToList allPlayerAssetCards) $ \(ccode, card) -> do
        when
          (ccode /= cdCardCode card)
          (throw $ InternalCardCodeMismatch ccode (cdCardCode card))
        let
          lookupMap = maybe
            jsonMap
            (fromJust . (`lookup` encounterMaps))
            (cdEncounterSet card)
        case lookup ccode lookupMap of
          Nothing -> throw $ UnknownCard (cdCardCode card)
          Just CardJson {..} -> do
            when
              (Name (normalizeName name) subname /= cdName card)
              (throw $ NameMismatch code (Name name subname) (cdName card))
            when
              (is_unique /= cdUnique card)
              (throw $ UniqueMismatch code (cdName card))
            when
              (normalizeCost cost /= cdCost card)
              (throw $ CostMismatch code (cdName card) cost (cdCost card))
            when
              (toClassSymbol faction_name /= cdClassSymbol card)
              (throw $ ClassMismatch
                code
                (cdName card)
                faction_name
                (cdClassSymbol card)
              )
