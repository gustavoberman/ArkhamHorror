module Arkham.Asset.Cards.EarlSawyer
  ( earlSawyer
  , EarlSawyer(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Matcher
import Arkham.Matcher qualified as Matcher
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype EarlSawyer = EarlSawyer AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

earlSawyer :: AssetCard EarlSawyer
earlSawyer = ally EarlSawyer Cards.earlSawyer (3, 2)

instance HasAbilities EarlSawyer where
  getAbilities (EarlSawyer attrs) =
    [ restrictedAbility attrs 1 OwnsThis $ ReactionAbility
        (Matcher.EnemyEvaded Timing.After You AnyEnemy)
        (ExhaustCost $ toTarget attrs)
    ]

instance HasModifiersFor env EarlSawyer where
  getModifiersFor _ (InvestigatorTarget iid) (EarlSawyer a) =
    pure [ toModifier a (SkillModifier SkillAgility 1) | ownedBy a iid ]
  getModifiersFor _ _ _ = pure []

instance AssetRunner env => RunMessage env EarlSawyer where
  runMessage msg a@(EarlSawyer attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      a <$ push (DrawCards iid 1 False)
    _ -> EarlSawyer <$> runMessage msg attrs
