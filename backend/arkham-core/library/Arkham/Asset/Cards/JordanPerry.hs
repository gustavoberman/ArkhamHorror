module Arkham.Asset.Cards.JordanPerry
  ( jordanPerry
  , JordanPerry(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Story.Cards qualified as Story
import Arkham.Asset.Runner
import Arkham.Card
import Arkham.Card.EncounterCard
import Arkham.Cost
import Arkham.Criteria
import Arkham.GameValue
import Arkham.Matcher
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype JordanPerry = JordanPerry AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

jordanPerry :: AssetCard JordanPerry
jordanPerry = asset JordanPerry Cards.jordanPerry

instance HasAbilities JordanPerry where
  getAbilities (JordanPerry a) =
    [ restrictedAbility
        a
        1
        (OnSameLocation <> InvestigatorExists
          (You <> InvestigatorWithResources (AtLeast $ Static 10))
        )
      $ ActionAbility Nothing
      $ ActionCost 1
    , mkAbility a 2
      $ ForcedAbility
      $ LastClueRemovedFromAsset Timing.When
      $ AssetWithId
      $ toId a
    ]

instance AssetRunner env => RunMessage env JordanPerry where
  runMessage msg a@(JordanPerry attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> a <$ push
      (BeginSkillTest iid source (toTarget attrs) Nothing SkillIntellect 2)
    PassedSkillTest iid _ source SkillTestInitiatorTarget{} _ _
      | isSource attrs source -> do
        modifiers <- getModifiers source (InvestigatorTarget iid)
        a <$ when
          (assetClues attrs > 0 && CannotTakeControlOfClues `notElem` modifiers)
          (pushAll [RemoveClues (toTarget attrs) 1, GainClues iid 1])
    UseCardAbility _ source _ 2 _ | isSource attrs source -> do
      a <$ push
        (ReadStory
        $ EncounterCard
        $ lookupEncounterCard Story.langneauPerdu
        $ toCardId attrs
        )
    _ -> JordanPerry <$> runMessage msg attrs
