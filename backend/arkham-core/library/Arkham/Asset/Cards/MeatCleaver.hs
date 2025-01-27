module Arkham.Asset.Cards.MeatCleaver
  ( meatCleaver
  , MeatCleaver(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Action qualified as Action
import Arkham.Asset.Runner
import Arkham.Card.CardCode
import Arkham.Cost
import Arkham.Criteria
import Arkham.Modifier
import Arkham.Query
import Arkham.SkillType
import Arkham.Target

newtype MeatCleaver = MeatCleaver AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

meatCleaver :: AssetCard MeatCleaver
meatCleaver = asset MeatCleaver Cards.meatCleaver

instance HasAbilities MeatCleaver where
  getAbilities (MeatCleaver attrs) =
    [ restrictedAbility attrs 1 OwnsThis
        $ ActionAbility (Just Action.Fight)
        $ Costs [ActionCost 1, UpTo 1 (HorrorCost (toSource attrs) YouTarget 1)]
    ]

paidHorror :: Payment -> Bool
paidHorror (HorrorPayment _) = True
paidHorror (Payments ps) = any paidHorror ps
paidHorror _ = False

instance AssetRunner env => RunMessage env MeatCleaver where
  runMessage msg a@(MeatCleaver attrs) = case msg of
    UseCardAbility iid source _ 1 payments | isSource attrs source -> do
      remainingSanity <- unRemainingSanity <$> getCount iid
      a <$ pushAll
        [ skillTestModifiers
          attrs
          (InvestigatorTarget iid)
          ([SkillModifier SkillCombat (if remainingSanity <= 3 then 2 else 1)]
          <> [ DamageDealt 1 | paidHorror payments ]
          )
        , CreateEffect
          (toCardCode attrs)
          Nothing
          source
          (InvestigatorTarget iid)
        , ChooseFightEnemy iid source Nothing SkillCombat mempty False
        ]
    _ -> MeatCleaver <$> runMessage msg attrs
