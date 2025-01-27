module Arkham.Classes.Entity (
  module Arkham.Classes.Entity,
  module X,
) where

import Arkham.Prelude hiding (to)

import Arkham.Classes.Entity.Source as X
import Arkham.Target
import Arkham.Token

class Entity a where
  type EntityId a
  type EntityAttrs a
  toId :: a -> EntityId a
  toAttrs :: a -> EntityAttrs a

class TargetEntity a where
  toTarget :: a -> Target
  isTarget :: a -> Target -> Bool
  isTarget = (==) . toTarget

instance TargetEntity Target where
  toTarget = id
  isTarget = (==)

instance Entity a => Entity (a `With` b) where
  type EntityId (a `With` b) = EntityId a
  type EntityAttrs (a `With` b) = EntityAttrs a
  toId (a `With` _) = toId a
  toAttrs (a `With` _) = toAttrs a

instance TargetEntity a => TargetEntity (a `With` b) where
  toTarget (a `With` _) = toTarget a
  isTarget (a `With` _) = isTarget a

insertEntity ::
  (Entity v, EntityId v ~ k, Eq k, Hashable k) =>
  v ->
  HashMap k v ->
  HashMap k v
insertEntity a = insertMap (toId a) a

instance TargetEntity Token where
  toTarget = TokenTarget
  isTarget t (TokenTarget t') = t == t'
  isTarget _ _ = False
