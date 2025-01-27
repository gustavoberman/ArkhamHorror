module Arkham.Treachery.Cards.WallsClosingIn
  ( wallsClosingIn
  , WallsClosingIn(..)
  ) where

import Arkham.Prelude

import Arkham.Treachery.Cards qualified as Cards
import Arkham.Classes
import Arkham.Id
import Arkham.Message
import Arkham.Query
import Arkham.Scenario.Deck
import Arkham.SkillType
import Arkham.Target
import Arkham.Treachery.Attrs
import Arkham.Treachery.Runner

newtype WallsClosingIn = WallsClosingIn TreacheryAttrs
  deriving anyclass (IsTreachery, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

wallsClosingIn :: TreacheryCard WallsClosingIn
wallsClosingIn = treachery WallsClosingIn Cards.wallsClosingIn

instance TreacheryRunner env => RunMessage env WallsClosingIn where
  runMessage msg t@(WallsClosingIn attrs) = case msg of
    Revelation iid source | isSource attrs source -> do
      shroud <- fmap unShroud . getCount =<< getId @LocationId iid
      t <$ push (RevelationSkillTest iid source SkillWillpower shroud)
    FailedSkillTest iid _ source SkillTestInitiatorTarget{} _ n
      | isSource attrs source -> do

        t <$ push
          (chooseOne
            iid
            [ Label
              ("Take " <> tshow n <> " horror")
              [InvestigatorAssignDamage iid source DamageAny 0 n]
            , Label
              "Randomly choose 1 enemy from among the set-aside Monster enemies and place it beneath the act deck without looking at it"
              [DrawRandomFromScenarioDeck iid MonstersDeck (toTarget attrs) 1]
            ]
          )
    DrewFromScenarioDeck _ _ target cards | isTarget attrs target ->
      t <$ push (PlaceUnderneath ActDeckTarget cards)
    _ -> WallsClosingIn <$> runMessage msg attrs
