module Arkham.Asset.Cards.Rolands38SpecialSpec
  ( spec
  ) where

import TestImport

import Arkham.Enemy.Attrs (EnemyAttrs(..))
import Arkham.Investigator.Attrs (InvestigatorAttrs(..))
import Arkham.Location.Attrs (LocationAttrs(..))

spec :: Spec
spec = describe "Roland's .39 Special" $ do
  it "gives +1 combat and +1 damage" $ do
    investigator <- testInvestigator "00000"
      $ \attrs -> attrs { investigatorCombat = 1 }
    rolands38Special <- buildAsset "01006"
    enemy <- testEnemy
      $ \attrs -> attrs { enemyFight = 2, enemyHealth = Static 3 }
    location <- testLocation id
    gameTest
        investigator
        [ SetTokens [Zero]
        , placedLocation location
        , enemySpawn location enemy
        , playAsset investigator rolands38Special
        , moveTo investigator location
        ]
        ((assetsL %~ insertEntity rolands38Special)
        . (enemiesL %~ insertEntity enemy)
        . (locationsL %~ insertEntity location)
        )
      $ do
          runMessages
          [doFight] <- getAbilitiesOf rolands38Special
          push $ UseAbility (toId investigator) doFight []
          runMessages
          chooseOnlyOption "choose enemy"
          chooseOnlyOption "start skill test"
          chooseOnlyOption "apply results"

          updated enemy `shouldSatisfyM` hasDamage (2, 0)

  it
      "gives +3 combat and +1 damage if there are 1 or more clues on your location"
    $ do
        investigator <- testInvestigator "00000"
          $ \attrs -> attrs { investigatorCombat = 1 }
        rolands38Special <- buildAsset "01006"
        enemy <- testEnemy
          $ \attrs -> attrs { enemyFight = 4, enemyHealth = Static 3 }
        location <- testLocation $ \attrs -> attrs { locationClues = 1 }
        gameTest
            investigator
            [ SetTokens [Zero]
            , placedLocation location
            , enemySpawn location enemy
            , playAsset investigator rolands38Special
            , moveTo investigator location
            ]
            ((assetsL %~ insertEntity rolands38Special)
            . (enemiesL %~ insertEntity enemy)
            . (locationsL %~ insertEntity location)
            )
          $ do
              runMessages
              [doFight] <- getAbilitiesOf rolands38Special
              push $ UseAbility (toId investigator) doFight []
              runMessages
              chooseOnlyOption "choose enemy"
              chooseOnlyOption "start skill test"
              chooseOnlyOption "apply results"

              updated enemy `shouldSatisfyM` hasDamage (2, 0)
