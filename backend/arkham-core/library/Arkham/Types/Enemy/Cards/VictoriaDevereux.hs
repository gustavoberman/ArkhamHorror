{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Enemy.Cards.VictoriaDevereux where

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

newtype VictoriaDevereux = VictoriaDevereux Attrs
  deriving newtype (Show, ToJSON, FromJSON)

victoriaDevereux :: EnemyId -> VictoriaDevereux
victoriaDevereux uuid = VictoriaDevereux $ (baseAttrs uuid "01140")
  { enemyHealthDamage = 1
  , enemyFight = 3
  , enemyHealth = Static 3
  , enemyEvade = 2
  , enemyVictory = Just 1
  }

instance (IsInvestigator investigator) => HasActions env investigator VictoriaDevereux where
  getActions i window (VictoriaDevereux attrs@Attrs {..}) = do
    baseActions <- getActions i window attrs
    pure
      $ baseActions
      <> [ ActivateCardAbilityAction
             (getId () i)
             (mkAbility (EnemySource enemyId) 1 (ActionAbility 1 (Just Parley)))
         | resourceCount i >= 5 && locationOf i == enemyLocation
         ]

instance (EnemyRunner env) => RunMessage env VictoriaDevereux where
  runMessage msg e@(VictoriaDevereux attrs@Attrs {..}) = case msg of
    InvestigatorDrawEnemy _ _ eid | eid == enemyId -> e <$ spawnAt eid "01134"
    UseCardAbility iid _ (EnemySource eid) 1 | eid == enemyId ->
      e <$ unshiftMessages
        [SpendResources iid 5, AddToVictory (EnemyTarget enemyId)]
    _ -> VictoriaDevereux <$> runMessage msg attrs