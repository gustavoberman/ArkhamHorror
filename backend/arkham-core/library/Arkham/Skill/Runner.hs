module Arkham.Skill.Runner where

import Arkham.Prelude

import Arkham.Classes
import Arkham.Id
import Arkham.Matcher
import Arkham.Query
import Arkham.SkillTest
import Arkham.Source
import Arkham.Trait

type SkillRunner env
  = ( HasQueue env
    , Query ExtendedCardMatcher env
    , HasSet ConnectedLocationId env LocationId
    , HasSet BlockedLocationId env ()
    , HasSet EnemyId env InvestigatorId
    , HasSet Trait env Source
    , HasId LocationId env InvestigatorId
    , HasModifiersFor env ()
    , HasSkillTest env
    , HasCount DamageCount env InvestigatorId
    , HasId (Maybe OwnerId) env AssetId
    , HasId OwnerId env EventId
    , HasId OwnerId env SkillId
    , Query InvestigatorMatcher env
    )