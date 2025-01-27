{-# OPTIONS_GHC -Wno-orphans #-}
module Arkham.Location.Runner (module Arkham.Location.Runner, module X) where

import Arkham.Prelude

import Arkham.Card.CardDef as X
import Arkham.Classes as X
import Arkham.Location.Attrs as X
import Arkham.LocationSymbol as X

import Arkham.Ability
import Arkham.Action qualified as Action
import Arkham.Card
import Arkham.Card.EncounterCard
import Arkham.Card.Id
import Arkham.Cost
import Arkham.Criteria
import Arkham.Direction
import Arkham.Exception
import Arkham.Id
import Arkham.Location.Helpers
import Arkham.Matcher
  (AgendaMatcher, AssetMatcher, EnemyMatcher, ExtendedCardMatcher, LocationMatcher(..), locationWithEnemy)
import Arkham.Message
import Arkham.Modifier
import Arkham.Name
import Arkham.Query
import Arkham.SkillTest
import Arkham.SkillType
import Arkham.Source
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Trait
import Arkham.Window (Window(..))
import Arkham.Window qualified as Window

type LocationRunner env =
  ( HasQueue env
  , CanCheckPlayable env
  , HasSkillTest env
  , HasSet EnemyId env EnemyMatcher
  , Query AgendaMatcher env
  , Query AssetMatcher env
  , Query LocationMatcher env
  , Query EnemyMatcher env
  , Query ExtendedCardMatcher env
  , HasCostPayment env
  , HasCount ActionRemainingCount env InvestigatorId
  , HasCount ClueCount env InvestigatorId
  , HasCount HorrorCount env InvestigatorId
  , HasCount PlayerCount env ()
  , HasId (Maybe LocationId) env LocationMatcher
  , HasId ActiveInvestigatorId env ()
  , HasId CardCode env EnemyId
  , HasId LeadInvestigatorId env ()
  , HasId LocationId env InvestigatorId
  , HasList DiscardedEncounterCard env ()
  , HasList HandCard env InvestigatorId
  , HasList LocationName env ()
  , HasList UsedAbility env ()
  , HasModifiersFor env ()
  , HasName env LocationId
  , HasSet ActId env ()
  , HasSet ConnectedLocationId env LocationId
  , HasSet EnemyId env Trait
  , HasSet EnemyId env CardCode
  , HasSet EnemyAccessibleLocationId env (EnemyId, LocationId)
  , HasSet EventId env ()
  , HasSet HandCardId env (InvestigatorId, CardType)
  , HasSet InvestigatorId env ()
  , HasSet LocationId env ()
  , HasSet LocationId env LocationMatcher
  , HasSet LocationId env (HashSet LocationSymbol)
  , HasSet LocationId env [Trait]
  , HasList SetAsideCard env ()
  , HasSet Trait env Source
  , HasSet Trait env EnemyId
  , HasSet Trait env LocationId
  , HasSet UnrevealedLocationId env ()
  , HasSet UnrevealedLocationId env LocationMatcher
  )

instance LocationRunner env => RunMessage env LocationAttrs where
  runMessage msg a@LocationAttrs {..} = case msg of
    Investigate iid lid source mTarget skillType False | lid == locationId -> do
      allowed <- getInvestigateAllowed iid a
      if allowed
        then do
          shroudValue' <- getModifiedShroudValueFor a
          a <$ push
            (BeginSkillTest
              iid
              source
              (maybe
                (LocationTarget lid)
                (ProxyTarget (LocationTarget lid))
                mTarget
              )
              (Just Action.Investigate)
              skillType
              shroudValue'
            )
        else pure a
    PassedSkillTest iid (Just Action.Investigate) source (SkillTestInitiatorTarget target) _ n
      | isTarget a target
      -> a <$ push (Successful (Action.Investigate, target) iid source target n)
    PassedSkillTest iid (Just Action.Investigate) source (SkillTestInitiatorTarget (ProxyTarget target investigationTarget)) _ n
      | isTarget a target
      -> a
        <$ push
             (Successful
               (Action.Investigate, target)
               iid
               source
               investigationTarget
               n
             )
    Successful (Action.Investigate, _) iid _ target _ | isTarget a target -> do
      let lid = toId a
      modifiers' <- getModifiers (InvestigatorSource iid) (LocationTarget lid)
      whenWindowMsg <- checkWindows
        [Window Timing.When (Window.SuccessfulInvestigation iid lid)]
      afterWindowMsg <- checkWindows
        [Window Timing.After (Window.SuccessfulInvestigation iid lid)]
      a <$ unless
        (AlternateSuccessfullInvestigation `elem` modifiers')
        (pushAll
          [ whenWindowMsg
          , InvestigatorDiscoverClues iid lid 1 (Just Action.Investigate)
          , afterWindowMsg
          ]
        )
    PlaceUnderneath target cards | isTarget a target ->
      pure $ a & cardsUnderneathL <>~ cards
    SetLocationLabel lid label' | lid == locationId ->
      pure $ a & labelL .~ label'
    PlacedLocationDirection lid direction lid2 | lid == locationId -> do
      let
        reversedDirection = case direction of
          LeftOf -> RightOf
          RightOf -> LeftOf
          Above -> Below
          Below -> Above

      pure $ a & (directionsL %~ insertMap reversedDirection lid2)
    PlacedLocationDirection lid direction lid2 | lid2 == locationId ->
      pure $ a & (directionsL %~ insertMap direction lid)
    AttachTreachery tid (LocationTarget lid) | lid == locationId ->
      pure $ a & treacheriesL %~ insertSet tid
    AttachEvent eid (LocationTarget lid) | lid == locationId ->
      pure $ a & eventsL %~ insertSet eid
    Discarded (AssetTarget aid) _ -> pure $ a & assetsL %~ deleteSet aid
    Discard (TreacheryTarget tid) -> pure $ a & treacheriesL %~ deleteSet tid
    Discard (EventTarget eid) -> pure $ a & eventsL %~ deleteSet eid
    Discarded (EnemyTarget eid) _ -> pure $ a & enemiesL %~ deleteSet eid
    PlaceEnemyInVoid eid -> pure $ a & enemiesL %~ deleteSet eid
    Flipped (AssetSource aid) card | toCardType card /= AssetType ->
      pure $ a & assetsL %~ deleteSet aid
    RemoveFromGame (AssetTarget aid) -> pure $ a & assetsL %~ deleteSet aid
    RemoveFromGame (TreacheryTarget tid) ->
      pure $ a & treacheriesL %~ deleteSet tid
    RemoveFromGame (EventTarget eid) -> pure $ a & eventsL %~ deleteSet eid
    RemoveFromGame (EnemyTarget eid) -> pure $ a & enemiesL %~ deleteSet eid
    Discard target | isTarget a target ->
      a <$ pushAll (resolve (RemoveLocation $ toId a))
    AttachAsset aid (LocationTarget lid) | lid == locationId ->
      pure $ a & assetsL %~ insertSet aid
    AttachAsset aid _ -> pure $ a & assetsL %~ deleteSet aid
    AddDirectConnection fromLid toLid | fromLid == locationId -> do
      pure
        $ a
        & revealedConnectedMatchersL
        <>~ [LocationWithId toLid]
        & connectedMatchersL
        <>~ [LocationWithId toLid]
    DiscoverCluesAtLocation iid lid n maction | lid == locationId -> do
      let discoveredClues = min n locationClues
      checkWindowMsg <- checkWindows
        [Window Timing.When (Window.DiscoverClues iid lid discoveredClues)]
      a <$ pushAll
        [checkWindowMsg, DiscoverClues iid lid discoveredClues maction]
    Do (DiscoverClues iid lid n _) | lid == locationId -> do
      let lastClue = locationClues - n <= 0
      push =<< checkWindows
        (Window Timing.After (Window.DiscoverClues iid lid n)
        : [ Window Timing.After (Window.DiscoveringLastClue iid lid)
          | lastClue
          ]
        )
      pure $ a & cluesL %~ max 0 . subtract n
    InvestigatorEliminated iid -> pure $ a & investigatorsL %~ deleteSet iid
    EnterLocation iid lid
      | lid /= locationId && iid `elem` locationInvestigators
      -> pure $ a & investigatorsL %~ deleteSet iid -- TODO: should we broadcast leaving the location
    EnterLocation iid lid | lid == locationId -> do
      push =<< checkWindows [Window Timing.When $ Window.Entering iid lid]
      unless locationRevealed $ push (RevealLocation (Just iid) lid)
      pure $ a & investigatorsL %~ insertSet iid
    SetLocationAsIf iid lid | lid == locationId -> do
      pure $ a & investigatorsL %~ insertSet iid
    SetLocationAsIf iid lid | lid /= locationId -> do
      pure $ a & investigatorsL %~ deleteSet iid
    AddToVictory (EnemyTarget eid) -> pure $ a & enemiesL %~ deleteSet eid
    EnemyEngageInvestigator eid iid -> do
      lid <- getId @LocationId iid
      if lid == locationId then pure $ a & enemiesL %~ insertSet eid else pure a
    EnemyMove eid lid | lid == locationId -> do
      willMove <- canEnterLocation eid lid
      pure $ if willMove then a & enemiesL %~ insertSet eid else a
    EnemyMove eid lid -> do
      mLocationId <- selectOne $ locationWithEnemy eid
      if mLocationId == Just locationId
         then do
           willMove <- canEnterLocation eid lid
           pure $ if willMove then a & enemiesL %~ deleteSet eid else a
         else pure a
    EnemyEntered eid lid | lid == locationId -> do
      pure $ a & enemiesL %~ insertSet eid
    EnemyEntered eid lid | lid /= locationId -> do
      pure $ a & enemiesL %~ deleteSet eid
    Will next@(EnemySpawn miid lid eid) | lid == locationId -> do
      shouldSpawnNonEliteAtConnectingInstead <-
        getShouldSpawnNonEliteAtConnectingInstead a
      when shouldSpawnNonEliteAtConnectingInstead $ do
        traits' <- getSetList eid
        when (Elite `notElem` traits') $ do
          activeInvestigatorId <- unActiveInvestigatorId <$> getId ()
          connectedLocationIds <- map unConnectedLocationId <$> getSetList lid
          availableLocationIds <-
            flip filterM connectedLocationIds $ \locationId' -> do
              modifiers' <- getModifiers
                (EnemySource eid)
                (LocationTarget locationId')
              pure . not $ flip any modifiers' $ \case
                SpawnNonEliteAtConnectingInstead{} -> True
                _ -> False
          withQueue_ $ filter (/= next)
          if null availableLocationIds
            then push (Discard (EnemyTarget eid))
            else push
              (chooseOne
                activeInvestigatorId
                [ Run
                    [Will (EnemySpawn miid lid' eid), EnemySpawn miid lid' eid]
                | lid' <- availableLocationIds
                ]
              )
      pure a
    EnemySpawn _ lid eid | lid == locationId ->
      pure $ a & enemiesL %~ insertSet eid
    EnemySpawnedAt lid eid | lid == locationId ->
      pure $ a & enemiesL %~ insertSet eid
    RemoveEnemy eid -> pure $ a & enemiesL %~ deleteSet eid
    RemovedFromPlay (EnemySource eid) -> pure $ a & enemiesL %~ deleteSet eid
    TakeControlOfAsset _ aid -> pure $ a & assetsL %~ deleteSet aid
    MoveAllCluesTo target | not (isTarget a target) -> do
      when (locationClues > 0) (push $ PlaceClues target locationClues)
      pure $ a & cluesL .~ 0
    PlaceClues target n | isTarget a target -> do
      modifiers' <- getModifiers (toSource a) (toTarget a)
      windows' <- windows [Window.PlacedClues (toTarget a) n]
      if CannotPlaceClues `elem` modifiers'
        then pure a
        else do
          pushAll windows'
          pure $ a & cluesL +~ n
    PlaceCluesUpToClueValue lid n | lid == locationId -> do
      clueValue <- getPlayerCountValue locationRevealClues
      let n' = min n (clueValue - locationClues)
      a <$ push (PlaceClues (toTarget a) n')
    PlaceDoom target n | isTarget a target -> pure $ a & doomL +~ n
    RemoveDoom target n | isTarget a target ->
      pure $ a & doomL %~ max 0 . subtract n
    PlaceResources target n | isTarget a target -> pure $ a & resourcesL +~ n
    PlaceHorror target n | isTarget a target -> pure $ a & horrorL +~ n
    RemoveClues (LocationTarget lid) n | lid == locationId ->
      pure $ a & cluesL %~ max 0 . subtract n
    RemoveAllClues target | isTarget a target -> pure $ a & cluesL .~ 0
    RemoveAllDoom -> pure $ a & doomL .~ 0
    RevealLocation miid lid | lid == locationId -> do
      modifiers' <- getModifiers (toSource a) (toTarget a)
      locationClueCount <- if CannotPlaceClues `elem` modifiers'
        then pure 0
        else getPlayerCountValue locationRevealClues
      revealer <- maybe getLeadInvestigatorId pure miid
      whenWindowMsg <- checkWindows
        [Window Timing.When (Window.RevealLocation revealer lid)]

      afterWindowMsg <- checkWindows
        [Window Timing.After (Window.RevealLocation revealer lid)]
      pushAll
        $ [whenWindowMsg, afterWindowMsg]
        <> [ PlaceClues (toTarget a) locationClueCount | locationClueCount > 0 ]
      pure $ a & revealedL .~ True
    LookAtRevealed source target | isTarget a target -> do
      push (Label "Continue" [After (LookAtRevealed source target)])
      pure $ a & revealedL .~ True
    After (LookAtRevealed _ target) | isTarget a target ->
      pure $ a & revealedL .~ False
    UnrevealLocation lid | lid == locationId -> pure $ a & revealedL .~ False
    RemoveLocation lid -> pure $ a & directionsL %~ filterMap (/= lid)
    UseResign iid source | isSource a source -> a <$ push (Resign iid)
    UseDrawCardUnderneath iid source | isSource a source ->
      case locationCardsUnderneath of
        (EncounterCard card : rest) -> do
          push (InvestigatorDrewEncounterCard iid card)
          pure $ a & cardsUnderneathL .~ rest
        _ ->
          throwIO
            $ InvalidState
            $ "Not expecting a player card or empty set, but got "
            <> tshow locationCardsUnderneath
    Blanked msg' -> runMessage msg' a
    UseCardAbility iid source _ 101 _ | isSource a source -> do
      let
        triggerSource = case source of
          ProxySource _ s -> s
          _ -> InvestigatorSource iid
      a <$ push
        (Investigate iid (toId a) triggerSource Nothing SkillIntellect False)
    UseCardAbility iid source _ 102 _ | isSource a source -> a <$ push
      (MoveAction
        iid
        locationId
        Free -- already paid by using ability
        True
      )
    _ -> pure a

locationEnemiesWithTrait
  :: (MonadReader env m, HasSet Trait env EnemyId)
  => LocationAttrs
  -> Trait
  -> m [EnemyId]
locationEnemiesWithTrait LocationAttrs { locationEnemies } trait =
  filterM (fmap (member trait) . getSet) (setToList locationEnemies)

locationInvestigatorsWithClues
  :: (MonadReader env m, HasCount ClueCount env InvestigatorId)
  => LocationAttrs
  -> m [InvestigatorId]
locationInvestigatorsWithClues LocationAttrs { locationInvestigators } =
  filterM
    (fmap ((> 0) . unClueCount) . getCount)
    (setToList locationInvestigators)

getModifiedShroudValueFor
  :: (MonadReader env m, HasModifiersFor env ()) => LocationAttrs -> m Int
getModifiedShroudValueFor attrs = do
  modifiers' <- getModifiers (toSource attrs) (toTarget attrs)
  pure $ foldr applyModifier (locationShroud attrs) modifiers'
 where
  applyModifier (ShroudModifier m) n = max 0 (n + m)
  applyModifier _ n = n

getInvestigateAllowed
  :: (MonadReader env m, HasModifiersFor env ())
  => InvestigatorId
  -> LocationAttrs
  -> m Bool
getInvestigateAllowed iid attrs = do
  modifiers1' <- getModifiers (toSource attrs) (toTarget attrs)
  modifiers2' <- getModifiers (InvestigatorSource iid) (toTarget attrs)
  pure $ not (any isCannotInvestigate $ modifiers1' <> modifiers2')
 where
  isCannotInvestigate CannotInvestigate{} = True
  isCannotInvestigate _ = False

canEnterLocation
  :: (MonadReader env m, HasModifiersFor env (), HasSet Trait env EnemyId)  => EnemyId -> LocationId -> m Bool
canEnterLocation eid lid = do
  traits' <- getSet eid
  modifiers' <- getModifiers (EnemySource eid) (LocationTarget lid)
  pure $ not $ flip any modifiers' $ \case
    CannotBeEnteredByNonElite{} -> Elite `notMember` traits'
    _ -> False

withResignAction
  :: (Entity location, EntityAttrs location ~ LocationAttrs)
  => location
  -> [Ability]
  -> [Ability]
withResignAction x body = do
  let other = withBaseAbilities attrs body
  locationResignAction attrs : other
  where attrs = toAttrs x

withDrawCardUnderneathAction
  :: (Entity location, EntityAttrs location ~ LocationAttrs)
  => location
  -> [Ability]
withDrawCardUnderneathAction x = withBaseAbilities
  attrs
  [ drawCardUnderneathAction attrs | locationRevealed attrs ]
  where attrs = toAttrs x

instance HasAbilities LocationAttrs where
  getAbilities l =
    [ restrictedAbility l 101 (OnLocation $ LocationWithId $ toId l)
      $ ActionAbility (Just Action.Investigate) (ActionCost 1)
    , restrictedAbility
        l
        102
        (OnLocation $ AccessibleTo $ LocationWithId $ toId l)
      $ ActionAbility (Just Action.Move) moveCost
    ]
   where
    moveCost = if not (locationRevealed l)
      then locationCostToEnterUnrevealed l
      else ActionCost 1

getShouldSpawnNonEliteAtConnectingInstead
  :: (MonadReader env m, HasModifiersFor env ()) => LocationAttrs -> m Bool
getShouldSpawnNonEliteAtConnectingInstead attrs = do
  modifiers' <- getModifiers (toSource attrs) (toTarget attrs)
  pure $ flip any modifiers' $ \case
    SpawnNonEliteAtConnectingInstead{} -> True
    _ -> False

instance Named LocationAttrs where
  toName l = if locationRevealed l
    then fromMaybe baseName (cdRevealedName $ toCardDef l)
    else baseName
    where baseName = toName (toCardDef l)

instance Named (Unrevealed LocationAttrs) where
  toName (Unrevealed l) = toName (toCardDef l)

instance IsCard LocationAttrs where
  toCardId = unLocationId . locationId
  toCardOwner = const Nothing

instance HasName env LocationAttrs where
  getName = pure . toName

instance HasName env (Unrevealed LocationAttrs) where
  getName = pure . toName

instance HasId (Maybe LocationId) env (Direction, LocationAttrs) where
  getId (dir, LocationAttrs {..}) = pure $ lookup dir locationDirections

instance HasId LocationSymbol env LocationAttrs where
  getId = pure . locationSymbol

instance HasList UnderneathCard env LocationAttrs where
  getList = pure . map UnderneathCard . locationCardsUnderneath
