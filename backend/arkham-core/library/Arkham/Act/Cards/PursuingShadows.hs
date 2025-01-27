module Arkham.Act.Cards.PursuingShadows
  ( PursuingShadows(..)
  , pursuingShadows
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Act.Attrs
import qualified Arkham.Act.Cards as Cards
import Arkham.Act.Runner
import Arkham.Act.Helpers
import Arkham.Classes
import Arkham.CampaignLogKey
import Arkham.Criteria
import Arkham.Resolution
import Arkham.GameValue
import Arkham.Matcher
import Arkham.Message
import Arkham.Scenarios.APhantomOfTruth.Helpers
import Arkham.Target
import qualified Arkham.Timing as Timing

newtype PursuingShadows = PursuingShadows ActAttrs
  deriving anyclass (IsAct, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

pursuingShadows :: ActCard PursuingShadows
pursuingShadows = act (2, A) PursuingShadows Cards.pursuingShadows Nothing

instance HasAbilities PursuingShadows where
  getAbilities (PursuingShadows a) =
    [ reaction a 1 NoRestriction (GroupClueCost (Static 1) YourLocation)
      $ EnemyAttacked Timing.After You AnySource (EnemyWithTitle "The Organist")
    , restrictedAbility
        a
        2
        (EnemyCriteria
        $ EnemyExists
        $ EnemyWithTitle "The Organist"
        <> EnemyWithClues (AtLeast $ PerPlayer 3)
        )
      $ Objective
      $ ForcedAbility AnyWindow
    ]

instance ActRunner env => RunMessage env PursuingShadows where
  runMessage msg a@(PursuingShadows attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source -> do
      theOrganist <- EnemyTarget <$> getTheOrganist
      a <$ push (PlaceClues theOrganist 1)
    UseCardAbility _ source _ 2 _ | isSource attrs source ->
      a <$ push (AdvanceAct (toId attrs) source AdvancedWithOther)
    AdvanceAct aid _ _ | aid == toId a && onSide B attrs -> do
      intrudedOnASecretMeeting <- getHasRecord YouIntrudedOnASecretMeeting
      a <$ push (ScenarioResolution $ Resolution $ if intrudedOnASecretMeeting then 2 else 1)
    _ -> PursuingShadows <$> runMessage msg attrs
