module Arkham.Asset.Cards.KeyToTheChamber
  ( keyToTheChamber
  , KeyToTheChamber(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Cost
import Arkham.Criteria
import Arkham.Exception
import Arkham.Matcher
import Arkham.Target

newtype KeyToTheChamber = KeyToTheChamber AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

keyToTheChamber :: AssetCard KeyToTheChamber
keyToTheChamber =
  assetWith KeyToTheChamber Cards.keyToTheChamber (isStoryL .~ True)

instance HasAbilities KeyToTheChamber where
  getAbilities (KeyToTheChamber attrs) =
    [ restrictedAbility
        attrs
        1
        (OwnsThis <> LocationExists
          (ConnectedLocation <> LocationWithTitle "The Hidden Chamber")
        )
        (FastAbility Free)
    ]

instance HasModifiersFor env KeyToTheChamber

instance AssetRunner env => RunMessage env KeyToTheChamber where
  runMessage msg a@(KeyToTheChamber attrs) = case msg of
    Revelation iid source | isSource attrs source ->
      a <$ push (TakeControlOfAsset iid $ toId a)
    UseCardAbility _ source _ 1 _ | isSource attrs source -> do
      mHiddenChamberId <- getId (LocationWithTitle "The Hidden Chamber")
      case mHiddenChamberId of
        Nothing -> throwIO $ InvalidState "The Hidden Chamber is missing"
        Just hiddenChamberId ->
          a <$ push (AttachAsset (toId a) (LocationTarget hiddenChamberId))
    _ -> KeyToTheChamber <$> runMessage msg attrs
