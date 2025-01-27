module Arkham.Event.Cards.Backstab where

import Arkham.Prelude

import Arkham.Event.Cards qualified as Cards
import Arkham.Action
import Arkham.Classes
import Arkham.Event.Attrs
import Arkham.Event.Helpers
import Arkham.Message
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Source
import Arkham.Target

newtype Backstab = Backstab EventAttrs
  deriving anyclass (IsEvent, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

backstab :: EventCard Backstab
backstab = event Backstab Cards.backstab

instance HasModifiersFor env Backstab where
  getModifiersFor (SkillTestSource _ _ source (Just Fight)) (InvestigatorTarget _) (Backstab attrs)
    = pure $ toModifiers attrs [ DamageDealt 2 | isSource attrs source ]
  getModifiersFor _ _ _ = pure []

instance HasQueue env => RunMessage env Backstab where
  runMessage msg e@(Backstab attrs@EventAttrs {..}) = case msg of
    InvestigatorPlayEvent iid eid _ _ _ | eid == eventId -> do
      e <$ pushAll
        [ ChooseFightEnemy iid (EventSource eid) Nothing SkillAgility mempty False
        , Discard (EventTarget eid)
        ]
    _ -> Backstab <$> runMessage msg attrs
