module Arkham.EntityInstance where

import Arkham.Prelude

import Arkham.Asset
import Arkham.Asset.Runner
import Arkham.Card
import Arkham.Card.Id
import Arkham.Classes
import Arkham.Enemy
import Arkham.Enemy.Runner
import Arkham.Event
import Arkham.Event.Runner
import Arkham.Id
import Arkham.Location
import Arkham.Location.Runner
import Arkham.Matcher (AssetMatcher, EnemyMatcher, LocationMatcher)
import Arkham.Message
import Arkham.Query
import Arkham.Skill
import Arkham.Skill.Runner
import Arkham.SkillTest
import Arkham.Trait (Trait)
import Arkham.Treachery
import Arkham.Treachery.Runner

data EntityInstance
  = AssetInstance Asset
  | EventInstance Event
  | LocationInstance Location
  | SkillInstance Skill
  | EnemyInstance Enemy
  | TreacheryInstance Treachery

instance EntityInstanceRunner env => RunMessage env EntityInstance where
  runMessage msg (AssetInstance x) = AssetInstance <$> runMessage msg x
  runMessage msg (EnemyInstance x) = EnemyInstance <$> runMessage msg x
  runMessage msg (EventInstance x) = EventInstance <$> runMessage msg x
  runMessage msg (LocationInstance x) = LocationInstance <$> runMessage msg x
  runMessage msg (SkillInstance x) = SkillInstance <$> runMessage msg x
  runMessage msg (TreacheryInstance x) = TreacheryInstance <$> runMessage msg x

instance HasAbilities EntityInstance where
  getAbilities (AssetInstance x) = getAbilities x
  getAbilities (EnemyInstance x) = getAbilities x
  getAbilities (EventInstance x) = getAbilities x
  getAbilities (LocationInstance x) = getAbilities x
  getAbilities (SkillInstance x) = getAbilities x
  getAbilities (TreacheryInstance x) = getAbilities x

toCardInstance :: InvestigatorId -> Card -> EntityInstance
toCardInstance iid card = case toCardType card of
  AssetType -> AssetInstance $ createAsset card
  EncounterAssetType -> AssetInstance $ createAsset card
  EnemyType -> EnemyInstance $ createEnemy card
  EventType -> EventInstance $ createEvent card iid
  LocationType -> LocationInstance $ createLocation card
  PlayerEnemyType -> EnemyInstance $ createEnemy card
  PlayerTreacheryType -> TreacheryInstance $ createTreachery card iid
  SkillType -> SkillInstance $ createSkill card iid
  TreacheryType -> TreacheryInstance $ createTreachery card iid
  ActType -> error "Unhandled"
  AgendaType -> error "Unhandled"
  StoryType -> error "Unhandled"
  InvestigatorType -> error "Unhandled"

{- | Masking rules
 UseCardAbility: Because some abilities have a discard self cost, the card of the ability will have already been discarded when we go to resolve this. While we could use InDiscard in the RunMessage instance for that card's entity, there may be cases where we can trigger abilities without paying the cost, so we want it to be accessible from both.
-}
doNotMask :: Message -> Bool
doNotMask UseCardAbility {} = True
doNotMask _ = False

type EntityInstanceRunner env =
  ( EnemyRunner env
  , LocationRunner env
  , AssetRunner env
  , TreacheryRunner env
  , LocationRunner env
  , SkillRunner env
  , EventRunner env
  )

type SomeEntityHasModifiersFor env =
  ( HasCount ResourceCount env TreacheryId
  , HasCount HorrorCount env InvestigatorId
  , HasCount Shroud env LocationId
  , HasId (Maybe OwnerId) env AssetId
  , HasCount ClueCount env LocationId
  , Query AssetMatcher env
  , Query EnemyMatcher env
  , HasPhase env
  , HasSkillTest env
  , HasModifiersFor env ()
  , HasName env AssetId
  , HasId CardCode env EnemyId
  , HasStep AgendaStep env ()
  , HasId InvestigatorId env EventId
  , HasId LocationId env InvestigatorId
  , HasSkillValue env InvestigatorId
  , HasId (Maybe LocationId) env AssetId
  , HasSet CommittedCardId env InvestigatorId
  , HasSet InvestigatorId env LocationId
  , HasSet Trait env LocationId
  , HasSet ConnectedLocationId env LocationId
  , HasCount ClueCount env InvestigatorId
  , HasSet LocationId env ()
  , HasCount ClueCount env EnemyId
  , HasCount CardCount env InvestigatorId
  , HasCount RemainingSanity env InvestigatorId
  , HasCount AssetCount env (InvestigatorId, [Trait])
  , HasSet Trait env AssetId
  , HasCount PlayerCount env ()
  , HasCount ResourceCount env InvestigatorId
  , HasId LocationId env AssetId
  , Query LocationMatcher env
  )

instance SomeEntityHasModifiersFor env => HasModifiersFor env EntityInstance where
  getModifiersFor s t = \case
    AssetInstance a -> getModifiersFor s t a
    EnemyInstance e -> getModifiersFor s t e
    EventInstance e -> getModifiersFor s t e
    LocationInstance l -> getModifiersFor s t l
    TreacheryInstance u -> getModifiersFor s t u
    SkillInstance k -> getModifiersFor s t k