module Arkham.AssetId where

import Arkham.Prelude

import Arkham.Card.Id

newtype AssetId = AssetId { unAssetId :: CardId }
  deriving newtype (Show, Eq, ToJSON, FromJSON, ToJSONKey, FromJSONKey, Hashable, Random)

newtype ClosestAssetId = ClosestAssetId { unClosestAssetId :: AssetId }
  deriving newtype (Show, Eq, ToJSON, FromJSON, ToJSONKey, FromJSONKey, Hashable)
