module Arkham.Act.Cards.TheStrangerThePathIsMine
  ( TheStrangerThePathIsMine(..)
  , theStrangerThePathIsMine
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Act.Cards qualified as Cards
import Arkham.Enemy.Cards qualified as Enemies
import Arkham.Scenarios.CurtainCall.Helpers
import Arkham.Act.Attrs
import Arkham.Act.Runner
import Arkham.Card
import Arkham.Classes
import Arkham.Matcher hiding (Discarded)
import Arkham.Message
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Token

newtype TheStrangerThePathIsMine = TheStrangerThePathIsMine ActAttrs
  deriving anyclass (IsAct, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

theStrangerThePathIsMine :: ActCard TheStrangerThePathIsMine
theStrangerThePathIsMine =
  act (2, A) TheStrangerThePathIsMine Cards.theStrangerThePathIsMine Nothing

instance HasAbilities TheStrangerThePathIsMine where
  getAbilities (TheStrangerThePathIsMine a) =
    [ mkAbility a 1
        $ Objective
        $ ForcedAbility
        $ EnemyWouldBeDiscarded Timing.When
        $ enemyIs Enemies.theManInThePallidMask
    ]

instance ActRunner env => RunMessage env TheStrangerThePathIsMine where
  runMessage msg a@(TheStrangerThePathIsMine attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      a <$ push (AdvanceAct (toId attrs) source)
    AdvanceAct aid _ | aid == toId attrs && onSide B attrs -> do
      theManInThePallidMask <- getTheManInThePallidMask
      moveTheManInThePalidMaskToLobbyInsteadOfDiscarding
      lid <- getId theManInThePallidMask
      card <- flipCard <$> genCard (toCardDef attrs)
      a <$ pushAll
        [ AddToken Tablet
        , AddToken Tablet
        , PlaceHorror (LocationTarget lid) 1
        , PlaceNextTo ActDeckTarget [card]
        , CreateEffect "03047b" Nothing (toSource attrs) (toTarget attrs)
        , AdvanceActDeck (actDeckId attrs) (toSource attrs)
        ]
    _ -> TheStrangerThePathIsMine <$> runMessage msg attrs