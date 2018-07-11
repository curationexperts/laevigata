<template>
<div>
  <label for="embargo-length">Requested Embargo Length</label>
  <select v-model="selectedEmbargo" name="etd[embargo_length]" class="form-control" id="embargo-length">
    <option v-for="length in lengths" :value="length.value" :selected="length.selected" :disabled="length.disabled">
        {{ length.value }}
      </option>
    </select>
  <div v-if="selectedEmbargo != 'None - open access immediately'">
    <label for="content-to-embargo">Content to Embargo</label>
    <select name="embargo_type" class="form-control" id="content-to-embargo">
      <option v-for="content in contents" :value="content.value" :disabled="content.disabled">
        {{ content.text }}
      </option>
    </select>
    </div>
    </div>
</div>
</template>

<script>
import Vue from "vue"
import { formStore } from './formStore'

export default {
  data() {
    return {
      selectedEmbargo: 'None - open access immediately'
    }
  },
  computed: {
    lengths () {
      return formStore.getEmbargoLengths()
    },
    contents () {
      return formStore.getEmbargoContents()
    }
 }
}
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
