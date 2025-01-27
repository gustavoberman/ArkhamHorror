module Arkham.Event.Cards.Barricade
  ( barricade
  , Barricade(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Event.Cards qualified as Cards
import Arkham.Classes
import Arkham.Event.Attrs
import Arkham.Event.Helpers
import Arkham.Event.Runner
import Arkham.Matcher
import Arkham.Message
import Arkham.Modifier
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype Barricade = Barricade EventAttrs
  deriving anyclass IsEvent
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

barricade :: EventCard Barricade
barricade = event Barricade Cards.barricade

instance HasModifiersFor env Barricade where
  getModifiersFor _ (LocationTarget lid) (Barricade attrs) = pure $ toModifiers
    attrs
    [ CannotBeEnteredByNonElite
    | LocationTarget lid `elem` eventAttachedTarget attrs
    ]
  getModifiersFor _ _ _ = pure []

instance HasAbilities Barricade where
  getAbilities (Barricade x) = case eventAttachedTarget x of
    Just (LocationTarget lid) ->
      [ mkAbility x 1 $ ForcedAbility $ Leaves Timing.When You $ LocationWithId
          lid
      ]
    _ -> []

instance EventRunner env => RunMessage env Barricade where
  runMessage msg e@(Barricade attrs) = case msg of
    InvestigatorPlayEvent iid eid _ _ _ | eid == toId attrs -> do
      lid <- getId iid
      e <$ push (AttachEvent eid (LocationTarget lid))
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      e <$ push (Discard $ toTarget attrs)
    _ -> Barricade <$> runMessage msg attrs
