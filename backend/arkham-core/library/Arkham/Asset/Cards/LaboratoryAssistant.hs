module Arkham.Asset.Cards.LaboratoryAssistant
  ( LaboratoryAssistant(..)
  , laboratoryAssistant
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Matcher
import Arkham.Modifier
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype LaboratoryAssistant = LaboratoryAssistant AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

laboratoryAssistant :: AssetCard LaboratoryAssistant
laboratoryAssistant = ally LaboratoryAssistant Cards.laboratoryAssistant (1, 2)

instance HasModifiersFor env LaboratoryAssistant where
  getModifiersFor _ (InvestigatorTarget iid) (LaboratoryAssistant attrs) =
    pure $ toModifiers attrs [ HandSize 2 | ownedBy attrs iid ]
  getModifiersFor _ _ _ = pure []

instance HasAbilities LaboratoryAssistant where
  getAbilities (LaboratoryAssistant x) =
    [ restrictedAbility x 1 OwnsThis
        $ ReactionAbility
            (AssetEntersPlay Timing.When (AssetWithId $ toId x))
            Free
    ]

instance (AssetRunner env) => RunMessage env LaboratoryAssistant where
  runMessage msg a@(LaboratoryAssistant attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      a <$ push (DrawCards iid 2 False)
    _ -> LaboratoryAssistant <$> runMessage msg attrs
