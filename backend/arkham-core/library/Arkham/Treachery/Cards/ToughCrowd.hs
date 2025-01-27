module Arkham.Treachery.Cards.ToughCrowd
  ( toughCrowd
  , ToughCrowd(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Treachery.Cards qualified as Cards
import Arkham.Action
import Arkham.Classes
import Arkham.Matcher
import Arkham.Message
import Arkham.Modifier
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Treachery.Attrs
import Arkham.Treachery.Helpers
import Arkham.Treachery.Runner

newtype ToughCrowd = ToughCrowd TreacheryAttrs
  deriving anyclass IsTreachery
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

toughCrowd :: TreacheryCard ToughCrowd
toughCrowd = treachery ToughCrowd Cards.toughCrowd

instance HasModifiersFor env ToughCrowd where
  getModifiersFor _ (InvestigatorTarget _) (ToughCrowd a) =
    pure $ toModifiers a [ActionCostOf (IsAction Parley) 1]
  getModifiersFor _ _ _ = pure []

instance HasAbilities ToughCrowd where
  getAbilities (ToughCrowd a) =
    [mkAbility a 1 $ ForcedAbility $ RoundEnds Timing.When]

instance TreacheryRunner env => RunMessage env ToughCrowd where
  runMessage msg t@(ToughCrowd attrs) = case msg of
    Revelation _ source | isSource attrs source -> do
      agendaId <- fromJustNote "missing agenda" . headMay <$> getSetList ()
      t <$ push (AttachTreachery (toId attrs) (AgendaTarget agendaId))
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      t <$ push (Discard $ toTarget attrs)
    _ -> ToughCrowd <$> runMessage msg attrs
