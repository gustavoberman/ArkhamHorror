{-# LANGUAGE UndecidableInstances #-}

module Arkham.Types.Asset.Cards.TheNecronomiconOlausWormiusTranslation
  ( theNecronomiconOlausWormiusTranslation
  , TheNecronomiconOlausWormiusTranslation(..)
  )
where

import Arkham.Import

import Arkham.Types.Asset.Attrs
import Arkham.Types.Game.Helpers

newtype TheNecronomiconOlausWormiusTranslation = TheNecronomiconOlausWormiusTranslation Attrs
  deriving newtype (Show, ToJSON, FromJSON)

theNecronomiconOlausWormiusTranslation
  :: AssetId -> TheNecronomiconOlausWormiusTranslation
theNecronomiconOlausWormiusTranslation uuid =
  TheNecronomiconOlausWormiusTranslation
    $ (baseAttrs uuid "02140") { assetSlots = [HandSlot] }

instance HasActions env TheNecronomiconOlausWormiusTranslation where
  getActions iid NonFast (TheNecronomiconOlausWormiusTranslation a)
    | ownedBy a iid = do
      pure
        [ ActivateCardAbilityAction
            iid
            (mkAbility (toSource a) 1 (ActionAbility Nothing $ ActionCost 1))
        ]
  getActions _ _ _ = pure []

instance HasModifiersFor env TheNecronomiconOlausWormiusTranslation where
  getModifiersFor _ (InvestigatorTarget iid) (TheNecronomiconOlausWormiusTranslation a)
    = pure $ toModifiers a [ SkillModifier SkillIntellect 1 | ownedBy a iid ]
  getModifiersFor _ _ _ = pure []

instance (HasQueue env, HasModifiersFor env ()) => RunMessage env TheNecronomiconOlausWormiusTranslation where
  runMessage msg a@(TheNecronomiconOlausWormiusTranslation attrs) = case msg of
    UseCardAbility iid source _ 1 | isSource attrs source ->
      a <$ unshiftMessage (TakeResources iid 2 False)
    _ -> TheNecronomiconOlausWormiusTranslation <$> runMessage msg attrs