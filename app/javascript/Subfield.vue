<template>
  <div v-if="formStore.subfields.length > 0">
    <label for="subfield">Subfield</label>
    <select id="subfield" name="etd[subfield]" class="form-control" v-model="selected">
      <option v-for="(option) in formStore.subfields"
              v-bind:value="option.id"
              v-bind:disabled="option.disabled">{{ option.label }}</option>
    </select>
  </div>
</template>

<script>
import { formStore } from './formStore'

export default {
  computed: {
    formStore() {
      return formStore
    }
  },
  data() {
    return {
      selected: formStore.getSubfield()
    }
  },
  beforeCreate() {
    formStore.getSubfields()
  },
  watch: {
    selected(newSubfield) {
      formStore.setSubfield(newSubfield)
    }
  }
}
</script>
