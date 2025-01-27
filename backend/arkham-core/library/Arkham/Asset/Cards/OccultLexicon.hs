module Arkham.Asset.Cards.OccultLexicon where

import Arkham.Prelude

import Arkham.Asset.Cards qualified as Cards
import Arkham.Event.Cards qualified as Events
import Arkham.Asset.Runner
import Arkham.Card
import Arkham.Card.PlayerCard

newtype OccultLexicon = OccultLexicon AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

occultLexicon :: AssetCard OccultLexicon
occultLexicon = asset OccultLexicon Cards.occultLexicon

instance AssetRunner env => RunMessage env OccultLexicon where
  runMessage msg (OccultLexicon attrs) = case msg of
    InvestigatorPlayAsset iid aid _ _ | aid == assetId attrs -> do
      handBloodRite <- PlayerCard <$> genPlayerCard Events.bloodRite
      deckBloodRites <- replicateM 2 (genPlayerCard Events.bloodRite)
      canShuffleDeck <- getCanShuffleDeck iid
      pushAll
        $ AddToHand iid handBloodRite
        : [ ShuffleCardsIntoDeck iid deckBloodRites | canShuffleDeck ]
      OccultLexicon <$> runMessage msg attrs
    RemovedFromPlay source | isSource attrs source -> do
      for_ (assetController attrs)
        $ \iid -> push (RemoveAllCopiesOfCardFromGame iid "05317")
      OccultLexicon <$> runMessage msg attrs
    _ -> OccultLexicon <$> runMessage msg attrs
