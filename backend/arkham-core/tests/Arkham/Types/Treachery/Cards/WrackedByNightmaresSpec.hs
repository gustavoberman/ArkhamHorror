module Arkham.Treachery.Cards.WrackedByNightmaresSpec
  ( spec
  ) where

import TestImport.Lifted

import Arkham.Treachery.Cards qualified as Cards
import Arkham.Asset.Attrs qualified as Asset

spec :: Spec
spec = describe "Wracked by Nightmares" $ do
  it "prevents controlled assets from readying" $ do
    investigator <- testInvestigator "00000" id
    wrackedByNightmares <- genPlayerCard Cards.wrackedByNightmares
    asset <- testAsset
      ((Asset.exhaustedL .~ True) . (Asset.investigatorL ?~ toId investigator))
    gameTest
        investigator
        [ loadDeck investigator [wrackedByNightmares]
        , drawCards investigator 1
        , ReadyExhausted
        ]
        (assetsL %~ insertEntity asset)
      $ do
          runMessages
          investigator' <- updated investigator
          hasTreacheryWithMatchingCardCode
              (PlayerCard wrackedByNightmares)
              investigator'
            `shouldReturn` True
          updated asset `shouldSatisfyM` isExhausted

  it "trigger actions removes restriction and takes two actions" $ do
    investigator <- testInvestigator "00000" id
    wrackedByNightmares <- genPlayerCard Cards.wrackedByNightmares
    asset <- testAsset
      ((Asset.exhaustedL .~ True) . (Asset.investigatorL ?~ toId investigator))
    gameTest
        investigator
        [loadDeck investigator [wrackedByNightmares], drawCards investigator 1]
        (assetsL %~ insertEntity asset)
      $ do
          runMessages
          game <- getTestGame
          let
            wrackedByNightmaresTreachery =
              game ^?! treacheriesL . to toList . ix 0
          [discardWrackedByNightmares] <- getAbilitiesOf
            wrackedByNightmaresTreachery
          pushAll
            [ UseAbility (toId investigator) discardWrackedByNightmares []
            , ReadyExhausted
            ]
          runMessages
          investigator' <- updated investigator
          hasTreacheryWithMatchingCardCode
              (PlayerCard wrackedByNightmares)
              investigator'
            `shouldReturn` False
          updated asset `shouldSatisfyM` isReady
          isInDiscardOf investigator wrackedByNightmares `shouldReturn` True
          getRemainingActions investigator `shouldReturn` 1
