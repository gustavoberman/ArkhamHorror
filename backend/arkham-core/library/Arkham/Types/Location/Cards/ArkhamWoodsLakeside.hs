{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Location.Cards.ArkhamWoodsLakeside where

import Arkham.Import

import qualified Arkham.Types.Action as Action
import qualified Arkham.Types.EncounterSet as EncounterSet
import Arkham.Types.Game.Helpers
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Runner
import Arkham.Types.Trait

newtype ArkhamWoodsLakeside = ArkhamWoodsLakeside Attrs
  deriving newtype (Show, ToJSON, FromJSON)

arkhamWoodsLakeside :: ArkhamWoodsLakeside
arkhamWoodsLakeside = ArkhamWoodsLakeside $ base
  { locationRevealedConnectedSymbols = setFromList [Squiggle, Heart]
  , locationRevealedSymbol = Star
  }
 where
  base = baseAttrs
    "50034"
    "Arkham Woods: Lakeside"
    EncounterSet.ReturnToTheDevourerBelow
    4
    (PerPlayer 1)
    Square
    [Squiggle]
    [Woods]

instance HasModifiersFor env ArkhamWoodsLakeside where
  getModifiersFor = noModifiersFor

instance ActionRunner env => HasActions env ArkhamWoodsLakeside where
  getActions i window (ArkhamWoodsLakeside attrs) = getActions i window attrs

instance (LocationRunner env) => RunMessage env ArkhamWoodsLakeside where
  runMessage msg l@(ArkhamWoodsLakeside attrs@Attrs {..}) = case msg of
    RevealToken (SkillTestSource _ source (Just Action.Investigate)) iid _
      | isSource attrs source && iid `elem` locationInvestigators -> do
        let
          ability = (mkAbility (toSource attrs) 0 ForcedAbility)
            { abilityLimit = PerRound
            }
        unused <- getGroupIsUnused ability
        l <$ when
          unused
          (unshiftMessages [UseLimitedAbility iid ability, DrawAnotherToken iid]
          )
    _ -> ArkhamWoodsLakeside <$> runMessage msg attrs