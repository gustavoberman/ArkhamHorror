{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Treachery.Cards.GraspingHands where

import Arkham.Json
import Arkham.Types.Classes
import Arkham.Types.Message
import Arkham.Types.SkillType
import Arkham.Types.Source
import Arkham.Types.Target
import Arkham.Types.Treachery.Attrs
import Arkham.Types.Treachery.Runner
import Arkham.Types.TreacheryId
import ClassyPrelude

newtype GraspingHands = GraspingHands Attrs
  deriving newtype (Show, ToJSON, FromJSON)

graspingHands :: TreacheryId -> GraspingHands
graspingHands uuid = GraspingHands $ baseAttrs uuid "01162"

instance (TreacheryRunner env) => RunMessage env GraspingHands where
  runMessage msg t@(GraspingHands attrs@Attrs {..}) = case msg of
    RunTreachery iid tid | tid == treacheryId -> t <$ unshiftMessages
      [ RevelationSkillTest
        iid
        (TreacherySource treacheryId)
        SkillAgility
        3
        []
        [DamagePerPointOfFailure iid]
      , Discard (TreacheryTarget tid)
      ]
    _ -> GraspingHands <$> runMessage msg attrs