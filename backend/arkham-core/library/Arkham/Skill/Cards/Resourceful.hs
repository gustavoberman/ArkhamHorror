module Arkham.Skill.Cards.Resourceful
  ( resourceful
  , Resourceful(..)
  ) where

import Arkham.Prelude

import Arkham.Skill.Cards qualified as Cards
import Arkham.Card
import Arkham.ClassSymbol
import Arkham.Classes
import Arkham.Matcher
import Arkham.Message
import Arkham.Skill.Attrs
import Arkham.Skill.Runner
import Arkham.Target

newtype Resourceful = Resourceful SkillAttrs
  deriving anyclass (IsSkill, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

resourceful :: SkillCard Resourceful
resourceful = skill Resourceful Cards.resourceful

instance SkillRunner env => RunMessage env Resourceful where
  runMessage msg s@(Resourceful attrs) = case msg of
    PassedSkillTest _ _ _ target _ _ | isTarget attrs target -> do
      targets <- selectList
        (InDiscardOf (InvestigatorWithId $ skillOwner attrs) <> BasicCardMatch
          (CardWithClass Survivor <> NotCard (CardWithTitle "Resourceful"))
        )
      s <$ when
        (notNull targets)
        (push $ chooseOne
          (skillOwner attrs)
          [ TargetLabel
              (CardIdTarget $ toCardId card)
              [ RemoveFromDiscard (skillOwner attrs) (toCardId card)
              , AddToHand (skillOwner attrs) card
              ]
          | card <- targets
          ]
        )
    _ -> Resourceful <$> runMessage msg attrs
