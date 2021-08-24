module Arkham.Types.Act.Cards.IntoTheDarkness where

import Arkham.Prelude

import qualified Arkham.Act.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Act.Attrs
import Arkham.Types.Act.Helpers
import Arkham.Types.Act.Runner
import Arkham.Types.Card
import Arkham.Types.Classes
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.Source
import qualified Arkham.Types.Timing as Timing

newtype IntoTheDarkness = IntoTheDarkness ActAttrs
  deriving anyclass (IsAct, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

intoTheDarkness :: ActCard IntoTheDarkness
intoTheDarkness = act (2, A) IntoTheDarkness Cards.intoTheDarkness Nothing

instance HasAbilities env IntoTheDarkness where
  getAbilities _ _ (IntoTheDarkness attrs) | onSide A attrs = pure
    [ mkAbility attrs 1
      $ Objective
      $ ForcedAbility
      $ Enters Timing.After Anyone
      $ LocationWithTitle "Ritual Site"
    ]
  getAbilities _ _ _ = pure []

instance ActRunner env => RunMessage env IntoTheDarkness where
  runMessage msg a@(IntoTheDarkness attrs@ActAttrs {..}) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source -> do
      a <$ push (AdvanceAct actId source)
    AdvanceAct aid _ | aid == actId && onSide B attrs -> do
      playerCount <- getPlayerCount
      if playerCount > 3
        then a <$ pushAll
          [ ShuffleEncounterDiscardBackIn
          , DiscardEncounterUntilFirst
            (ActSource actId)
            (CardWithType EnemyType)
          , DiscardEncounterUntilFirst
            (ActSource actId)
            (CardWithType EnemyType)
          , NextAct actId "01148"
          ]
        else a <$ pushAll
          [ ShuffleEncounterDiscardBackIn
          , DiscardEncounterUntilFirst
            (ActSource actId)
            (CardWithType EnemyType)
          , NextAct actId "01148"
          ]
    RequestedEncounterCard (ActSource aid) mcard | aid == actId -> case mcard of
      Nothing -> pure a
      Just card -> do
        ritualSiteId <- getJustLocationIdByName "Ritual Site"
        a <$ pushAll [SpawnEnemyAt (EncounterCard card) ritualSiteId]
    _ -> IntoTheDarkness <$> runMessage msg attrs
