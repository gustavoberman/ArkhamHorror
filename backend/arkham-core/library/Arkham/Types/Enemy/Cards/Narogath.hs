module Arkham.Types.Enemy.Cards.Narogath
  ( narogath
  , Narogath(..)
  ) where

import Arkham.Prelude

import Arkham.Enemy.Cards qualified as Cards
import Arkham.Types.Action
import Arkham.Types.Classes
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Id
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.Prey
import Arkham.Types.Query
import Arkham.Types.Target
import Arkham.Types.Trait
import Arkham.Types.Trait qualified as Trait

newtype Narogath = Narogath EnemyAttrs
  deriving anyclass IsEnemy
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

narogath :: EnemyCard Narogath
narogath = enemyWith
  Narogath
  Cards.narogath
  (3, Static 4, 3)
  (1, 2)
  (preyL .~ NearestToEnemyWithTrait Trait.Cultist)

instance (HasSet InvestigatorId env LocationId, HasSet ConnectedLocationId env LocationId) => HasModifiersFor env Narogath where
  getModifiersFor _ (InvestigatorTarget iid) (Narogath a@EnemyAttrs {..})
    | spawned a = do
      connectedLocationIds <- map unConnectedLocationId
        <$> getSetList enemyLocation
      iids <- concat <$> for (enemyLocation : connectedLocationIds) getSetList
      pure $ toModifiers
        a
        [ CannotTakeAction (EnemyAction Parley [Cultist])
        | not enemyExhausted && iid `elem` iids
        ]
  getModifiersFor _ _ _ = pure []

instance (EnemyRunner env) => RunMessage env Narogath where
  runMessage msg (Narogath attrs@EnemyAttrs {..}) = case msg of
    EnemySpawnEngagedWithPrey eid | eid == enemyId -> do
      playerCount <- unPlayerCount <$> getCount ()
      Narogath
        <$> runMessage msg (attrs & healthL %~ fmap (+ (3 * playerCount)))
    _ -> Narogath <$> runMessage msg attrs
