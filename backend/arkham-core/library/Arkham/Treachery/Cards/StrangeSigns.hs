module Arkham.Treachery.Cards.StrangeSigns
  ( strangeSigns
  , StrangeSigns(..)
  ) where

import Arkham.Prelude

import Arkham.Treachery.Cards qualified as Cards
import Arkham.Classes
import Arkham.Game.Helpers
import Arkham.Message
import Arkham.SkillType
import Arkham.Target
import Arkham.Treachery.Attrs
import Arkham.Treachery.Runner

newtype StrangeSigns = StrangeSigns TreacheryAttrs
  deriving anyclass (IsTreachery, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

strangeSigns :: TreacheryCard StrangeSigns
strangeSigns = treachery StrangeSigns Cards.strangeSigns

instance TreacheryRunner env => RunMessage env StrangeSigns where
  runMessage msg t@(StrangeSigns attrs) = case msg of
    Revelation iid source | isSource attrs source ->
      t <$ push (RevelationSkillTest iid source SkillIntellect 3)
    FailedSkillTest iid _ source SkillTestInitiatorTarget{} _ _
      | isSource attrs source -> do
        playerCount <- getPlayerCount
        lid <- getId iid
        let clueCount = if playerCount == 3 || playerCount == 4 then 2 else 1
        t <$ push (PlaceClues (LocationTarget lid) clueCount)
    _ -> StrangeSigns <$> runMessage msg attrs
