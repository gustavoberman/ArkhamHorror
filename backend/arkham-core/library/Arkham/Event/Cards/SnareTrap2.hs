module Arkham.Event.Cards.SnareTrap2
  ( snareTrap2
  , SnareTrap2(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Event.Cards qualified as Cards
import Arkham.Classes
import Arkham.Event.Attrs
import Arkham.Event.Runner
import Arkham.Matcher
import Arkham.Message
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Window (Window(..))
import Arkham.Window qualified as Window

newtype SnareTrap2 = SnareTrap2 EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

snareTrap2 :: EventCard SnareTrap2
snareTrap2 = event SnareTrap2 Cards.snareTrap2

instance HasAbilities SnareTrap2 where
  getAbilities (SnareTrap2 a) = case eventAttachedTarget a of
    Just (LocationTarget lid) ->
      [ mkAbility a 1 $ ForcedAbility $ EnemyEnters
          Timing.After
          (LocationWithId lid)
          NonEliteEnemy
      ]
    Just (EnemyTarget eid) ->
      [ mkAbility a 2
          $ ForcedAbility
          $ EnemyWouldReady Timing.When
          $ EnemyWithId eid
      ]
    _ -> []

instance EventRunner env => RunMessage env SnareTrap2 where
  runMessage msg e@(SnareTrap2 attrs) = case msg of
    InvestigatorPlayEvent iid eid _ _ _ | eid == toId attrs -> do
      lid <- getId iid
      e <$ push (AttachEvent eid (LocationTarget lid))
    UseCardAbility _ source [Window _ (Window.EnemyEnters enemyId _)] 1 _
      | isSource attrs source -> do
        iids <- selectList $ InvestigatorEngagedWith (EnemyWithId enemyId)
        e <$ pushAll
          (Exhaust (EnemyTarget enemyId)
          : map (`DisengageEnemy` enemyId) iids
          <> [AttachEvent (toId attrs) (EnemyTarget enemyId)]
          )
    UseCardAbility _ source [Window _ (Window.WouldReady target)] 2 _
      | isSource attrs source -> e <$ replaceMessageMatching
        (\case
          Ready t -> t == target
          _ -> False
        )
        (const [Discard $ toTarget attrs])
    _ -> SnareTrap2 <$> runMessage msg attrs
