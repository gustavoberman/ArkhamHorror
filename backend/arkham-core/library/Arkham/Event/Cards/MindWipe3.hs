module Arkham.Event.Cards.MindWipe3 where

import Arkham.Prelude

import Arkham.Event.Cards qualified as Cards
import Arkham.Classes
import Arkham.Event.Attrs
import Arkham.Event.Runner
import Arkham.Id
import Arkham.Message
import Arkham.Target
import Arkham.Trait

newtype MindWipe3 = MindWipe3 EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

mindWipe3 :: EventCard MindWipe3
mindWipe3 = event MindWipe3 Cards.mindWipe3

instance EventRunner env => RunMessage env MindWipe3 where
  runMessage msg e@(MindWipe3 attrs@EventAttrs {..}) = case msg of
    InvestigatorPlayEvent iid eid _ _ _ | eid == eventId -> do
      locationId <- getId @LocationId iid
      enemyIds <- getSetList locationId
      nonEliteEnemyIds <- flip filterM enemyIds $ \enemyId -> do
        notElem Elite <$> getSet enemyId
      if null nonEliteEnemyIds
        then e <$ push (Discard (EventTarget eventId))
        else e <$ pushAll
          [ chooseOne
            iid
            [ TargetLabel
                (EnemyTarget eid')
                [CreateEffect "" Nothing (toSource attrs) (EnemyTarget eid')]
            | eid' <- nonEliteEnemyIds
            ]
          , Discard (EventTarget eid)
          ]
    _ -> MindWipe3 <$> runMessage msg attrs
