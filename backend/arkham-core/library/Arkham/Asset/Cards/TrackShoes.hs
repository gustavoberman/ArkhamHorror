module Arkham.Asset.Cards.TrackShoes
  ( trackShoes
  , TrackShoes(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Matcher hiding (MoveAction)
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype TrackShoes = TrackShoes AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

trackShoes :: AssetCard TrackShoes
trackShoes = asset TrackShoes Cards.trackShoes

instance HasModifiersFor env TrackShoes where
  getModifiersFor _ (InvestigatorTarget iid) (TrackShoes attrs)
    | attrs `ownedBy` iid = pure
    $ toModifiers attrs [SkillModifier SkillAgility 1]
  getModifiersFor _ _ _ = pure []

instance HasAbilities TrackShoes where
  getAbilities (TrackShoes attrs) =
    [ restrictedAbility attrs 1 OwnsThis $ ReactionAbility
        (MovedButBeforeEnemyEngagement Timing.After You Anywhere)
        (ExhaustCost $ toTarget attrs)
    ]

instance AssetRunner env => RunMessage env TrackShoes where
  runMessage msg a@(TrackShoes attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      a
        <$ push
             (BeginSkillTest
               iid
               source
               (InvestigatorTarget iid)
               Nothing
               SkillAgility
               3
             )
    PassedSkillTest iid _ source SkillTestInitiatorTarget{} _ _
      | isSource attrs source -> do
        accessibleLocationIds <- selectList AccessibleLocation
        a <$ push
          (chooseOne
            iid
            [ TargetLabel (LocationTarget lid) [MoveAction iid lid Free False]
            | lid <- accessibleLocationIds
            ]
          )
    _ -> TrackShoes <$> runMessage msg attrs
