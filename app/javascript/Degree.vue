<template>
    <div>
        <label for="degree">Degree</label>
        <select id="degree" name="etd[degree]" class="form-control" aria-required="true" v-on:change="sharedState.setValid('My Program', false)">
            <option v-for="degree in degrees" v-bind:value="degree.id" v-bind:key='degree.id' :selected='degree.selected' :disabled='degree.disabled'>
                {{ degree.label }}
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
      degreeEndpoint: "/authorities/terms/local/degree",
      degrees: {},
      sharedState: formStore,
      selected: ''
    }
  },
  methods: {
    fetchData() {
      axios.get(this.degreeEndpoint).then(response => {
        this.degrees = this.getSelected(response.data)
      });
    },
    getSelected(data){
      var selected = this.sharedState.getSavedDegree()
      if (selected !== undefined) {
        //if we are editing etds, we might have a legacy term that is not in our list. Add it to the top and make it selected if so.
        if (this.sharedState.allowTabSave() === false){
          data.unshift({ "value": selected, "active": true, "label": selected, "selected": "selected"})
        }
        _.forEach(data, function(o){
          if (o.id == selected){
            o.selected = 'selected'
          }
        })
      } else {
        data.unshift({ "value": "", "active": true, "label": "Select a Degree", "disabled":"disabled" ,"selected": "selected"})
      }
      return data
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
