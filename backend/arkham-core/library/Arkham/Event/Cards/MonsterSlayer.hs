module Arkham.Event.Cards.MonsterSlayer
  ( monsterSlayer
  , MonsterSlayer(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Event.Cards as Cards
import Arkham.Classes
import Arkham.Event.Attrs
import Arkham.Event.Helpers
import Arkham.Event.Runner
import Arkham.Message
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target

newtype MonsterSlayer = MonsterSlayer EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

monsterSlayer :: EventCard MonsterSlayer
monsterSlayer = event MonsterSlayer Cards.monsterSlayer

instance EventRunner env => RunMessage env MonsterSlayer where
  runMessage msg e@(MonsterSlayer attrs) = case msg of
    InvestigatorPlayEvent iid eid _ _ _ | eid == toId attrs -> do
      e <$ pushAll
        [ skillTestModifier
          (toSource attrs)
          (InvestigatorTarget iid)
          (DamageDealt 1)
        , ChooseFightEnemy iid (toSource attrs) Nothing SkillCombat mempty False
        , Discard (toTarget attrs)
        ]
    _ -> MonsterSlayer <$> runMessage msg attrs
