module Arkham.Window where

import Arkham.Prelude

import Arkham.Action (Action)
import Arkham.Agenda.AdvancementReason (AgendaAdvancementReason)
import Arkham.SkillTest.Base
import Arkham.SkillType (SkillType)
import Arkham.Card (Card)
import Arkham.DamageEffect (DamageEffect)
import Arkham.Deck
import Arkham.Id
import Arkham.Matcher (LocationMatcher)
import Arkham.Phase (Phase)
import Arkham.Source (Source)
import Arkham.Target (Target)
import Arkham.Timing (Timing)
import Arkham.Token (Token)

data Window = Window
  { windowTiming :: Timing
  , windowType :: WindowType
  }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (ToJSON, FromJSON, Hashable)

data WindowType
  = ActAdvance ActId
  | AgendaAdvance AgendaId
  | AgendaWouldAdvance AgendaAdvancementReason AgendaId
  | AllUndefeatedInvestigatorsResigned
  | AllDrawEncounterCard
  | AmongSearchedCards InvestigatorId
  | AnyPhaseBegins
  | AtEndOfRound
  | EndOfGame
  | ChosenRandomLocation LocationId
  | CommittedCards InvestigatorId [Card]
  | CommittedCard InvestigatorId Card
  | DealtDamage Source DamageEffect Target
  | TakeDamage Source DamageEffect Target
  | DealtHorror Source Target
  | AssignedHorror Source InvestigatorId [Target]
  | Defeated Source
  | DiscoverClues InvestigatorId LocationId Int
  | GainsClues InvestigatorId Int
  | DiscoveringLastClue InvestigatorId LocationId
  | LastClueRemovedFromAsset AssetId
  | DrawCard InvestigatorId Card DeckSignifier
  | Discarded InvestigatorId Card
  | WouldBeDiscarded Target
  | DrawToken InvestigatorId Token
  | DrawingStartingHand InvestigatorId
  | DuringTurn InvestigatorId
  | EndTurn InvestigatorId
  | InvestigatorDefeated Source InvestigatorId
  | InvestigatorEliminated InvestigatorId
  | AssetDefeated AssetId
  | TookControlOfAsset InvestigatorId AssetId
  | EnemyWouldAttack InvestigatorId EnemyId
  | EnemyAttacks InvestigatorId EnemyId
  | EnemyAttacked InvestigatorId Source EnemyId
  | EnemyDefeated InvestigatorId EnemyId
  | EnemyWouldBeDefeated EnemyId
  | EnemyEngaged InvestigatorId EnemyId
  | EnemyEvaded InvestigatorId EnemyId
  | EnemyAttemptsToSpawnAt EnemyId LocationMatcher
  | EnemySpawns EnemyId LocationId
  | EnemyEnters EnemyId LocationId
  | EnemyLeaves EnemyId LocationId
  | EnterPlay Target
  | AddedToVictory Card
  | Entering InvestigatorId LocationId
  | FailAttackEnemy InvestigatorId EnemyId Int
  | FailEvadeEnemy InvestigatorId EnemyId Int
  | FailInvestigationSkillTest InvestigatorId LocationId Int
  | FailSkillTest InvestigatorId Int
  | FailSkillTestAtOrLess InvestigatorId Int
  | FastPlayerWindow
  | InDiscardWindow InvestigatorId Window
  | InHandWindow InvestigatorId Window
  | Moves InvestigatorId LocationId LocationId
  | MoveAction InvestigatorId LocationId LocationId
  | Leaving InvestigatorId LocationId
  | LeavePlay Target
  | MovedFromHunter EnemyId
  | MovedBy Source LocationId InvestigatorId
  | MovedButBeforeEnemyEngagement InvestigatorId LocationId
  | NonFast
  | PassSkillTest (Maybe Action) Source InvestigatorId Int
  | PassInvestigationSkillTest InvestigatorId LocationId Int
  | PerformAction InvestigatorId Action
  | PhaseBegins Phase
  | PhaseEnds Phase
  | PlacedHorror InvestigatorId Int
  | PlacedDamage InvestigatorId Int
  | PlacedClues Target Int
  | PlaceUnderneath Target Card
  | PlayCard InvestigatorId Card
  | PutLocationIntoPlay InvestigatorId LocationId
  | RevealLocation InvestigatorId LocationId
  | RevealToken InvestigatorId Token
  | RevealTokenWithNegativeModifier InvestigatorId Token
  | SkillTest SkillType
  | InitiatedSkillTest InvestigatorId (Maybe Action) Int
  | SkillTestEnded SkillTest
  | SuccessfulAttackEnemy InvestigatorId EnemyId Int
  | SuccessfulEvadeEnemy InvestigatorId EnemyId Int
  | SuccessfulInvestigation InvestigatorId LocationId
  | TurnBegins InvestigatorId
  | TurnEnds InvestigatorId
  | DeckHasNoCards InvestigatorId
  | WouldDrawEncounterCard InvestigatorId
  | WouldFailSkillTest InvestigatorId
  | WouldReady Target
  | WouldRevealChaosToken Source InvestigatorId
  | WouldTakeDamage Source Target
  | WouldTakeDamageOrHorror Source Target Int Int
  | WouldTakeHorror Source Target
  deriving stock (Show, Generic, Eq)
  deriving anyclass (ToJSON, FromJSON, Hashable)
