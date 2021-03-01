<template>
    <div>
        <label for="graduation-term">Graduation Term</label>
        <select id="graduation-term" name="etd[graduation_term]" class="form-control" aria-required="true">
            <option v-for="graduationTerm in graduationTerms" v-bind:value="graduationTerm.id"
            v-bind:key='graduationTerm.id' v-if="graduationTerm.active" :disabled="graduationTerm.disabled"
            :selected="graduationTerm.selected">
                {{ graduationTerm.label }}
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
      graduationTermsEndpoint: "/authorities/terms/local/graduation_terms",
      graduationTerms: {}
    }
  },
  methods: {
    fetchData() {
      axios.get(this.graduationTermsEndpoint).then(response => {
        this.graduationTerms = this.getSelected(response.data)
      }).catch(e => {
        console.log(e)
      })
    },
    getSelected(data){
      var selected = this.sharedState.getGraduationTerm()
      if (selected !== undefined) {
        _.forEach(data, function(o){
          if (o.id == selected){
            o.selected = 'selected'
            o.active = true
          }
        })
      } else {
        data.unshift({ "value": "", "active": true, "label": "Select a Graduation Term", "disabled":"disabled", "selected":"selected" })
      }
      return data
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
