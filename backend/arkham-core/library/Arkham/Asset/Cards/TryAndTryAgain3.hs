module Arkham.Asset.Cards.TryAndTryAgain3
  ( tryAndTryAgain3
  , TryAndTryAgain3(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Card
import Arkham.Cost
import Arkham.Criteria
import Arkham.Id
import Arkham.Matcher
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype TryAndTryAgain3 = TryAndTryAgain3 AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

tryAndTryAgain3 :: AssetCard TryAndTryAgain3
tryAndTryAgain3 = asset TryAndTryAgain3 Cards.tryAndTryAgain3

instance HasAbilities TryAndTryAgain3 where
  getAbilities (TryAndTryAgain3 x) =
    [ restrictedAbility x 1 OwnsThis $ ReactionAbility
        (SkillTestResult
          Timing.After
          Anyone
          (SkillTestWithSkill YourSkill)
          (FailureResult AnyValue)
        )
        (ExhaustCost $ toTarget x)
    ]

instance AssetRunner env => RunMessage env TryAndTryAgain3 where
  runMessage msg a@(TryAndTryAgain3 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      committedSkills <-
        filter ((== SkillType) . toCardType)
        . map unCommittedCard
        <$> getList iid
      a <$ pushAll
        [ FocusCards committedSkills
        , chooseOne
          iid
          [ ReturnToHand iid (SkillTarget $ SkillId $ toCardId skill)
          | skill <- committedSkills
          ]
        , UnfocusCards
        ]
    _ -> TryAndTryAgain3 <$> runMessage msg attrs
