{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Treachery.Cards.OfferOfPower where

import Arkham.Json
import Arkham.Types.Classes
import Arkham.Types.Message
import Arkham.Types.Source
import Arkham.Types.Treachery.Attrs
import Arkham.Types.Treachery.Runner
import Arkham.Types.TreacheryId
import ClassyPrelude

newtype OfferOfPower = OfferOfPower Attrs
  deriving newtype (Show, ToJSON, FromJSON)

offerOfPower :: TreacheryId -> OfferOfPower
offerOfPower uuid = OfferOfPower $ baseAttrs uuid "01178"

instance HasActions env investigator OfferOfPower where
  getActions i window (OfferOfPower attrs) = getActions i window attrs

instance (TreacheryRunner env) => RunMessage env OfferOfPower where
  runMessage msg t@(OfferOfPower attrs@Attrs {..}) = case msg of
    Revelation iid tid | tid == treacheryId -> t <$ unshiftMessage
      (Ask iid $ ChooseOne
        [ Label
          "Draw 2 cards and place 2 doom on agenda"
          [ DrawCards iid 2 False
          , PlaceDoomOnAgenda
          , PlaceDoomOnAgenda
          , AdvanceAgendaIfThresholdSatisfied
          ]
        , Label
          "Take 2 horror"
          [InvestigatorAssignDamage iid (TreacherySource treacheryId) 0 2]
        ]
      )
    _ -> OfferOfPower <$> runMessage msg attrs