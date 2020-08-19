{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Enemy.Cards.PeterWarren where

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

newtype PeterWarren = PeterWarren Attrs
  deriving newtype (Show, ToJSON, FromJSON)

peterWarren :: EnemyId -> PeterWarren
peterWarren uuid = PeterWarren $ (baseAttrs uuid "01139")
  { enemyHealthDamage = 1
  , enemyFight = 2
  , enemyHealth = Static 3
  , enemyEvade = 3
  , enemyVictory = Just 1
  }

instance (IsInvestigator investigator) => HasActions env investigator PeterWarren where
  getActions i window (PeterWarren attrs@Attrs {..}) = do
    baseActions <- getActions i window attrs
    pure
      $ baseActions
      <> [ ActivateCardAbilityAction
             (getId () i)
             (mkAbility (EnemySource enemyId) 1 (ActionAbility 1 (Just Parley)))
         | clueCount i >= 2 && locationOf i == enemyLocation
         ]

instance (EnemyRunner env) => RunMessage env PeterWarren where
  runMessage msg e@(PeterWarren attrs@Attrs {..}) = case msg of
    InvestigatorDrawEnemy _ _ eid | eid == enemyId -> e <$ spawnAt eid "01134"
    UseCardAbility iid _ (EnemySource eid) 1 | eid == enemyId ->
      e <$ unshiftMessages
        [SpendClues 2 [iid], AddToVictory (EnemyTarget enemyId)]
    _ -> PeterWarren <$> runMessage msg attrs