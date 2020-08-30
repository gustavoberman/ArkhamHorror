{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Skill.Cards.Perception where

import ClassyPrelude

import Arkham.Json
import Arkham.Types.Classes
import Arkham.Types.InvestigatorId
import Arkham.Types.Message
import Arkham.Types.Skill.Attrs
import Arkham.Types.Skill.Runner
import Arkham.Types.SkillId

newtype Perception = Perception Attrs
  deriving newtype (Show, ToJSON, FromJSON)

perception :: InvestigatorId -> SkillId -> Perception
perception iid uuid = Perception $ baseAttrs iid uuid "01090"

instance HasActions env investigator Perception where
  getActions i window (Perception attrs) = getActions i window attrs

instance (SkillRunner env) => RunMessage env Perception where
  runMessage msg s@(Perception attrs@Attrs {..}) = case msg of
    PassedSkillTest {} ->
      s <$ unshiftMessage (AddOnSuccess (DrawCards skillOwner 1 False))
    _ -> Perception <$> runMessage msg attrs