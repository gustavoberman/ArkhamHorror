module Arkham.Location.Cards.MainPath
  ( MainPath(..)
  , mainPath
  ) where

import Arkham.Prelude

import Arkham.Location.Cards qualified as Cards (mainPath)
import Arkham.Classes
import Arkham.GameValue
import Arkham.Location.Runner
import Arkham.Matcher
import Arkham.Trait

newtype MainPath = MainPath LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

mainPath :: LocationCard MainPath
mainPath = locationWith
  MainPath
  Cards.mainPath
  2
  (Static 0)
  Squiggle
  [Square, Plus]
  (revealedConnectedMatchersL <>~ [LocationWithTrait Woods])

instance HasAbilities MainPath where
  getAbilities (MainPath a) = withResignAction a []

instance LocationRunner env => RunMessage env MainPath where
  runMessage msg (MainPath attrs) = MainPath <$> runMessage msg attrs
