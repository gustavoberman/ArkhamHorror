{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Agenda.Cards.ACreatureOfTheBayou where

import Arkham.Import

import Arkham.Types.Agenda.Attrs
import qualified Arkham.Types.Agenda.Attrs as Agenda
import Arkham.Types.Agenda.Runner
import Arkham.Types.Agenda.Helpers
import Arkham.Types.Trait

newtype ACreatureOfTheBayou = ACreatureOfTheBayou Attrs
  deriving newtype (Show, ToJSON, FromJSON)

aCreatureOfTheBayou :: ACreatureOfTheBayou
aCreatureOfTheBayou = ACreatureOfTheBayou
  $ baseAttrs "81002" "A Creature of the Bayou" "Agenda 1a" (Static 5)

instance HasActions env investigator ACreatureOfTheBayou where
  getActions i window (ACreatureOfTheBayou x) = getActions i window x

getRougarou
  :: (MonadReader env m, HasId (Maybe StoryEnemyId) CardCode env)
  => m (Maybe EnemyId)
getRougarou = asks (fmap unStoryEnemyId <$> getId (CardCode "81028"))

instance AgendaRunner env => RunMessage env ACreatureOfTheBayou where
  runMessage msg (ACreatureOfTheBayou attrs@Attrs {..}) = case msg of
    AdvanceAgenda aid | aid == agendaId && agendaSequence == "Agenda 1a" -> do
      mrougarou <- getRougarou
      case mrougarou of
        Nothing -> unshiftMessages
          [ ShuffleEncounterDiscardBackIn
          , NextAgenda aid "81003"
          , PlaceDoomOnAgenda
          ]
        Just eid -> do
          leadInvestigatorId <- getLeadInvestigatorId
          locations <- asks $ getSet @LocationId ()
          nonBayouLocations <- asks $ setToList . difference locations . getSet
            [Bayou]
          nonBayouLocationsWithClueCounts <- sortOn snd <$> for
            nonBayouLocations
            (\lid -> asks $ (lid, ) . unClueCount . getCount lid)
          let
            moveMessage = case nonBayouLocationsWithClueCounts of
              [] -> error "there has to be such a location"
              ((_, c) : _) ->
                let
                  (matches, _) =
                    span ((== c) . snd) nonBayouLocationsWithClueCounts
                in
                  case matches of
                    [(x, _)] -> MoveUntil x (EnemyTarget eid)
                    xs -> chooseOne
                      leadInvestigatorId
                      [ MoveUntil x (EnemyTarget eid) | (x, _) <- xs ]
          unshiftMessages
            [ShuffleEncounterDiscardBackIn, moveMessage, NextAgenda aid "81003"]
      pure
        $ ACreatureOfTheBayou
        $ attrs
        & Agenda.sequence
        .~ "Agenda 1b"
        & flipped
        .~ True
    _ -> ACreatureOfTheBayou <$> runMessage msg attrs