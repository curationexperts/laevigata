<template>
  <div>
    <label id="research-fields">Research Fields</label>
    <select aria-labelledby="research-fields" name="etd[research_field][]" aria-required="true" class="form-control">
      <option value="" active="true" selected="selected">Select a Research Field</option>
      <option v-for="researchField in researchFields" v-bind:value="researchField.id" v-bind:key='researchField.id'
      v-if="researchField.active" :selected="isSelected(researchField.id, 0)">
          {{ researchField.id }}
      </option>
    </select>
    <select aria-labelledby="research-fields" name="etd[research_field][]" class="form-control">
      <option value="" active="true" selected="selected">Select a Research Field</option>
      <option v-for="researchField in researchFields" v-bind:value="researchField.id" v-bind:key='researchField.id'
      v-if="researchField.active" :selected="isSelected(researchField.id, 1)">
          {{ researchField.id }}
      </option>
    </select>
    <select aria-labelledby="research-fields" name="etd[research_field][]" class="form-control">
      <option value="" active="true" selected="selected">Select a Research Field</option>
      <option v-for="researchField in researchFields" v-bind:value="researchField.id" v-bind:key='researchField.id'
      v-if="researchField.active" :selected="isSelected(researchField.id, 2)">
          {{ researchField.id }}
      </option>
    </select>
  </div>
</template>

<script>
import Axios from "axios"
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
      Axios.get(this.researchFieldsEndpoint).then(response => {
        this.researchFields = response.data
        this.setSelecteds(data)
      })
    },
    setSelecteds(data){
      var selectedResearchFields = this.sharedState.getSavedResearchFields()
        _.forEach(selectedResearchFields, function(selected){
        if (selected.length > 0) {
          _.forEach(data, function(o){
            if (o.id == selected){
              o.selected = 'selected'
              this.selectedFields.push(o)
            }
          })
        }
      })
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
