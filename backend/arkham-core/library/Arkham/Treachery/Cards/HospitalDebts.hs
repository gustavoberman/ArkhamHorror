module Arkham.Treachery.Cards.HospitalDebts
  ( HospitalDebts(..)
  , hospitalDebts
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Classes
import Arkham.Cost
import Arkham.Criteria
import Arkham.GameValue
import Arkham.Matcher
import Arkham.Message hiding ( InvestigatorEliminated )
import Arkham.Modifier
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Treachery.Attrs
import Arkham.Treachery.Cards qualified as Cards
import Arkham.Treachery.Helpers
import Arkham.Treachery.Runner

newtype HospitalDebts = HospitalDebts TreacheryAttrs
  deriving anyclass IsTreachery
  deriving newtype (Show, Eq, Generic, ToJSON, FromJSON, Entity)

hospitalDebts :: TreacheryCard HospitalDebts
hospitalDebts =
  treacheryWith HospitalDebts Cards.hospitalDebts (resourcesL ?~ 0)

instance HasModifiersFor env HospitalDebts where
  getModifiersFor _ (InvestigatorTarget iid) (HospitalDebts attrs) = do
    let resources' = fromJustNote "must be set" $ treacheryResources attrs
    pure $ toModifiers
      attrs
      [ XPModifier (-2) | treacheryOnInvestigator iid attrs && resources' < 6 ]
  getModifiersFor _ _ _ = pure []

instance HasAbilities HospitalDebts where
  getAbilities (HospitalDebts a) =
    (limitedAbility (PlayerLimit PerRound 2)
      $ restrictedAbility
          a
          1
          (OnSameLocation <> InvestigatorExists
            (You <> InvestigatorWithResources (AtLeast $ Static 1))
          )
      $ FastAbility Free
      )
      : [ restrictedAbility a 2 (ResourcesOnThis $ LessThan $ Static 6)
          $ ForcedAbility
          $ OrWindowMatcher
              [ GameEnds Timing.When
              , InvestigatorEliminated Timing.When (InvestigatorWithId iid)
              ]
        | iid <- maybeToList (treacheryOwner a)
        ]

instance TreacheryRunner env => RunMessage env HospitalDebts where
  runMessage msg t@(HospitalDebts attrs) = case msg of
    Revelation iid source | isSource attrs source ->
      t <$ push (AttachTreachery (toId attrs) (InvestigatorTarget iid))
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      t <$ pushAll [SpendResources iid 1, PlaceResources (toTarget attrs) 1]
    _ -> HospitalDebts <$> runMessage msg attrs
