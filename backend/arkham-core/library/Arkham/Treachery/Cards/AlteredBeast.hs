module Arkham.Treachery.Cards.AlteredBeast
  ( AlteredBeast(..)
  , alteredBeast
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Treachery.Cards qualified as Cards
import Arkham.Classes
import Arkham.Matcher
import Arkham.Message
import Arkham.Target
import Arkham.Timing qualified as Timing
import Arkham.Trait
import Arkham.Treachery.Attrs
import Arkham.Treachery.Runner

newtype AlteredBeast = AlteredBeast TreacheryAttrs
  deriving anyclass (IsTreachery, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

alteredBeast :: TreacheryCard AlteredBeast
alteredBeast = treachery AlteredBeast Cards.alteredBeast

instance HasAbilities AlteredBeast where
  getAbilities (AlteredBeast x) = case treacheryAttachedTarget x of
    Just (EnemyTarget eid) ->
      [ mkAbility x 1 $ ForcedAbility $ OrWindowMatcher
          [ EnemyEnters Timing.When YourLocation $ EnemyWithId eid
          , Enters Timing.When You (LocationWithEnemy $ EnemyWithId eid)
          ]
      ]
    _ -> error "Altered Beast must be attached to an enemy"

instance TreacheryRunner env => RunMessage env AlteredBeast where
  runMessage msg t@(AlteredBeast attrs@TreacheryAttrs {..}) = case msg of
    Revelation iid source | isSource attrs source -> do
      abominations <- selectListMap EnemyTarget $ EnemyWithTrait Abomination
      t <$ case abominations of
        [] -> push (Surge iid source)
        xs -> push
          (chooseOrRunOne
            iid
            [ TargetLabel x [AttachTreachery treacheryId x, HealAllDamage x]
            | x <- xs
            ]
          )
    UseCardAbility iid source _ 1 _ ->
      t <$ push (InvestigatorAssignDamage iid source DamageAny 0 1)
    _ -> AlteredBeast <$> runMessage msg attrs
