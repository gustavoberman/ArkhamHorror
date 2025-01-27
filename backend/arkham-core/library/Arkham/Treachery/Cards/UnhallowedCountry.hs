module Arkham.Treachery.Cards.UnhallowedCountry
  ( UnhallowedCountry(..)
  , unhallowedCountry
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Treachery.Cards qualified as Cards
import Arkham.Card
import Arkham.Classes
import Arkham.Criteria
import Arkham.Id
import Arkham.Matcher
import Arkham.Message
import Arkham.Modifier
import Arkham.SkillType
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Trait
import Arkham.Treachery.Attrs
import Arkham.Treachery.Helpers
import Arkham.Treachery.Runner

newtype UnhallowedCountry = UnhallowedCountry TreacheryAttrs
  deriving anyclass IsTreachery
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

unhallowedCountry :: TreacheryCard UnhallowedCountry
unhallowedCountry = treachery UnhallowedCountry Cards.unhallowedCountry

instance (HasSet Trait env AssetId, Query InvestigatorMatcher env) => HasModifiersFor env UnhallowedCountry where
  getModifiersFor _ (InvestigatorTarget iid) (UnhallowedCountry attrs) =
    pure $ toModifiers
      attrs
      [ CannotPlay [(AssetType, singleton Ally)]
      | treacheryOnInvestigator iid attrs
      ]
  getModifiersFor _ (AssetTarget aid) (UnhallowedCountry attrs) = do
    traits <- getSet @Trait aid
    miid <- selectAssetController aid
    pure $ case miid of
      Just iid -> toModifiers
        attrs
        [ Blank | treacheryOnInvestigator iid attrs && Ally `member` traits ]
      Nothing -> []
  getModifiersFor _ _ _ = pure []

instance HasAbilities UnhallowedCountry where
  getAbilities (UnhallowedCountry x) =
    [ restrictedAbility x 1 (InThreatAreaOf You) $ ForcedAbility $ TurnEnds
        Timing.When
        You
    ]

instance TreacheryRunner env => RunMessage env UnhallowedCountry where
  runMessage msg t@(UnhallowedCountry attrs) = case msg of
    Revelation iid source | isSource attrs source ->
      t <$ push (AttachTreachery (toId attrs) $ InvestigatorTarget iid)
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      t <$ push (RevelationSkillTest iid source SkillWillpower 3)
    PassedSkillTest _ _ source SkillTestInitiatorTarget{} _ _
      | isSource attrs source -> t <$ push (Discard $ toTarget attrs)
    _ -> UnhallowedCountry <$> runMessage msg attrs
