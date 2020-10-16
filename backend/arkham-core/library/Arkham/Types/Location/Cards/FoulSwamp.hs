{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Location.Cards.FoulSwamp
  ( FoulSwamp(..)
  , foulSwamp
  )
where

import Arkham.Import

import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Helpers
import Arkham.Types.Location.Runner
import Arkham.Types.ScenarioLogKey
import Arkham.Types.Trait

newtype FoulSwamp = FoulSwamp Attrs
  deriving newtype (Show, ToJSON, FromJSON)

foulSwamp :: FoulSwamp
foulSwamp = FoulSwamp $ baseAttrs
  "81016"
  "Foul Swamp"
  2
  (Static 0)
  Hourglass
  [Equals, Square, Triangle, Diamond]
  [Unhallowed, Bayou]

instance IsInvestigator investigator => HasModifiersFor env investigator FoulSwamp where
  getModifiersFor _ i (FoulSwamp attrs) | atLocation i attrs =
    pure [CannotHealHorror, CannotCancelHorror]
  getModifiersFor _ _ _ = pure []

ability :: Attrs -> Ability
ability attrs = (mkAbility (toSource attrs) 1 (ActionAbility 1 Nothing))
  { abilityMetadata = Just (IntMetadata 0)
  }

instance IsInvestigator investigator => HasActions env investigator FoulSwamp where
  getActions i NonFast (FoulSwamp attrs@Attrs {..}) | locationRevealed = do
    baseActions <- getActions i NonFast attrs
    pure
      $ baseActions
      <> [ ActivateCardAbilityActionWithDynamicCost (getId () i) (ability attrs)
         | atLocation i attrs && hasActionsRemaining i Nothing locationTraits
         ]
  getActions i window (FoulSwamp attrs) = getActions i window attrs

instance LocationRunner env => RunMessage env FoulSwamp where
  runMessage msg l@(FoulSwamp attrs) = case msg of
    PayForCardAbility iid source meta@(Just (IntMetadata n)) 1
      | isSource attrs source -> if n == 3
        then runMessage (UseCardAbility iid source meta 1) l
        else do
          unshiftMessage $ chooseOne
            iid
            [ Run
              [ InvestigatorAssignDamage iid (toSource attrs) 0 1
              , PayForCardAbility iid source (Just (IntMetadata $ n + 1)) 1
              ]
            , Label
              ("Test with +" <> tshow n <> " Willpower")
              [UseCardAbility iid source meta 1]
            ]
          pure l
    UseCardAbility iid source (Just (IntMetadata n)) 1
      | isSource attrs source -> l <$ unshiftMessage
        (BeginSkillTest
          iid
          source
          (toTarget attrs)
          Nothing
          SkillWillpower
          7
          [Remember FoundAnAncientBindingStone]
          mempty
          [SkillModifier SkillWillpower n]
          mempty
        )
    _ -> FoulSwamp <$> runMessage msg attrs