{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Event.Cards.SecondWind
  ( secondWind
  , SecondWind(..)
  )
where

import Arkham.Import

import Arkham.Types.Event.Attrs

newtype SecondWind = SecondWind Attrs
  deriving newtype (Show, ToJSON, FromJSON)

secondWind :: InvestigatorId -> EventId -> SecondWind
secondWind iid uuid = SecondWind $ baseAttrs iid uuid "04149"

instance HasActions env SecondWind where
  getActions iid window (SecondWind attrs) = getActions iid window attrs

instance HasModifiersFor env SecondWind where
  getModifiersFor = noModifiersFor

instance (HasQueue env, HasRoundHistory env) => RunMessage env SecondWind where
  runMessage msg (SecondWind attrs@Attrs {..}) = case msg of
    InvestigatorPlayEvent iid eid _ | eid == eventId -> do
      roundHistory <- getRoundHistory =<< ask
      let
        didDrawTreachery = \case
          DrewTreachery iid' _ -> iid == iid'
          DrewPlayerTreachery iid' _ _ -> iid == iid'
          _ -> False
        damageToHeal = if any didDrawTreachery roundHistory then 2 else 1
      unshiftMessages
        [ HealDamage (InvestigatorTarget iid) damageToHeal
        , DrawCards iid 1 False
        ]
      SecondWind <$> runMessage msg (attrs & resolved .~ True)
    _ -> SecondWind <$> runMessage msg attrs