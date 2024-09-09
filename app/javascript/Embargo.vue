<template>
<div v-if="displayEmbargoFields()">
  <label for="embargo-length">Requested Embargo Length</label>
  <select v-model="selectedEmbargo" name="etd[embargo_length]" aria-required="true" class="form-control" id="embargo-length" v-on:change="sharedState.setSelectedEmbargo(selectedEmbargo), sharedState.setValid('Embargo', false)">
    <option v-for="length in embargoLengths" :value="length.value" :selected="length.selected" :disabled="length.disabled">
        {{ length.value }}
      </option>
  </select>
  <div v-if="selectedEmbargo != 'None - open access immediately'">
    <label for="content-to-embargo">Content to Embargo</label>
    <select name="etd[embargo_type]" v-model="selectedContent" class="form-control" id="content-to-embargo" v-on:change="sharedState.setSelectedEmbargoContents(selectedContent), sharedState.setValid('Embargo', false)">
      <option v-for="content in sharedState.getEmbargoContents()" :value="content.value" :disabled="content.disabled" :selected="content.selected">
        {{ content.text }}
      </option>
    </select>
  </div>
  <div v-else>
    <input type="hidden" name="etd[embargo_type]" id="content-to-embargo" value="open" />
  </div>
</div>

<div v-else>
  This form cannot be used to edit the embargo after graduation.  Please contact your department if you would like modify the embargo.
</div>
</template>

<script>
import Vue from "vue"
import { formStore } from './formStore'
import _ from 'lodash'

export default {
  data() {
    return {
      selectedContent: formStore.getSelectedEmbargoContents(),
      selectedEmbargo: formStore.getSelectedEmbargo(),
      embargoLengths: formStore.getEmbargoLengths(formStore.getSavedOrSelectedSchool()),
      sharedState: formStore
    }
  },
methods: {
  displayEmbargoFields () {
    if (this.sharedState.getDegreeAwarded()) {
      return false
    } else {
      return true
    }
  }
}
}
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
