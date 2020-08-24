{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Treachery.Cards.UmordhothsWrath where

import Arkham.Json
import Arkham.Types.Classes
import Arkham.Types.Message
import Arkham.Types.Query
import Arkham.Types.SkillType
import Arkham.Types.Source
import Arkham.Types.Target
import Arkham.Types.Treachery.Attrs
import Arkham.Types.Treachery.Runner
import Arkham.Types.TreacheryId
import ClassyPrelude

newtype UmordhothsWrath = UmordhothsWrath Attrs
  deriving newtype (Show, ToJSON, FromJSON)

umordhothsWrath :: TreacheryId -> UmordhothsWrath
umordhothsWrath uuid = UmordhothsWrath $ baseAttrs uuid "01158"

instance HasActions env investigator UmordhothsWrath where
  getActions i window (UmordhothsWrath attrs) = getActions i window attrs

instance (TreacheryRunner env) => RunMessage env UmordhothsWrath where
  runMessage msg t@(UmordhothsWrath attrs@Attrs {..}) = case msg of
    SkillTestDidFailBy iid (TreacheryTarget tid) n | tid == treacheryId ->
      t <$ unshiftMessage (HandlePointOfFailure iid (TreacheryTarget tid) n)
    HandlePointOfFailure _ (TreacheryTarget tid) 0 | tid == treacheryId ->
      pure t
    HandlePointOfFailure iid (TreacheryTarget tid) n | tid == treacheryId -> do
      cardCount' <- unCardCount <$> asks (getCount iid)
      if cardCount' > 0
        then t <$ unshiftMessages
          [ Ask iid $ ChooseOne
            [ Label "Discard a card from your hand" [RandomDiscard iid]
            , Label
              "Take 1 damage and 1 horror"
              [InvestigatorAssignDamage iid (TreacherySource treacheryId) 1 1]
            ]
          , HandlePointOfFailure iid (TreacheryTarget treacheryId) (n - 1)
          ]
        else t <$ unshiftMessages
          [ InvestigatorAssignDamage iid (TreacherySource treacheryId) 1 1
          , HandlePointOfFailure iid (TreacheryTarget treacheryId) (n - 1)
          ]
    Revelation iid tid | tid == treacheryId -> t <$ unshiftMessage
      (BeginSkillTest
        iid
        (TreacherySource treacheryId)
        Nothing
        SkillWillpower
        5
        []
        [NotifyOnFailure iid (TreacheryTarget treacheryId)]
        mempty
        mempty
      )
    _ -> UmordhothsWrath <$> runMessage msg attrs