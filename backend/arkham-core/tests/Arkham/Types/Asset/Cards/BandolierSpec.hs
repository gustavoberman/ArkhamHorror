module Arkham.Types.Asset.Cards.BandolierSpec
  ( spec
  )
where

import TestImport

import qualified Arkham.Types.Investigator.Attrs as Investigator
import Arkham.Types.Trait

spec :: Spec
spec = describe "Bandolier" $ do
  it "adds a weapon hand slot" $ do
    investigator <- testInvestigator "00000" id
    bandolier <- buildAsset "02147"
    game <- runGameTest
      investigator
      [playAsset investigator bandolier]
      (assets %~ insertEntity bandolier)
    let
      slots =
        fromMaybe []
          $ investigatorAttrs (updated game investigator)
          ^? Investigator.slots
          . ix HandSlot
    slots `shouldSatisfy` elem
      (TraitRestrictedSlot (AssetSource $ getId () bandolier) Weapon Nothing)