module Arkham.Event.Cards.HeroicRescue
  ( heroicRescue
  , HeroicRescue(..)
  ) where

import Arkham.Prelude

import Arkham.Event.Cards qualified as Cards
import Arkham.Classes
import Arkham.DamageEffect
import Arkham.Event.Attrs
import Arkham.Message
import Arkham.Window (Window(..))
import Arkham.Window qualified as Window

newtype HeroicRescue = HeroicRescue EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

heroicRescue :: EventCard HeroicRescue
heroicRescue = event HeroicRescue Cards.heroicRescue

instance RunMessage env HeroicRescue where
  runMessage msg e@(HeroicRescue attrs) = case msg of
    InvestigatorPlayEvent iid eid _ [Window _ (Window.EnemyWouldAttack iid' eid')] _
      | eid == toId attrs
      -> do
        popMessageMatching_ \case
          CheckWindow _ windows -> flip
            any
            windows
            \case
              Window _ (Window.EnemyAttacks targetInvestigator targetEnemy) ->
                targetInvestigator == iid' && targetEnemy == eid'
              _ -> False
          _ -> False
        popMessageMatching_ \case
          After (PerformEnemyAttack targetInvestigator targetEnemy _) ->
            targetInvestigator == iid' && targetEnemy == eid'
          _ -> False
        replaceMessageMatching
          \case
            PerformEnemyAttack targetInvestigator targetEnemy _ ->
              targetInvestigator == iid' && targetEnemy == eid'
            _ -> False
          \case
            PerformEnemyAttack _ targetEnemy damageStrategy ->
              [ EnemyAttack iid targetEnemy damageStrategy
              , EnemyDamage
                targetEnemy
                iid
                (toSource attrs)
                NonAttackDamageEffect
                1
              ]
            _ -> error "Mismatched"
        e <$ pushAll [Discard (toTarget attrs)]
    _ -> HeroicRescue <$> runMessage msg attrs
