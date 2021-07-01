module Arkham.Types.Event.Cards.LetMeHandleThis
  ( letMeHandleThis
  , LetMeHandleThis(..)
  ) where

import Arkham.Prelude

import Arkham.Types.Card
import Arkham.Types.Classes
import Arkham.Types.Event.Attrs
import Arkham.Types.EventId
import Arkham.Types.InvestigatorId
import Arkham.Types.Message
import Arkham.Types.Source
import Arkham.Types.Target
import Arkham.Types.Window

newtype LetMeHandleThis = LetMeHandleThis EventAttrs
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

letMeHandleThis :: InvestigatorId -> EventId -> LetMeHandleThis
letMeHandleThis iid uuid = LetMeHandleThis $ baseAttrs iid uuid "03022"

instance HasModifiersFor env LetMeHandleThis where
  getModifiersFor = noModifiersFor

instance HasActions env LetMeHandleThis where
  getActions iid (InHandWindow ownerId (WhenDrawNonPerilTreachery who tid)) (LetMeHandleThis attrs)
    | who /= You && iid == ownerId
    = pure
      [ InitiatePlayCard
          iid
          (attrs ^. cardIdL)
          (Just $ TreacheryTarget tid)
          False
      ]
  getActions iid window (LetMeHandleThis attrs) = getActions iid window attrs

instance HasQueue env => RunMessage env LetMeHandleThis where
  runMessage msg e@(LetMeHandleThis attrs@EventAttrs {..}) = case msg of
    InvestigatorPlayEvent iid eid (Just (TreacheryTarget tid))
      | eid == eventId -> do
        withQueue_ $ map $ \case
          Revelation _ (TreacherySource tid') | tid == tid' ->
            Revelation iid (TreacherySource tid')
          AfterRevelation _ tid' | tid == tid' -> AfterRevelation iid tid'
          Surge _ (TreacherySource tid') | tid == tid' ->
            Surge iid (TreacherySource tid')
          other -> other
        e <$ unshiftMessages
          [ CreateEffect
            (attrs ^. defL . cardCodeL)
            Nothing
            (toSource attrs)
            (InvestigatorTarget iid)
          , Discard (toTarget attrs)
          ]
    _ -> LetMeHandleThis <$> runMessage msg attrs
