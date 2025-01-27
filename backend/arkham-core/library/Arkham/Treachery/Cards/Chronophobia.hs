module Arkham.Treachery.Cards.Chronophobia
  ( chronophobia
  , Chronophobia(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Treachery.Cards qualified as Cards
import Arkham.Classes
import Arkham.Cost
import Arkham.Criteria
import Arkham.Matcher
import Arkham.Message
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Treachery.Attrs
import Arkham.Treachery.Runner

newtype Chronophobia = Chronophobia TreacheryAttrs
  deriving anyclass (IsTreachery, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

chronophobia :: TreacheryCard Chronophobia
chronophobia = treachery Chronophobia Cards.chronophobia

instance HasAbilities Chronophobia where
  getAbilities (Chronophobia x) =
    [ restrictedAbility x 1 (InThreatAreaOf You) $ ForcedAbility $ TurnEnds
      Timing.When
      You
    , restrictedAbility x 2 OnSameLocation $ ActionAbility Nothing $ ActionCost
      2
    ]

instance TreacheryRunner env => RunMessage env Chronophobia where
  runMessage msg t@(Chronophobia attrs) = case msg of
    Revelation iid source | isSource attrs source ->
      t <$ push (AttachTreachery (toId attrs) $ InvestigatorTarget iid)
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      t <$ push (InvestigatorDirectDamage iid source 0 1)
    UseCardAbility _ source _ 2 _ | isSource attrs source ->
      t <$ push (Discard $ toTarget attrs)
    _ -> Chronophobia <$> runMessage msg attrs
