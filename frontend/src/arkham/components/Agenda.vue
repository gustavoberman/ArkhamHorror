<template>
  <div class="agenda-container">
    <img
      :class="{ 'agenda--can-progress': interactAction !== -1 }"
      class="card card--sideways"
      @click="$emit('choose', interactAction)"
      :src="image"
    />
    <AbilityButton
      v-for="ability in abilities"
      :key="ability"
      :ability="choices[ability]"
      :data-image="image"
      @click="$emit('choose', ability)"
      />
    <Treachery
      v-for="treacheryId in agenda.contents.treacheries"
      :key="treacheryId"
      :treachery="game.treacheries[treacheryId]"
      :game="game"
      :investigatorId="investigatorId"
      @choose="$emit('choose', $event)"
    />
    <div class="pool">
      <PoolItem
        type="doom"
        :amount="agenda.contents.doom"
      />

      <template v-if="debug">
        <button @click="debugChoose({tag: 'PlaceDoom', contents: [{'tag': 'AgendaTarget', 'contents': id}, 1]})">+</button>
      </template>
    </div>

    <button v-if="cardsUnder.length > 0" class="view-cards-under-button" @click="showCardsUnderAgenda">{{viewUnderLabel}}</button>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref } from 'vue';
import { Game } from '@/arkham/types/Game';
import { Card } from '@/arkham/types/Card'
import * as ArkhamGame from '@/arkham/types/Game';
import { Message, MessageType } from '@/arkham/types/Message';
import AbilityButton from '@/arkham/components/AbilityButton.vue';
import PoolItem from '@/arkham/components/PoolItem.vue';
import Treachery from '@/arkham/components/Treachery.vue';
import * as Arkham from '@/arkham/types/Agenda';

export default defineComponent({
  components: { PoolItem, AbilityButton, Treachery },
  props: {
    agenda: { type: Object as () => Arkham.Agenda, required: true },
    game: { type: Object as () => Game, required: true },
    cardsUnder: { type: Array as () => Card[], required: true },
    investigatorId: { type: String, required: true }
  },
  setup(props, context) {
    const id = computed(() => props.agenda.contents.id)
    const image = computed(() => {
      const baseUrl = process.env.NODE_ENV == 'production' ? "https://assets.arkhamhorror.app" : '';

      if (props.agenda.contents.flipped) {
        return `${baseUrl}/img/arkham/cards/${id.value.replace('c', '')}b.jpg`;
      }

      return `${baseUrl}/img/arkham/cards/${id.value.replace('c', '')}.jpg`;
    })

    const choices = computed(() => ArkhamGame.choices(props.game, props.investigatorId))

    const viewingUnder = ref(false)
    const toggleUnder = function() { viewingUnder.value = !viewingUnder.value }
    const viewUnderLabel = computed(() => viewingUnder.value ? "Close" : `${props.cardsUnder.length} Cards Underneath`)

    function canInteract(c: Message): boolean {
      switch (c.tag) {
        case MessageType.ADVANCE_AGENDA:
          return true;
        case MessageType.ATTACH_TREACHERY:
          return c.contents[1].contents == id.value;
        case MessageType.TARGET_LABEL:
          return c.contents[0].tag === "AgendaTarget" && c.contents[0].contents === id.value
        case MessageType.RUN:
          return c.contents.some((c1: Message) => canInteract(c1));
        default:
          return false;
      }
    }

    const interactAction = computed(() => choices.value.findIndex(canInteract));

    function isAbility(v: Message) {
     return (v.tag === 'UseAbility' && v.contents[1].source.tag === 'AgendaSource' && v.contents[1].source.contents === id.value)
    }

    const abilities = computed(() => {
      return choices.value
        .reduce<number[]>((acc, v, i) => {
          if (v.tag === 'Run' && isAbility(v.contents[0])) {
            return [...acc, i];
          } else if (isAbility(v)) {
            return [...acc, i];
          }

          return acc;
        }, [])
    })

    const cardsUnder = computed(() => props.cardsUnder)
    const showCardsUnderAgenda = (e: Event) => context.emit('show', e, cardsUnder, 'Cards Under Agenda', false)

    const debug = inject('debug')
    const debugChoose = inject('debugChoose')

    return { toggleUnder, viewUnderLabel, showCardsUnderAgenda, debug, debugChoose, abilities, choices, interactAction, image, id }
  }
})
</script>

<style scoped lang="scss">
.card {
  width: $card-width;
  -webkit-box-shadow: 0 3px 6px rgba(0, 0, 0, 0.23), 0 3px 6px rgba(0, 0, 0, 0.53);
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.23), 0 3px 6px rgba(0, 0, 0, 0.53);
  border-radius: 6px;
  margin: 2px;
}

.card--sideways {
  width: auto;
  height: $card-width;
}

.agenda-container {
  display: flex;
  flex-direction: column;
}

.agenda--can-progress {
  border: 3px solid #ff00ff;
  border-radius: 8px;
  cursor: pointer;
}

.pool {
  display: flex;
  flex-direction: row;
  height: 2em;
  justify-content: flex-start;
}

.button{
  margin-top: 2px;
  border: 0;
  color: #fff;
  border-radius: 4px;
  border: 1px solid #ff00ff;
}

.agenda :deep(.treachery) {
  object-fit: cover;
  object-position: 0 -74px;
  height: 68px;
  margin-top: 2px;
}
</style>
