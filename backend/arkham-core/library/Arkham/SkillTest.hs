{-# OPTIONS_GHC -Wno-orphans #-}
module Arkham.SkillTest (
  module X,
  module Arkham.SkillTest,
) where

import Arkham.Prelude

import Arkham.Action (Action)
import Arkham.SkillTestResult
import Arkham.SkillTest.Base as X
import Arkham.SkillType
import Arkham.Card
import Arkham.Card.Id
import Arkham.Classes
import Arkham.Id
import Arkham.Modifier
import Arkham.Source
import Arkham.Target
import Arkham.Token

class HasSkillTest env where
  getSkillTest :: MonadReader env m => m (Maybe SkillTest)

getSkillTestTarget :: (MonadReader env m, HasSkillTest env) => m (Maybe Target)
getSkillTestTarget = fmap skillTestTarget <$> getSkillTest

getSkillTestSource :: (MonadReader env m, HasSkillTest env) => m (Maybe Source)
getSkillTestSource = fmap toSource <$> getSkillTest

data SkillTestResultsData = SkillTestResultsData
  { skillTestResultsSkillValue :: Int
  , skillTestResultsIconValue :: Int
  , skillTestResultsTokensValue :: Int
  , skillTestResultsDifficulty :: Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

subscribersL :: Lens' SkillTest [Target]
subscribersL =
  lens skillTestSubscribers $ \m x -> m {skillTestSubscribers = x}

setAsideTokensL :: Lens' SkillTest [Token]
setAsideTokensL =
  lens skillTestSetAsideTokens $ \m x -> m {skillTestSetAsideTokens = x}

resolvedTokensL :: Lens' SkillTest [Token]
resolvedTokensL =
  lens skillTestResolvedTokens $ \m x -> m {skillTestResolvedTokens = x}

revealedTokensL :: Lens' SkillTest [Token]
revealedTokensL =
  lens skillTestRevealedTokens $ \m x -> m {skillTestRevealedTokens = x}

committedCardsL :: Lens' SkillTest (HashMap CardId (InvestigatorId, Card))
committedCardsL =
  lens skillTestCommittedCards $ \m x -> m {skillTestCommittedCards = x}

resultL :: Lens' SkillTest SkillTestResult
resultL = lens skillTestResult $ \m x -> m {skillTestResult = x}

valueModifierL :: Lens' SkillTest Int
valueModifierL =
  lens skillTestValueModifier $ \m x -> m {skillTestValueModifier = x}

instance TargetEntity SkillTest where
  toTarget _ = SkillTestTarget
  isTarget _ SkillTestTarget = True
  isTarget _ _ = False

instance SourceEntity SkillTest where
  toSource SkillTest {..} =
    SkillTestSource
      skillTestInvestigator
      skillTestSkillType
      skillTestSource
      skillTestAction
  isSource _ SkillTestSource {} = True
  isSource _ _ = False

-- TODO: Cursed Swamp would apply to anyone trying to commit skill cards
instance HasModifiersFor env SkillTest

instance HasList CommittedCard env (InvestigatorId, SkillTest) where
  getList (iid, st) =
    pure
      . map (CommittedCard . snd)
      . filter ((== iid) . fst)
      . toList
      $ skillTestCommittedCards st

instance HasSet CommittedCardId env (InvestigatorId, SkillTest) where
  getSet (iid, st) =
    pure
      . mapSet CommittedCardId
      . keysSet
      . filterMap ((== iid) . fst)
      $ skillTestCommittedCards st

instance HasSet CommittedSkillId env (InvestigatorId, SkillTest) where
  getSet (iid, st) =
    pure
      . mapSet (CommittedSkillId . SkillId)
      . keysSet
      . filterMap
        (\(iid', card') -> iid' == iid && toCardType card' == SkillType)
      $ skillTestCommittedCards st

instance HasModifiersFor env () => HasList CommittedSkillIcon env (InvestigatorId, SkillTest) where
  getList (iid, st) = do
    let cards = toList . filterMap ((== iid) . fst) $ skillTestCommittedCards st
    concatMapM (fmap (map CommittedSkillIcon) . iconsForCard . snd) cards
   where
    iconsForCard c@(PlayerCard MkPlayerCard {..}) = do
      modifiers' <- getModifiers (toSource st) (CardIdTarget pcId)
      pure $ foldr applyAfterSkillModifiers (foldr applySkillModifiers (cdSkills $ toCardDef c) modifiers') modifiers'
    iconsForCard _ = pure []
    applySkillModifiers (AddSkillIcons xs) ys = xs <> ys
    applySkillModifiers _ ys = ys
    applyAfterSkillModifiers DoubleSkillIcons ys = ys <> ys
    applyAfterSkillModifiers _ ys = ys

instance HasSet CommittedCardCode env SkillTest where
  getSet =
    pure
      . setFromList
      . map (CommittedCardCode . cdCardCode . toCardDef . snd)
      . toList
      . skillTestCommittedCards

initSkillTest ::
  InvestigatorId ->
  Source ->
  Target ->
  Maybe Action ->
  SkillType ->
  Int ->
  Int ->
  SkillTest
initSkillTest iid source target maction skillType' _skillValue' difficulty' =
  SkillTest
    { skillTestInvestigator = iid
    , skillTestSkillType = skillType'
    , skillTestDifficulty = difficulty'
    , skillTestSetAsideTokens = mempty
    , skillTestRevealedTokens = mempty
    , skillTestResolvedTokens = mempty
    , skillTestValueModifier = 0
    , skillTestResult = Unrun
    , skillTestCommittedCards = mempty
    , skillTestSource = source
    , skillTestTarget = target
    , skillTestAction = maction
    , skillTestSubscribers = [InvestigatorTarget iid]
    }
