module Arkham.Types.Asset.Cards.ArchaicGlyphsGuidingStones3
  ( archaicGlyphsGuidingStones3
  , ArchaicGlyphsGuidingStones3(..)
  ) where

import Arkham.Prelude

import Arkham.Asset.Cards qualified as Cards
import Arkham.Types.Ability
import Arkham.Types.Action qualified as Action
import Arkham.Types.Asset.Attrs
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.Id
import Arkham.Types.Query
import Arkham.Types.SkillType
import Arkham.Types.Target

newtype ArchaicGlyphsGuidingStones3 = ArchaicGlyphsGuidingStones3 AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

instance HasAbilities ArchaicGlyphsGuidingStones3 where
  getAbilities (ArchaicGlyphsGuidingStones3 a) =
    [ restrictedAbility a 1 OwnsThis
        $ ActionAbility (Just Action.Investigate)
        $ Costs [ActionCost 1, UseCost (toId a) Charge 1]
    ]

archaicGlyphsGuidingStones3 :: AssetCard ArchaicGlyphsGuidingStones3
archaicGlyphsGuidingStones3 =
  asset ArchaicGlyphsGuidingStones3 Cards.archaicGlyphsGuidingStones3

instance AssetRunner env => RunMessage env ArchaicGlyphsGuidingStones3 where
  runMessage msg a@(ArchaicGlyphsGuidingStones3 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      lid <- getId @LocationId iid
      a <$ pushAll
        [ Investigate
          iid
          lid
          (toSource attrs)
          (Just $ toTarget attrs)
          SkillIntellect
          False
        , Discard (toTarget attrs)
        ]
    Successful (Action.Investigate, LocationTarget lid) iid _ target n
      | isTarget attrs target -> do
        clueCount <- unClueCount <$> getCount lid
        let
          additional = n `div` 2
          amount = min clueCount (1 + additional)
        a <$ push
          (InvestigatorDiscoverClues iid lid amount (Just Action.Investigate))
    _ -> ArchaicGlyphsGuidingStones3 <$> runMessage msg attrs