module Arkham.Agenda.Cards.AllIsOne
  ( AllIsOne
  , allIsOne
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Agenda.Cards qualified as Cards
import Arkham.Agenda.Attrs
import Arkham.Agenda.Runner
import Arkham.CampaignLogKey
import Arkham.Card.CardType
import Arkham.Classes
import Arkham.Game.Helpers
import Arkham.GameValue
import Arkham.Matcher
import Arkham.Message
import Arkham.Timing qualified as Timing

newtype AllIsOne = AllIsOne AgendaAttrs
  deriving anyclass (IsAgenda, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

allIsOne :: AgendaCard AllIsOne
allIsOne = agenda (1, A) AllIsOne Cards.allIsOne (Static 4)

instance HasAbilities AllIsOne where
  getAbilities (AllIsOne x) =
    [ mkAbility x 1 $ ForcedAbility $ MovedBy
        Timing.After
        You
        EncounterCardSource
    ]

instance AgendaRunner env => RunMessage env AllIsOne where
  runMessage msg a@(AllIsOne attrs@AgendaAttrs {..}) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      a <$ push (InvestigatorAssignDamage iid source DamageAny 0 1)
    AdvanceAgenda aid | aid == agendaId && onSide B attrs -> do
      failedToSaveStudents <- getHasRecord
        TheInvestigatorsFailedToSaveTheStudents
      investigatorIds <- getInvestigatorIds
      a <$ pushAll
        ([ ShuffleEncounterDiscardBackIn
         , DiscardEncounterUntilFirst
           (toSource attrs)
           (CardWithType LocationType)
         ]
        <> [ InvestigatorAssignDamage iid (toSource attrs) DamageAny 0 1
           | failedToSaveStudents
           , iid <- investigatorIds
           ]
        <> [AdvanceAgendaDeck agendaDeckId (toSource attrs)]
        )
    RequestedEncounterCard source (Just card) | isSource attrs source -> do
      leadInvestigator <- getLeadInvestigatorId
      a <$ push (InvestigatorDrewEncounterCard leadInvestigator card)
    _ -> AllIsOne <$> runMessage msg attrs
