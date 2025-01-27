module Arkham.Treachery.Cards.DreamsOfRlyeh
  ( DreamsOfRlyeh(..)
  , dreamsOfRlyeh
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Treachery.Cards qualified as Cards
import Arkham.Classes
import Arkham.Cost
import Arkham.Criteria
import Arkham.Message
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target
import Arkham.Treachery.Attrs
import Arkham.Treachery.Helpers
import Arkham.Treachery.Runner

newtype DreamsOfRlyeh = DreamsOfRlyeh TreacheryAttrs
  deriving anyclass IsTreachery
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

dreamsOfRlyeh :: TreacheryCard DreamsOfRlyeh
dreamsOfRlyeh = treachery DreamsOfRlyeh Cards.dreamsOfRlyeh

instance HasModifiersFor env DreamsOfRlyeh where
  getModifiersFor _ (InvestigatorTarget iid) (DreamsOfRlyeh attrs) =
    pure $ toModifiers attrs $ if treacheryOnInvestigator iid attrs
      then [SkillModifier SkillWillpower (-1), SanityModifier (-1)]
      else []
  getModifiersFor _ _ _ = pure []

instance HasAbilities DreamsOfRlyeh where
  getAbilities (DreamsOfRlyeh a) =
    [ restrictedAbility a 1 OnSameLocation $ ActionAbility Nothing $ ActionCost
        1
    ]

instance TreacheryRunner env => RunMessage env DreamsOfRlyeh where
  runMessage msg t@(DreamsOfRlyeh attrs@TreacheryAttrs {..}) = case msg of
    Revelation iid source | isSource attrs source ->
      t <$ push (AttachTreachery treacheryId (InvestigatorTarget iid))
    UseCardAbility iid source _ 1 _ | isSource attrs source -> t <$ push
      (BeginSkillTest
        iid
        source
        (InvestigatorTarget iid)
        Nothing
        SkillWillpower
        3
      )
    PassedSkillTest _ _ source SkillTestInitiatorTarget{} _ _
      | isSource attrs source -> t <$ push (Discard $ toTarget attrs)
    _ -> DreamsOfRlyeh <$> runMessage msg attrs
