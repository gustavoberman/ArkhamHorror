module Arkham.Treachery.Cards.CrisisOfIdentity
  ( crisisOfIdentity
  , CrisisOfIdentity(..)
  ) where

import Arkham.Prelude

import Arkham.Treachery.Cards qualified as Cards
import Arkham.Card.CardDef
import Arkham.ClassSymbol
import Arkham.Classes
import Arkham.Matcher
import Arkham.Message
import Arkham.Target
import Arkham.Treachery.Attrs
import Arkham.Treachery.Runner

newtype CrisisOfIdentity = CrisisOfIdentity TreacheryAttrs
  deriving anyclass (IsTreachery, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

crisisOfIdentity :: TreacheryCard CrisisOfIdentity
crisisOfIdentity = treachery CrisisOfIdentity Cards.crisisOfIdentity

instance TreacheryRunner env => RunMessage env CrisisOfIdentity where
  runMessage msg t@(CrisisOfIdentity attrs) = case msg of
    Revelation iid source | isSource attrs source -> do
      roles <- getSetList iid
      t <$ case roles of
        [] -> error "role has to be set"
        role : _ -> do
          assets <- selectList
            (AssetOwnedBy You <> AssetWithClass role <> DiscardableAsset)
          events <- getSetList
            (EventOwnedBy (InvestigatorWithId iid) <> EventWithClass role)
          skills <- getSetList (SkillOwnedBy iid <> SkillWithClass role)
          pushAll
            $ [ Discard $ AssetTarget aid | aid <- assets ]
            <> [ Discard $ EventTarget eid | eid <- events ]
            <> [ Discard $ SkillTarget sid | sid <- skills ]
            <> [DiscardTopOfDeck iid 1 (Just $ toTarget attrs)]
    DiscardedTopOfDeck iid [card] target | isTarget attrs target -> do
      t <$ push
        (SetRole iid $ fromMaybe Neutral $ cdClassSymbol $ toCardDef card)
    _ -> CrisisOfIdentity <$> runMessage msg attrs