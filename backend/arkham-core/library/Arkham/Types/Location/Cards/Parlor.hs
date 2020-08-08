{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Location.Cards.Parlor where

import Arkham.Json
import Arkham.Types.Ability
import qualified Arkham.Types.Action as Action
import Arkham.Types.AssetId
import Arkham.Types.Card
import Arkham.Types.Classes
import Arkham.Types.GameValue
import Arkham.Types.InvestigatorId
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Runner
import Arkham.Types.LocationSymbol
import Arkham.Types.Message
import Arkham.Types.SkillType
import Arkham.Types.Source
import ClassyPrelude
import Lens.Micro

newtype Parlor = Parlor Attrs
  deriving newtype (Show, ToJSON, FromJSON)

parlor :: Parlor
parlor = Parlor $ (baseAttrs "01115" "Parlor" 2 (Static 0) Diamond [Square])
  { locationBlocked = True
  , locationAbilities =
    [ ( LocationSource "01115"
      , Nothing
      , 1
      , ActionAbility 1 (Just Action.Resign)
      , NoLimit
      )
    ]
  }


instance (LocationRunner env) => RunMessage env Parlor where
  runMessage msg l@(Parlor attrs@Attrs {..}) = case msg of
    RevealLocation lid | lid == locationId -> do
      attrs' <- runMessage msg attrs
      pure $ Parlor $ attrs' & blocked .~ False
    PrePlayerWindow | locationRevealed -> do
      aid <- unStoryAssetId <$> asks (getId (CardCode "01117"))
      miid <- fmap unOwnerId <$> asks (getId aid)
      case miid of
        Just _ ->
          l <$ unshiftMessage (RemoveAbilitiesFrom (LocationSource locationId))
        Nothing -> l <$ unshiftMessages
          [ RemoveAbilitiesFrom (LocationSource locationId)
          , AddAbility
            (AssetSource aid)
            ( AssetSource aid
            , Just (LocationSource locationId)
            , 2
            , ActionAbility 1 (Just Action.Parley)
            , NoLimit
            )
          ]
    UseCardAbility iid (LocationSource lid, _, 1, _, _)
      | lid == locationId && locationRevealed -> l
      <$ unshiftMessage (Resign iid)
    UseCardAbility iid (_, Just (LocationSource lid), 2, _, _)
      | lid == locationId && locationRevealed -> do
        aid <- unStoryAssetId <$> asks (getId (CardCode "01117"))
        l <$ unshiftMessage
          (BeginSkillTest
            iid
            (LocationSource lid)
            (Just Action.Parley)
            SkillIntellect
            4
            [TakeControlOfAsset iid aid]
            []
            []
            mempty
          )
    _ -> Parlor <$> runMessage msg attrs