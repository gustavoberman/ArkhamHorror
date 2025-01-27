module Arkham.Scenarios.APhantomOfTruth.Helpers (module Arkham.Scenarios.APhantomOfTruth.Helpers, module X) where

import Arkham.Prelude

import Arkham.Enemy.Cards qualified as Cards
import Arkham.Classes
import Arkham.Cost
import Arkham.Game.Helpers
import Arkham.Id
import Arkham.Matcher hiding (MoveAction)
import Arkham.Message
import Arkham.Query
import Arkham.Target
import Arkham.Campaigns.ThePathToCarcosa.Helpers as X

getTheOrganist :: (Query EnemyMatcher env, MonadReader env m) => m EnemyId
getTheOrganist = selectJust $ EnemyWithTitle "The Organist"

investigatorsNearestToTheOrganist ::
  (HasList (InvestigatorId, Distance) env EnemyMatcher, MonadReader env m) =>
  m (Distance, [InvestigatorId])
investigatorsNearestToTheOrganist = do
  mappings :: [(InvestigatorId, Distance)] <-
    getList
      ( EnemyOneOf
          [ enemyIs Cards.theOrganistHopelessIDefiedHim
          , enemyIs Cards.theOrganistDrapedInMystery
          ]
      )
  let minDistance :: Int =
        fromJustNote "error" . minimumMay $ map (unDistance . snd) mappings
  pure . (Distance minDistance,) . hashNub . map fst $
    filter
      ((== minDistance) . unDistance . snd)
      mappings

moveOrganistAwayFromNearestInvestigator ::
  ( MonadReader env m
  , HasId LeadInvestigatorId env ()
  , HasList (LocationId, Distance) env InvestigatorId
  , HasList (InvestigatorId, Distance) env EnemyMatcher
  , Query LocationMatcher env
  , Query EnemyMatcher env
  ) =>
  m Message
moveOrganistAwayFromNearestInvestigator = do
  organist <-
    selectJust $
      EnemyOneOf
        [ enemyIs Cards.theOrganistDrapedInMystery
        , enemyIs Cards.theOrganistHopelessIDefiedHim
        ]
  leadInvestigatorId <- getLeadInvestigatorId
  (minDistance, iids) <- investigatorsNearestToTheOrganist
  lids <-
    setFromList . concat
      <$> for
        iids
        ( \iid -> do
            rs <- getList iid
            pure $ map fst $ filter ((> minDistance) . snd) rs
        )
  withNoInvestigators <- select LocationWithoutInvestigators
  let forced = lids `intersect` withNoInvestigators
      targets = toList $ if null forced then lids else forced
  pure $
    chooseOne
      leadInvestigatorId
      [ TargetLabel (LocationTarget lid) [EnemyMove organist lid]
      | lid <- targets
      ]

disengageEachEnemyAndMoveToConnectingLocation ::
  ( MonadReader env m
  , HasSet InvestigatorId env ()
  , HasId LeadInvestigatorId env ()
  , Query EnemyMatcher env
  , Query LocationMatcher env
  ) =>
  m [Message]
disengageEachEnemyAndMoveToConnectingLocation = do
  leadInvestigatorId <- getLeadInvestigatorId
  iids <- getInvestigatorIds
  enemyPairs <-
    traverse
      (traverseToSnd (selectList . EnemyIsEngagedWith . InvestigatorWithId))
      iids
  locationPairs <-
    traverse
      ( traverseToSnd
          ( selectList
              . AccessibleFrom
              . LocationWithInvestigator
              . InvestigatorWithId
          )
      )
      iids
  pure $
    [ DisengageEnemy iid enemy
    | (iid, enemies) <- enemyPairs
    , enemy <- enemies
    ]
      <> [ chooseOneAtATime
            leadInvestigatorId
            [ TargetLabel
              (InvestigatorTarget iid)
              [ chooseOne
                  iid
                  [ TargetLabel
                    (LocationTarget lid)
                    [MoveAction iid lid Free False]
                  | lid <- locations
                  ]
              ]
            | (iid, locations) <- locationPairs
            ]
         ]
