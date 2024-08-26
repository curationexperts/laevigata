<template>
    <div>
        <label for="submitting-type">Submission Type</label>
        <select id="submitting-type" name="etd[submitting_type]" aria-required="true" class="form-control" v-on:change="sharedState.setValid('My Program', false)">
            <option v-for="submittingType in submittingTypes"
                    v-bind:value="submittingType.id"
                    v-bind:key='submittingType.id'
                    v-if="submittingType.active"
                    :disabled="submittingType.disabled"
                    :selected="submittingType.selected">
                {{ submittingType.label }}
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
      submittingTypeEndpoint: "/authorities/terms/local/submitting_type",
      submittingTypes: {}
    }
  },
  methods: {
    fetchData() {
      axios.get(this.submittingTypeEndpoint).then(response => {
        this.submittingTypes = this.getSelected(response.data)
      })
    },
    getSelected(data){
      var selected = this.sharedState.getSubmittingType()
      if (selected !== undefined) {
        if (this.sharedState.allowTabSave() === false){
          data.unshift({ "value": selected, "active": true, "label": selected, "selected": "selected"})
        }
        _.forEach(data, function(o){
          if (o.id == selected){
            o.selected = 'selected'
          }
        })
      } else {
        data.unshift({ "value": "", "active": true, "label": "Select a Submission Type", "disabled":"disabled" ,"selected": "selected"})
      }
      return data
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
