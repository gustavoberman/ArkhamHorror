module Arkham.Event.Cards.UncageTheSoul
  ( uncageTheSoul
  , UncageTheSoul(..)
  ) where

import Arkham.Prelude

import Arkham.Event.Cards qualified as Cards
import Arkham.Card
import Arkham.Classes
import Arkham.Event.Attrs
import Arkham.Game.Helpers
import Arkham.Matcher hiding (PlayCard)
import Arkham.Message
import Arkham.Query
import Arkham.Source
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Trait
import Arkham.Window (Window(..))
import Arkham.Window qualified as Window

newtype UncageTheSoul = UncageTheSoul EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

uncageTheSoul :: EventCard UncageTheSoul
uncageTheSoul = event UncageTheSoul Cards.uncageTheSoul

instance CanCheckPlayable env => RunMessage env UncageTheSoul where
  runMessage msg e@(UncageTheSoul attrs) = case msg of
    InvestigatorPlayEvent iid eid _ _ _ | eid == toId attrs -> do
      let
        windows' = map
          (Window Timing.When)
          [Window.DuringTurn iid, Window.NonFast, Window.FastPlayerWindow]
      availableResources <- unResourceCount <$> getCount iid
      results <- selectList
        (InHandOf You <> BasicCardMatch
          (CardWithOneOf [CardWithTrait Spell, CardWithTrait Ritual])
        )
      cards <- filterM
        (getIsPlayableWithResources
          iid
          (InvestigatorSource iid)
          (availableResources + 3)
          UnpaidCost
          windows'
        )
        results
      e <$ pushAll
        [ chooseOne
          iid
          [ TargetLabel
              (CardIdTarget $ toCardId c)
              [ CreateEffect
                (toCardCode attrs)
                Nothing
                (toSource attrs)
                (CardIdTarget $ toCardId c)
              , PayCardCost iid (toCardId c)
              , PlayCard iid (toCardId c) Nothing False
              ]
          | c <- cards
          ]
        , Discard (toTarget attrs)
        ]
    _ -> UncageTheSoul <$> runMessage msg attrs
