module Arkham.Enemy.Cards.SeekerOfCarcosa
  ( seekerOfCarcosa
  , SeekerOfCarcosa(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Classes
import Arkham.Enemy.Cards qualified as Cards
import Arkham.Enemy.Runner
import Arkham.Matcher
import Arkham.Message
import Arkham.Phase
import Arkham.Query
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype SeekerOfCarcosa = SeekerOfCarcosa EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

seekerOfCarcosa :: EnemyCard SeekerOfCarcosa
seekerOfCarcosa = enemyWith
  SeekerOfCarcosa
  Cards.seekerOfCarcosa
  (2, Static 3, 2)
  (0, 1)
  (spawnAtL ?~ EmptyLocation <> LocationWithTitle "Historical Society")

instance HasAbilities SeekerOfCarcosa where
  getAbilities (SeekerOfCarcosa attrs) = withBaseAbilities
    attrs
    [ mkAbility attrs 1 $ ForcedAbility $ PhaseEnds Timing.When $ PhaseIs
        MythosPhase
    ]

instance EnemyRunner env => RunMessage env SeekerOfCarcosa where
  runMessage msg e@(SeekerOfCarcosa attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      case enemyLocation attrs of
        Nothing -> pure e
        Just loc -> do
          clueCount <- unClueCount <$> getCount loc
          e <$ pushAll
            (if clueCount > 0
              then
                [ RemoveClues (LocationTarget loc) 1
                , PlaceClues (toTarget attrs) 1
                ]
              else [PlaceDoom (toTarget attrs) 1]
            )
    _ -> SeekerOfCarcosa <$> runMessage msg attrs
