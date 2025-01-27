module Arkham.Act.Cards.Run
  ( Run(..)
  , run
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Act.Attrs
import Arkham.Act.Cards qualified as Cards
import Arkham.Act.Runner
import Arkham.Classes
import Arkham.Matcher
import Arkham.Message hiding (Run)
import Arkham.SkillType
import Arkham.Source
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype Run = Run ActAttrs
  deriving anyclass (IsAct, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

run :: ActCard Run
run = act (1, A) Run Cards.run Nothing

instance HasAbilities Run where
  getAbilities (Run x) =
    [ mkAbility x 1 $ ForcedAbility $ Enters Timing.When You $ LocationWithTitle
        "Engine Car"
    ]

instance ActRunner env => RunMessage env Run where
  runMessage msg a@(Run attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> do
      -- We need to know the investigator who entered
      a <$ push (AdvanceAct (toId attrs) (InvestigatorSource iid) AdvancedWithOther)
    AdvanceAct aid (InvestigatorSource iid) _
      | aid == toId attrs && onSide B attrs -> a <$ pushAll
        (chooseOne
            iid
            [ Label
              "Attempt to dodge the creature"
              [ BeginSkillTest
                  iid
                  (toSource attrs)
                  (toTarget attrs)
                  Nothing
                  SkillAgility
                  3
              ]
            , Label
              "Attempt to endure the creature's extreme heat"
              [ BeginSkillTest
                  iid
                  (toSource attrs)
                  (toTarget attrs)
                  Nothing
                  SkillCombat
                  3
              ]
            ]
        : [AdvanceActDeck (actDeckId attrs) (toSource attrs)]
        )
    FailedSkillTest iid _ source SkillTestInitiatorTarget{} SkillAgility _
      | isSource attrs source && onSide B attrs -> a
      <$ push (SufferTrauma iid 1 0)
    FailedSkillTest iid _ source SkillTestInitiatorTarget{} SkillCombat _
      | isSource attrs source && onSide B attrs -> a
      <$ push (SufferTrauma iid 1 0)
    _ -> Run <$> runMessage msg attrs
