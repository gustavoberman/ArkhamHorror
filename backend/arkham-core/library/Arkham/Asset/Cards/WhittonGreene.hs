module Arkham.Asset.Cards.WhittonGreene
  ( whittonGreene
  , WhittonGreene(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Card.CardType
import Arkham.Cost
import Arkham.Criteria
import Arkham.Matcher
import Arkham.Matcher qualified as Matcher
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Trait

newtype WhittonGreene = WhittonGreene AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

whittonGreene :: AssetCard WhittonGreene
whittonGreene = ally WhittonGreene Cards.whittonGreene (2, 2)

instance HasAbilities WhittonGreene where
  getAbilities (WhittonGreene x) =
    [ restrictedAbility x 1 OwnsThis $ ReactionAbility
        (OrWindowMatcher
          [ Matcher.RevealLocation Timing.After You Anywhere
          , PutLocationIntoPlay Timing.After You Anywhere
          ]
        )
        (ExhaustCost $ toTarget x)
    ]

instance Query AssetMatcher env => HasModifiersFor env WhittonGreene where
  getModifiersFor _ (InvestigatorTarget iid) (WhittonGreene a) | ownedBy a iid =
    do
      active <- selectAny (AssetControlledBy (InvestigatorWithId iid) <> AssetOneOf [AssetWithTrait Tome, AssetWithTrait Relic])
      -- active <- (> 0) . unAssetCount <$> getCount (iid, [Tome, Relic])
      pure $ toModifiers a [ SkillModifier SkillIntellect 1 | active ]
  getModifiersFor _ _ _ = pure []

instance AssetRunner env => RunMessage env WhittonGreene where
  runMessage msg a@(WhittonGreene attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> a <$ push
      (Search
        iid
        source
        (InvestigatorTarget iid)
        [fromTopOfDeck 6]
        (CardWithType AssetType
        <> CardWithOneOf (map CardWithTrait [Tome, Relic])
        )
        (DrawFound iid 1)
      )
    _ -> WhittonGreene <$> runMessage msg attrs
