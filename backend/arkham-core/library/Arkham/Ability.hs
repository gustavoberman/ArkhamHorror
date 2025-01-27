module Arkham.Ability (
  module Arkham.Ability,
  module X,
) where

import Arkham.Prelude

import Arkham.Ability.Limit as X
import Arkham.Ability.Type as X
import Arkham.Json
import Arkham.Action (Action)
import Arkham.Card.EncounterCard
import Arkham.Classes.Entity.Source
import Arkham.Cost
import Arkham.Criteria (Criterion(InYourHand, AnyCriterion, Criteria))
import Arkham.Id
import Arkham.Matcher
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Source
import Arkham.Target

data Ability = Ability
  { abilitySource :: Source
  , abilityIndex :: Int
  , abilityType :: AbilityType
  , abilityLimit :: AbilityLimit
  , abilityWindow :: WindowMatcher
  , abilityMetadata :: Maybe AbilityMetadata
  , abilityCriteria :: Maybe Criterion
  , abilityDoesNotProvokeAttacksOfOpportunity :: Bool
  }
  deriving stock (Show, Generic)
  deriving anyclass (Hashable)

inHandAbility :: Ability -> Bool
inHandAbility = maybe False inHandCriteria . abilityCriteria
  where
    inHandCriteria = \case
      InYourHand -> True
      Criteria xs -> any inHandCriteria xs
      AnyCriterion xs -> any inHandCriteria xs
      _ -> False

abilityCost :: Ability -> Cost
abilityCost = abilityTypeCost . abilityType

abilityAction :: Ability -> Maybe Action
abilityAction = abilityTypeAction . abilityType

abilityIs :: Ability -> Action -> Bool
abilityIs a = (== abilityAction a) . Just

abilityIsActionAbility :: Ability -> Bool
abilityIsActionAbility a = case abilityType a of
  ActionAbility {} -> True
  ActionAbilityWithSkill {} -> True
  ActionAbilityWithBefore {} -> True
  _ -> False

abilityLimitL :: Lens' Ability AbilityLimit
abilityLimitL = lens abilityLimit $ \m x -> m {abilityLimit = x}

limitedAbility :: AbilityLimit -> Ability -> Ability
limitedAbility l a = a & abilityLimitL .~ l

abilityMetadataL :: Lens' Ability (Maybe AbilityMetadata)
abilityMetadataL = lens abilityMetadata $ \m x -> m {abilityMetadata = x}

abilityDoesNotProvokeAttacksOfOpportunityL :: Lens' Ability Bool
abilityDoesNotProvokeAttacksOfOpportunityL =
  lens abilityDoesNotProvokeAttacksOfOpportunity $
    \m x -> m {abilityDoesNotProvokeAttacksOfOpportunity = x}

instance Eq Ability where
  a == b =
    (abilitySource a == abilitySource b) && (abilityIndex a == abilityIndex b)

instance ToJSON Ability where
  toJSON = genericToJSON $ aesonOptions $ Just "ability"
  toEncoding = genericToEncoding $ aesonOptions $ Just "ability"

instance FromJSON Ability where
  parseJSON = genericParseJSON $ aesonOptions $ Just "ability"

newtype UsedAbility = UsedAbility {unUsedAbility :: (InvestigatorId, Ability)}

data AbilityMetadata
  = IntMetadata Int
  | TargetMetadata Target
  | SourceMetadata Source
  | EncounterCardMetadata EncounterCard
  | SkillChoiceMetadata SkillType
  | NoAbilityMetadata
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON, Hashable)

restrictedAbility ::
  SourceEntity a => a -> Int -> Criterion -> AbilityType -> Ability
restrictedAbility entity idx restriction type' =
  (mkAbility entity idx type') {abilityCriteria = Just restriction}

reaction :: SourceEntity a => a -> Int -> Criterion -> Cost -> WindowMatcher -> Ability
reaction a n c cost wm = restrictedAbility a n c (ReactionAbility wm cost)

abilityEffect :: SourceEntity a => a -> Cost -> Ability
abilityEffect a cost = mkAbility a (-1) (AbilityEffect cost)

mkAbility :: SourceEntity a => a -> Int -> AbilityType -> Ability
mkAbility entity idx type' =
  Ability
    { abilitySource = toSource entity
    , abilityIndex = idx
    , abilityType = type'
    , abilityLimit = defaultAbilityLimit type'
    , abilityWindow = defaultAbilityWindow type'
    , abilityMetadata = Nothing
    , abilityCriteria = Nothing
    , abilityDoesNotProvokeAttacksOfOpportunity = False
    }

applyAbilityModifiers :: Ability -> [ModifierType] -> Ability
applyAbilityModifiers a@Ability {abilityType} modifiers =
  a {abilityType = applyAbilityTypeModifiers abilityType modifiers}

isSilentForcedAbility :: Ability -> Bool
isSilentForcedAbility Ability {abilityType} = isSilentForcedAbilityType abilityType

isForcedAbility :: Ability -> Bool
isForcedAbility Ability {abilityType} = isForcedAbilityType abilityType

isFastAbility :: Ability -> Bool
isFastAbility Ability {abilityType} = isFastAbilityType abilityType
