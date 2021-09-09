module Arkham.Campaigns.ThePathToCarcosa.CampaignSteps where

import Arkham.Prelude

import Arkham.Types.Campaign.Attrs
import Arkham.Types.CampaignStep

nextStep :: CampaignAttrs -> Maybe CampaignStep
nextStep a = case campaignStep a of
  Just PrologueStep -> Just (ScenarioStep "03043")
  Just (ScenarioStep "03043") -> Just (UpgradeDeckStep $ ScenarioStep "03061")
  _ -> Nothing