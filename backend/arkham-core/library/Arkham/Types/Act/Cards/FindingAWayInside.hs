{-# LANGUAGE UndecidableInstances #-}

module Arkham.Types.Act.Cards.FindingAWayInside
  ( FindingAWayInside(..)
  , findingAWayInside
  )
where

import Arkham.Import

import Arkham.Types.Act.Attrs
import Arkham.Types.Act.Helpers
import Arkham.Types.Act.Runner

newtype FindingAWayInside = FindingAWayInside Attrs
  deriving newtype (Show, ToJSON, FromJSON)

findingAWayInside :: FindingAWayInside
findingAWayInside = FindingAWayInside $ baseAttrs
  "02122"
  "Finding A Way Inside"
  (Act 1 A)
  (Just $ RequiredClues (Static 2) Nothing)

instance ActionRunner env => HasActions env FindingAWayInside where
  getActions i window (FindingAWayInside x) = getActions i window x

instance ActRunner env => RunMessage env FindingAWayInside where
  runMessage msg a@(FindingAWayInside attrs@Attrs {..}) = case msg of
    AdvanceAct aid _ | aid == actId && onSide A attrs -> do
      leadInvestigatorId <- getLeadInvestigatorId
      investigatorIds <- getInvestigatorIds
      unshiftMessages
        [ SpendClues 2 investigatorIds
        , chooseOne leadInvestigatorId [AdvanceAct aid (toSource attrs)]
        ]
      pure $ FindingAWayInside $ attrs & sequenceL .~ Act 1 B
    AdvanceAct aid source
      | aid == actId && onSide B attrs && isSource attrs source -> do
        leadInvestigatorId <- getLeadInvestigatorId
        investigatorIds <- getInvestigatorIds
        a <$ unshiftMessages
          [ chooseOne
            leadInvestigatorId
            [ TargetLabel
                (InvestigatorTarget iid)
                [AddCampaignCardToDeck iid "02061"]
            | iid <- investigatorIds
            ]
          , RevealLocation Nothing "02127"
          , NextAct aid "02123"
          ]
    AdvanceAct aid _ | aid == actId && onSide B attrs ->
      a <$ unshiftMessages [RevealLocation Nothing "02127", NextAct aid "02124"]
    _ -> FindingAWayInside <$> runMessage msg attrs