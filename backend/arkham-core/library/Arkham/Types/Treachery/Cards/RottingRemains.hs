{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Treachery.Cards.RottingRemains where

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

newtype RottingRemains = RottingRemains Attrs
  deriving newtype (Show, ToJSON, FromJSON)

rottingRemains :: TreacheryId -> RottingRemains
rottingRemains uuid = RottingRemains $ baseAttrs uuid "01163"

instance HasActions env investigator RottingRemains where
  getActions i window (RottingRemains attrs) = getActions i window attrs

instance (TreacheryRunner env) => RunMessage env RottingRemains where
  runMessage msg (RottingRemains attrs@Attrs {..}) = case msg of
    Revelation iid tid | tid == treacheryId -> do
      unshiftMessages
        [ RevelationSkillTest
          iid
          (TreacherySource treacheryId)
          SkillWillpower
          3
          []
          [HorrorPerPointOfFailure iid]
        , Discard (TreacheryTarget tid)
        ]
      RottingRemains <$> runMessage msg attrs
    _ -> RottingRemains <$> runMessage msg attrs
