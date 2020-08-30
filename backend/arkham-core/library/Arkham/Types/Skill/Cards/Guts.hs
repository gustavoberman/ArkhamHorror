{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Skill.Cards.Guts where

import ClassyPrelude

import Arkham.Json
import Arkham.Types.Classes
import Arkham.Types.InvestigatorId
import Arkham.Types.Message
import Arkham.Types.Skill.Attrs
import Arkham.Types.Skill.Runner
import Arkham.Types.SkillId

newtype Guts = Guts Attrs
  deriving newtype (Show, ToJSON, FromJSON)

guts :: InvestigatorId -> SkillId -> Guts
guts iid uuid = Guts $ baseAttrs iid uuid "01089"

instance HasActions env investigator Guts where
  getActions i window (Guts attrs) = getActions i window attrs

instance (SkillRunner env) => RunMessage env Guts where
  runMessage msg s@(Guts attrs@Attrs {..}) = case msg of
    PassedSkillTest{} ->
      s <$ unshiftMessage (AddOnSuccess (DrawCards skillOwner 1 False))
    _ -> Guts <$> runMessage msg attrs