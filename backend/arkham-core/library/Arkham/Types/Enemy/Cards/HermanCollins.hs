{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Enemy.Cards.HermanCollins where

import Arkham.Json
import Arkham.Types.Ability
import Arkham.Types.Action hiding (Ability)
import Arkham.Types.Classes
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Enemy.Runner
import Arkham.Types.EnemyId
import Arkham.Types.GameValue
import Arkham.Types.Message
import Arkham.Types.Source
import Arkham.Types.Target
import ClassyPrelude

newtype HermanCollins = HermanCollins Attrs
  deriving newtype (Show, ToJSON, FromJSON)

hermanCollins :: EnemyId -> HermanCollins
hermanCollins uuid = HermanCollins $ (baseAttrs uuid "01138")
  { enemyHealthDamage = 1
  , enemySanityDamage = 1
  , enemyFight = 3
  , enemyHealth = Static 4
  , enemyEvade = 4
  , enemyVictory = Just 1
  }

instance (IsInvestigator investigator) => HasActions env investigator HermanCollins where
  getActions i window (HermanCollins attrs@Attrs {..}) = do
    baseActions <- getActions i window attrs
    pure
      $ baseActions
      <> [ ActivateCardAbilityAction
             (getId () i)
             (mkAbility (EnemySource enemyId) 1 (ActionAbility 1 (Just Parley)))
         | cardCount i >= 4 && locationOf i == enemyLocation
         ]

instance (EnemyRunner env) => RunMessage env HermanCollins where
  runMessage msg e@(HermanCollins attrs@Attrs {..}) = case msg of
    InvestigatorDrawEnemy _ _ eid | eid == enemyId -> e <$ spawnAt eid "01134"
    UseCardAbility iid _ (EnemySource eid) 1 | eid == enemyId ->
      e <$ unshiftMessages
        (replicate 4 (ChooseAndDiscardCard iid)
        <> [AddToVictory (EnemyTarget enemyId)]
        )
    _ -> HermanCollins <$> runMessage msg attrs