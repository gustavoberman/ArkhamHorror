module Arkham.Treachery.Cards.VastExpanse
  ( vastExpanse
  , VastExpanse(..)
  ) where

import Arkham.Prelude

import Arkham.Treachery.Cards qualified as Cards
import Arkham.Classes
import Arkham.Id
import Arkham.Message
import Arkham.SkillType
import Arkham.Target
import Arkham.Trait
import Arkham.Treachery.Attrs
import Arkham.Treachery.Runner

newtype VastExpanse = VastExpanse TreacheryAttrs
  deriving anyclass (IsTreachery, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

vastExpanse :: TreacheryCard VastExpanse
vastExpanse = treachery VastExpanse Cards.vastExpanse

instance TreacheryRunner env => RunMessage env VastExpanse where
  runMessage msg t@(VastExpanse attrs) = case msg of
    Revelation iid source | isSource attrs source -> do
      extradimensionalCount <- length
        <$> getSetList @LocationId [Extradimensional]
      let
        revelationMsg = if extradimensionalCount == 0
          then Surge iid source
          else BeginSkillTest
            iid
            source
            (InvestigatorTarget iid)
            Nothing
            SkillWillpower
            (min 5 extradimensionalCount)
      t <$ push revelationMsg
    FailedSkillTest iid _ source SkillTestInitiatorTarget{} _ n
      | isSource attrs source -> t
      <$ push (InvestigatorAssignDamage iid source DamageAny 0 n)
    _ -> VastExpanse <$> runMessage msg attrs
