{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Treachery.Cards.CursedLuck
  ( CursedLuck(..)
  , cursedLuck
  )
where

import Arkham.Import

import Arkham.Types.Treachery.Attrs
import Arkham.Types.Treachery.Helpers
import Arkham.Types.Treachery.Runner

newtype CursedLuck = CursedLuck Attrs
  deriving newtype (Show, ToJSON, FromJSON)

cursedLuck :: TreacheryId -> Maybe InvestigatorId -> CursedLuck
cursedLuck uuid _ = CursedLuck $ baseAttrs uuid "02092"

instance HasModifiersFor env CursedLuck where
  getModifiersFor SkillTestSource{} (InvestigatorTarget iid) (CursedLuck attrs)
    = pure $ toModifiers
      attrs
      [ AnySkillValue (-1) | treacheryOnInvestigator iid attrs ]
  getModifiersFor _ _ _ = pure []

instance HasActions env CursedLuck where
  getActions i window (CursedLuck attrs) = getActions i window attrs

instance TreacheryRunner env => RunMessage env CursedLuck where
  runMessage msg t@(CursedLuck attrs@Attrs {..}) = case msg of
    Revelation iid source | isSource attrs source ->
      t <$ unshiftMessage (AttachTreachery treacheryId (InvestigatorTarget iid))
    PassedSkillTest iid _ _ (SkillTestInitiatorTarget _) n
      | treacheryOnInvestigator iid attrs && n >= 1 -> t
      <$ unshiftMessage (Discard $ toTarget attrs)
    _ -> CursedLuck <$> runMessage msg attrs