<template>
<div>
  <label for="embargo-length">Requested Embargo Length</label>
  <select v-model="selectedEmbargo" name="etd[embargo_length]" aria-required="true" class="form-control" id="embargo-length" v-on:change="sharedState.setValid('Embargo', false)">
    <option v-for="length in lengths" :value="length.value" :selected="length.selected" :disabled="length.disabled">
        {{ length.value }}
      </option>
    </select>
  <div v-if="selectedEmbargo != 'None - open access immediately'">
    <label for="content-to-embargo">Content to Embargo</label>
    <select name="etd[embargo_type]" v-model="selectedContent" class="form-control" id="content-to-embargo" v-on:change="sharedState.setValid('Embargo', false)">
      <option v-for="content in contents" :value="content.value" :disabled="content.disabled" :selected="content.selected">
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
import _ from 'lodash'

export default {
  data() {
    return {
      selectedEmbargo: 'None - open access immediately',
      selectedContent: '',
      sharedState: formStore
    }
  },
  methods: {
    setSelected(collection, selected){
      var match = false
      //ensuring we have this item in our current school's lengths and types
      if (selected !== undefined) {
        _.forEach(collection, function(item) {
          if (item.value === selected){
            match = true
            item.selected = 'selected'
          }
        });
      }
      if (match === true) {
        return selected
      }
    }
  },
  computed: {
    lengths () {
      var lengths = formStore.getEmbargoLengths()
      var selected = formStore.savedData['embargo_length']
      var selectedLength = this.setSelected(lengths, selected)

      if (selectedLength  !== undefined){
        this.selectedEmbargo = selectedLength
      }
      return lengths
    },
    contents () {
      var contents = formStore.getEmbargoContents()
      var selected = formStore.savedData['embargo_type']
      var selectedContent = this.setSelected(contents, selected)

      if (selectedContent !== undefined){
        this.selectedContent = selectedContent
      }
      return contents
    }
  }
}
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
