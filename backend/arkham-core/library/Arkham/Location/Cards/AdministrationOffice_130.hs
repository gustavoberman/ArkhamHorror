module Arkham.Location.Cards.AdministrationOffice_130
  ( administrationOffice_130
  , AdministrationOffice_130(..)
  ) where

import Arkham.Prelude

import Arkham.Location.Cards qualified as Cards (administrationOffice_130)
import Arkham.Classes
import Arkham.GameValue
import Arkham.InvestigatorId
import Arkham.Location.Runner
import Arkham.Location.Helpers
import Arkham.Modifier
import Arkham.Query
import Arkham.Source

newtype AdministrationOffice_130 = AdministrationOffice_130 LocationAttrs
  deriving anyclass IsLocation
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

administrationOffice_130 :: LocationCard AdministrationOffice_130
administrationOffice_130 = location
  AdministrationOffice_130
  Cards.administrationOffice_130
  1
  (PerPlayer 1)
  Triangle
  [Square]

instance HasCount ResourceCount env InvestigatorId => HasModifiersFor env AdministrationOffice_130 where
  getModifiersFor (InvestigatorSource iid) target (AdministrationOffice_130 attrs)
    | isTarget attrs target
    = do
      resources <- unResourceCount <$> getCount iid
      pure $ toModifiers attrs [ CannotInvestigate | resources <= 4 ]
  getModifiersFor _ _ _ = pure []

instance LocationRunner env => RunMessage env AdministrationOffice_130 where
  runMessage msg (AdministrationOffice_130 attrs) =
    AdministrationOffice_130 <$> runMessage msg attrs
