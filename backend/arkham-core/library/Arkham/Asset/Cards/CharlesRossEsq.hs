module Arkham.Asset.Cards.CharlesRossEsq
  ( charlesRossEsq
  , CharlesRossEsq(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Card.CardCode
import Arkham.Card.CardType
import Arkham.Cost
import Arkham.Criteria
import Arkham.Id
import Arkham.Matcher
import Arkham.Modifier
import Arkham.Target
import Arkham.Trait

newtype CharlesRossEsq = CharlesRossEsq AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

charlesRossEsq :: AssetCard CharlesRossEsq
charlesRossEsq = ally CharlesRossEsq Cards.charlesRossEsq (1, 2)

instance HasId LocationId env AssetId => HasModifiersFor env CharlesRossEsq where
  getModifiersFor _ (InvestigatorTarget iid) (CharlesRossEsq attrs)
    | attrs `ownedBy` iid = do
      lid <- getId @LocationId (toId attrs)
      pure $ toModifiers
        attrs
        [ CanSpendResourcesOnCardFromInvestigator
            (InvestigatorAt $ LocationWithId lid)
            (CardWithType AssetType <> CardWithTrait Item)
        ]
  getModifiersFor _ _ _ = pure []

instance HasAbilities CharlesRossEsq where
  getAbilities (CharlesRossEsq attrs) =
    [ restrictedAbility attrs 1 OwnsThis $ FastAbility $ ExhaustCost $ toTarget
        attrs
    ]

instance AssetRunner env => RunMessage env CharlesRossEsq where
  runMessage msg a@(CharlesRossEsq attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      -- TODO: we may want to track the investigator instead of the asset
      a <$ push
        (CreateEffect (toCardCode attrs) Nothing source (toTarget attrs))
    _ -> CharlesRossEsq <$> runMessage msg attrs
