<template>
    <button
      v-if="display"
      class="button"
      :class="classObject"
      @click="$emit('choose', ability)"
      >{{abilityLabel}}</button>
</template>

<script lang="ts">
import { defineComponent, computed, ComputedRef } from 'vue';
import { Cost } from '@/arkham/types/Cost';
import { Message } from '@/arkham/types/Message';

export default defineComponent({
  props: {
    ability: { type: Object as () => Message, required: true }
  },

  setup(props) {
    const ability: ComputedRef<Message> = computed(() => props.ability.tag == 'Run' ? props.ability.contents[0] : props.ability)

    const isAction = (action: string) => {
      if (ability.value.tag === "EvadeLabel") {
        return action === "Evade"
      }
      if (ability.value.tag === "FightEnemy") {
        return action === "Fight"
      }
      const {tag} = ability.value.contents[1].type
      if (tag !== "ActionAbility" && tag !== "ActionAbilityWithBefore" && tag !== "ActionAbilityWithSkill") {
        return false
      }
      const maction = ability.value.contents[1].type.contents[0]
      return maction === action
    }

    const isInvestigate = computed(() => isAction("Investigate"))
    const isFight = computed(() => isAction("Fight") || ability.value.tag == "FightEnemy")
    const isEvade = computed(() => isAction("Evade"))
    const isEngage = computed(() => isAction("Engage"))
    const display = computed(() => !isAction("Move"))
    const isSingleActionAbility = computed(() => {
      if (ability.value.tag !== "UseAbility") {
        return false
      }
      const {tag} = ability.value.contents[1].type
      if (tag !== "ActionAbility" && tag !== "ActionAbilityWithBefore" && tag !== "ActionAbilityWithSkill") {
        return false
      }
      const costIndex = tag === "ActionAbility" ? 1 : 2
      const { contents } = ability.value.contents[1].type.contents[costIndex]
      if (typeof contents?.some == 'function') {
        return contents.some((cost: Cost) => cost.tag == "ActionCost" && cost.contents == 1)
      } else {
        return contents === 1
      }
    })
    const isDoubleActionAbility = computed(() => {
      if (ability.value.tag !== "UseAbility") {
        return false
      }
      const {tag} = ability.value.contents[1].type
      if (tag !== "ActionAbility" && tag !== "ActionAbilityWithBefore" && tag !== "ActionAbilityWithSkill") {
        return false
      }
      const costIndex = tag === "ActionAbility" ? 1 : 2
      const { contents } = ability.value.contents[1].type.contents[costIndex]
      if (typeof contents?.some == 'function') {
        return contents.some((cost: Cost) => cost.tag == "ActionCost" && cost.contents == 2)
      } else {
        return contents === 2
      }
    })

    const isTripleActionAbility = computed(() => {
      if (ability.value.tag !== "UseAbility") {
        return false
      }
      const {tag} = ability.value.contents[1].type
      if (tag !== "ActionAbility" && tag !== "ActionAbilityWithBefore" && tag !== "ActionAbilityWithSkill") {
        return false
      }
      const costIndex = tag === "ActionAbility" ? 1 : 2
      const { contents } = ability.value.contents[1].type.contents[costIndex]
      if (typeof contents?.some == 'function') {
        return contents.some((cost: Cost) => cost.tag == "ActionCost" && cost.contents == 3)
      } else {
        return contents === 3
      }
    })

    const isObjective = computed(() => ability.value.tag === "UseAbility" && ability.value.contents[1].type.tag === "Objective")
    const isFastActionAbility = computed(() => ability.value.tag === "UseAbility" && ability.value.contents[1].type.tag === "FastAbility")
    const isReactionAbility = computed(() => ability.value.tag === "UseAbility" && (ability.value.contents[1].type.tag === "ReactionAbility" || ability.value.contents[1].type.tag === "LegacyReactionAbility"))
    const isForcedAbility = computed(() => ability.value.tag === "UseAbility" && ability.value.contents[1].type.tag === "ForcedAbility")

    const isNeutralAbility = computed(() => !(isInvestigate.value || isFight.value || isEvade.value || isEngage.value))

    const abilityLabel = computed(() => {
      if (ability.value.tag === "EvadeLabel") {
        return "Evade"
      }

      if (ability.value.tag === "FightEnemy") {
        return "Fight"
      }

      if (isForcedAbility.value === true) {
        return "Forced"
      }

      if (isObjective.value === true) {
        return "Objective"
      }

      if (isReactionAbility.value === true) {
        return ""
      }

      const label = ability.value.tag === 'Run'
        ? ability.value.contents[0].contents[1].type.contents[0]
        : ability.value.contents[1].type.contents[0]

      if (label) {
        return typeof label === "string" ? label : label.contents
      }

      return ""
    })


    const classObject = computed(() => {
      return {
        'ability-button': isSingleActionAbility.value && isNeutralAbility.value,
        'double-ability-button': isDoubleActionAbility.value,
        'triple-ability-button': isTripleActionAbility.value,
        'fast-ability-button': isFastActionAbility.value,
        'reaction-ability-button': isReactionAbility.value,
        'forced-ability-button': isForcedAbility.value,
        'investigate-button': isInvestigate.value,
        'fight-button': isFight.value,
        'evade-button': isEvade.value,
        'engage-button': isEngage.value,
        'objective-button': isObjective.value,
      }
    })

    return {
      display,
      classObject,
      abilityLabel,
      isSingleActionAbility,
      isDoubleActionAbility,
      isTripleActionAbility,
      isFastActionAbility,
      isReactionAbility,
      isForcedAbility,
    }
  }
})
</script>

<style lang="scss" scoped>
.button{
  margin-top: 2px;
  color: #fff;
  cursor: pointer;
  border-radius: 4px;
  background-color: #555;
}

.objective-button {
  background-color: #465550;
}

.investigate-button {
  background-color: #40263A;
  &:before {
    font-family: "arkham";
    content: "\0046";
    margin-right: 5px;
  }
}

.fight-button {
  background-color: #8F5B41;
  &:before {
    font-family: "Arkham";
    content: "\0044";
    margin-right: 5px;
  }
}

.evade-button {
  background-color: #576345;
  &:before {
    font-family: "Arkham";
    content: "\0053";
    margin-right: 5px;
  }
}

.engage-button {
  background-color: #555;
  &:before {
    font-family: "Arkham";
    content: "\0048";
    margin-right: 5px;
  }
}

.ability-button {
  background-color: #555;
  &:before {
    font-family: "arkham";
    content: "\0049";
    margin-right: 5px;
  }
}

.double-ability-button {
  background-color: #555;
  &:before {
    font-family: "arkham";
    content: "\0049\0049";
    margin-right: 5px;
  }
}

.triple-ability-button {
  background-color: #555;
  &:before {
    font-family: "arkham";
    content: "\0049\0049\0049";
    margin-right: 5px;
  }
}

.fast-ability-button {
  background-color: #555;
  &:before {
    font-family: "arkham";
    content: "\0075";
    margin-right: 5px;
  }
}

.forced-ability-button {
  background-color: #222;
  color: #fff;
}

.reaction-ability-button {
  background-color: #A02ECB;
  &:before {
    font-family: "arkham";
    content: "\0059";
    margin-right: 5px;
  }
}
</style>
