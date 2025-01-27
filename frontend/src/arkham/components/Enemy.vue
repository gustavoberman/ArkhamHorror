<template>
  <div class="enemy">
    <img :src="image"
      :class="{'enemy--can-interact': cardAction !== -1, exhausted: isExhausted }"
      class="card enemy"
      @click="$emit('choose', cardAction)"
    />
    <AbilityButton
      v-for="ability in abilities"
      :key="ability"
      :ability="choices[ability]"
      :data-image="image"
      @click="$emit('choose', ability)"
      />
    <div class="pool">
      <PoolItem type="health" :amount="enemy.contents.damage" />
      <PoolItem v-if="enemy.contents.doom > 0" type="doom" :amount="enemy.contents.doom" />
      <PoolItem v-if="enemy.contents.clues > 0" type="clue" :amount="enemy.contents.clues" />
    </div>
    <Treachery
      v-for="treacheryId in enemy.contents.treacheries"
      :key="treacheryId"
      :treachery="game.treacheries[treacheryId]"
      :game="game"
      :investigatorId="investigatorId"
      :attached="true"
      :class="{ 'small-treachery': atLocation }"
      @choose="$emit('choose', $event)"
    />
    <Asset
      v-for="assetId in enemy.contents.assets"
      :key="assetId"
      :asset="game.assets[assetId]"
      :game="game"
      :investigatorId="investigatorId"
      @choose="$emit('choose', $event)"
    />
    <template v-if="debug">
      <button @click="debugChoose({tag: 'DefeatEnemy', contents: [id, investigatorId, {tag: 'TestSource', contents:[]}]})">Defeat</button>
    </template>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, inject } from 'vue'
import { Game } from '@/arkham/types/Game'
import * as ArkhamGame from '@/arkham/types/Game'
import { Message, MessageType } from '@/arkham/types/Message'
import PoolItem from '@/arkham/components/PoolItem.vue'
import AbilityButton from '@/arkham/components/AbilityButton.vue'
import Treachery from '@/arkham/components/Treachery.vue';
import Asset from '@/arkham/components/Asset.vue';
import * as Arkham from '@/arkham/types/Enemy'

export default defineComponent({
  components: { PoolItem, Treachery, AbilityButton, Asset },
  props: {
    game: { type: Object as () => Game, required: true },
    enemy: { type: Object as () => Arkham.Enemy, required: true },
    investigatorId: { type: String, required: true },
    atLocation: { type: Boolean, default: false },
  },
  setup(props) {
    const image = computed(() => {
      const { cardCode } = props.enemy.contents;
      const baseUrl = process.env.NODE_ENV == 'production' ? "https://assets.arkhamhorror.app" : '';
      return `${baseUrl}/img/arkham/cards/${cardCode.replace('c', '')}.jpg`;
    })

    const id = computed(() => props.enemy.contents.id)

    const choices = computed(() => ArkhamGame.choices(props.game, props.investigatorId))

    const attackAction = computed(() => {
      return choices
        .value
        .findIndex((c) => c.tag === MessageType.ENEMY_ATTACK && c.contents[1] === id.value)
    })

    const labelAction = computed(() => {
      return choices
        .value
        .findIndex((c) => c.tag === MessageType.TARGET_LABEL && c.contents[0].contents === id.value)
    })

    const moveAction = computed(() => {
      return choices
        .value
        .findIndex((c) => c.tag === MessageType.ENEMY_MOVE && c.contents[0] === id.value)
    })

    const placeDoomAction = computed(() => {
      return choices
        .value
        .findIndex((c) => c.tag === MessageType.PLACE_DOOM && c.contents[0].contents === id.value)
    })

    const damageAction = computed(() => {
      const isRunDamage = choices.value.findIndex((c) => c.tag === MessageType.RUN
        && c.contents[0]
        && c.contents[0].tag === MessageType.ENEMY_DAMAGE
        && c.contents[0].contents[0] === id.value);

      if (isRunDamage !== -1) {
        return isRunDamage;
      }

      return choices
        .value
        .findIndex((c) => c.tag === MessageType.ENEMY_DAMAGE && c.contents[0] === id.value);
    })

    const cardAction = computed(() => {
      if (labelAction.value !== -1) {
        return labelAction.value;
      }

      if (attackAction.value !== -1) {
        return attackAction.value;
      }

      if (moveAction.value !== -1) {
        return moveAction.value;
      }

      if (placeDoomAction.value !== -1) {
        return placeDoomAction.value;
      }

      return damageAction.value;
    });


    const fightAction = computed(() => {
      return choices
        .value
        .findIndex((c) => c.tag === MessageType.FIGHT_ENEMY && c.contents[1] === id.value);
    })

    const engageAction = computed(() => {
      // This is for the rougarou, we look at the 2nd [1] item in the array because
      // the first is spending clues, there may be a different approach to take here
      const isRunEngage = choices.value.findIndex((c) => c.tag === MessageType.RUN
        && c.contents[1]
        && c.contents[1].tag === MessageType.ENGAGE_ENEMY
        && c.contents[1].contents[1] === id.value);

      if (isRunEngage !== -1) {
        return isRunEngage;
      }

      return choices
        .value
        .findIndex((c) => c.tag === MessageType.ENGAGE_ENEMY && c.contents[1] === id.value);
    })

    function isActivate(v: Message) {
      if (v.tag === 'EvadeLabel' && v.contents[0] === id.value) {
        return true
      }

      if (v.tag === 'FightEnemy' && v.contents[1] === id.value) {
        return true
      }

      if (v.tag !== 'UseAbility') {
        return false
      }

      const { tag, contents } = v.contents[1].source;

      if (tag === 'EnemySource' && contents === id.value) {
        return true
      }

      if (tag === 'ProxySource' && contents[0].tag === 'EnemySource' && contents[0].contents === id.value) {
        return true
      }

      return false
    }

    const abilities = computed(() => {
      return choices
        .value
        .reduce<number[]>((acc, v, i) => {
          if (v.tag === 'Run' && isActivate(v.contents[0])) {
            return [...acc, i];
          } else if (isActivate(v)) {
            return [...acc, i];
          }

          return acc;
        }, []);
    })

    const isExhausted = computed(() => props.enemy.contents.exhausted)

    const debug = inject('debug')
    const debugChoose = inject('debugChoose')

    return { id, debug, debugChoose, abilities, choices, engageAction, fightAction, cardAction, image, isExhausted }
  }
})
</script>

<style scoped lang="scss">
.small-treachery :deep(.card) {
  height: $card-width * 0.35;
}

.enemy--can-interact {
  border: 3px solid $select;
  border-radius: 15px;
  cursor: pointer;
}

.enemy {
  display: flex;
  flex-direction: column;
}

.button{
  margin-top: 2px;
  border: 0;
  color: #fff;
  border-radius: 4px;
  border: 1px solid #ff00ff;
}

.card {
  width: $card-width;
  max-width: $card-width;
  border-radius: 5px;
}

.pool {
  display: flex;
  flex-direction: row;
  height: 2em;
}

.button{
  margin-top: 2px;
  border: 0;
  color: #fff;
  border-radius: 4px;
  border: 1px solid #ff00ff;
}

.exhausted {
  transform: rotate(90deg);
  margin-left: 13px;
  margin-bottom: -10px;
  height: 80px;
  width: auto;
}
</style>
