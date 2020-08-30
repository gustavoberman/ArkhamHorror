{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Skill.Cards.Overpower where

import ClassyPrelude

import Arkham.Json
import Arkham.Types.Classes
import Arkham.Types.InvestigatorId
import Arkham.Types.Message
import Arkham.Types.Skill.Attrs
import Arkham.Types.Skill.Runner
import Arkham.Types.SkillId

newtype Overpower = Overpower Attrs
  deriving newtype (Show, ToJSON, FromJSON)

overpower :: InvestigatorId -> SkillId -> Overpower
overpower iid uuid = Overpower $ baseAttrs iid uuid "01091"

instance HasActions env investigator Overpower where
  getActions i window (Overpower attrs) = getActions i window attrs

instance (SkillRunner env) => RunMessage env Overpower where
  runMessage msg s@(Overpower attrs@Attrs {..}) = case msg of
    PassedSkillTest{} ->
      s <$ unshiftMessage (AddOnSuccess (DrawCards skillOwner 1 False))
    _ -> Overpower <$> runMessage msg attrs