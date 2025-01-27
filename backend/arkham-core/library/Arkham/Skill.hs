{-# LANGUAGE TemplateHaskell #-}

module Arkham.Skill (
  module Arkham.Skill,
) where

import Arkham.Prelude

import Data.Aeson.TH
import Arkham.Card
import Arkham.Classes
import Arkham.Id
import Arkham.Name
import Arkham.Skill.Attrs
import Arkham.Skill.Runner
import Arkham.Skill.Skills

$(buildEntity "Skill")

$(deriveJSON defaultOptions ''Skill)

createSkill :: IsCard a => a -> InvestigatorId -> Skill
createSkill a iid = lookupSkill (toCardCode a) iid (SkillId $ toCardId a)

instance HasCardCode Skill where
  toCardCode = toCardCode . toAttrs

instance HasCardDef Skill where
  toCardDef = toCardDef . toAttrs

instance HasAbilities Skill where
  getAbilities = $(entityF "Skill" "getAbilities")

instance SkillRunner env => RunMessage env Skill where
  runMessage = $(entityRunMessage "Skill")

instance HasModifiersFor env Skill where
  getModifiersFor = $(entityF2 "Skill" "getModifiersFor")

instance Entity Skill where
  type EntityId Skill = SkillId
  type EntityAttrs Skill = SkillAttrs
  toId = toId . toAttrs
  toAttrs = $(entityF "Skill" "toAttrs")

instance Named Skill where
  toName = toName . toAttrs

instance TargetEntity Skill where
  toTarget = toTarget . toAttrs
  isTarget = isTarget . toAttrs

instance SourceEntity Skill where
  toSource = toSource . toAttrs
  isSource = isSource . toAttrs

instance IsCard Skill where
  toCardId = toCardId . toAttrs
  toCardOwner = toCardOwner . toAttrs

lookupSkill :: CardCode -> (InvestigatorId -> SkillId -> Skill)
lookupSkill cardCode =
  fromJustNote ("Unknown skill: " <> show cardCode) $ lookup cardCode allSkills

allSkills :: HashMap CardCode (InvestigatorId -> SkillId -> Skill)
allSkills =
  mapFromList $
    map
      (cbCardCode &&& (curry . cbCardBuilder))
      $(buildEntityLookupList "Skill")

ownerOfSkill :: Skill -> InvestigatorId
ownerOfSkill = skillOwner . toAttrs
