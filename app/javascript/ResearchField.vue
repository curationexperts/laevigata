<template>
  <div>
    <label id="research-fields">Research Fields</label>
    <div aria-live="polite" class="alert alert-info"><span class="glyphicon glyphicon-info-sign"></span> One research field is required, but you may select up to three.</div>
    <select aria-labelledby="research-fields" name="etd[research_field][]" aria-required="true" class="form-control" v-on:change="sharedState.setValid('Keywords', false)">
      <option value="" active="true" selected="selected">Select a Research Field</option>
      <option v-for="(researchField, i) in researchFields" v-bind:value="researchField.id" v-bind:key="`a-${researchField.id}-${i}`"
      v-if="researchField.active" :selected="isSelected(researchField.id, 0)">
          {{ researchField.id }}
      </option>
    </select>
    <select aria-labelledby="research-fields" name="etd[research_field][]" class="form-control" v-on:change="sharedState.setValid('Keywords', false)">
      <option value="" active="true" selected="selected">Select a Research Field</option>
  <option v-for="(researchField, i) in researchFields" v-bind:value="researchField.id" v-bind:key="`b-${researchField.id}-${i}`"
      v-if="researchField.active" :selected="isSelected(researchField.id, 1)">
          {{ researchField.id }}
      </option>
    </select>
    <select aria-labelledby="research-fields" name="etd[research_field][]" class="form-control" v-on:change="sharedState.setValid('Keywords', false)">
      <option value="" active="true" selected="selected">Select a Research Field</option>
   <option v-for="(researchField, i) in researchFields" v-bind:value="researchField.id" v-bind:key="`c-${researchField.id}-${i}`"
      v-if="researchField.active" :selected="isSelected(researchField.id, 2)">
          {{ researchField.id }}
      </option>
    </select>
  </div>
</template>

<script>
import axios from "axios"
import { formStore } from './formStore'
import _ from 'lodash'

export default {
  data() {
    return {
      sharedState: formStore,
      selected: '',
      selectedFields: [],
      researchFieldsEndpoint: "/authorities/terms/local/research_fields",
      researchFields: {}
    }
  },
  methods: {
    isSelected(id, index){
      return id === this.sharedState.getSavedResearchField(index) ? true : false
    },
    fetchData() {
      axios.get(this.researchFieldsEndpoint).then(response => {
        var data = response.data
        if(this.sharedState.allowTabSave() === false){
          //TODO: confirm this value is ok for label in the absence of a real one
          _.forEach(this.sharedState.getSavedResearchFields(), (srf) => {
            data.unshift({'id': srf, 'active': true, 'label': srf})
          } )
        }
        this.researchFields = data
      })
    },
  },
  created() {
    this.fetchData()
    this.sharedState.getSavedResearchFields()
  }
}
</script>
