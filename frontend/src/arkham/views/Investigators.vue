<template>
  <div class="cards">
    <img class="card" v-for="card in cards" :key="card.cardCode" :src="image(card)" />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';
import { fetchInvestigators } from '@/arkham/api';
import * as Arkham from '@/arkham/types/Investigator';

export default defineComponent({
  setup() {
    const cards = ref<Arkham.Investigator[]>([])
    const ready = ref(false)
    const baseUrl = process.env.NODE_ENV == 'production' ? "https://assets.arkhamhorror.app" : '';

    fetchInvestigators().then((response) => {
      cards.value = response.sort((a, b) => {
        if (a.contents.id < b.contents.id) {
          return -1
        }

        if (a.contents.id > b.contents.id) {
          return 1
        }

        return 0
      })
      ready.value = true
    })

    const image = (card: Arkham.Investigator) => `${baseUrl}/img/arkham/cards/${card.contents.id.replace('c', '')}.jpg`

    return { cards, ready, image }
  }
})
</script>

<style scoped lang="scss">
.card {
  width: 300px;
  margin: 10px;
  border-radius: 10px;
}

.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  padding: 10px;
}
</style>
