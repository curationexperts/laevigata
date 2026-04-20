<template>
    <div>
        <label for="graduation-date">Graduation Date</label>
        <select id="graduation-date" name="etd[graduation_date]" class="form-control" aria-required="true">
            <template v-for="graduationDate in graduationDates">
                <option v-if="graduationDate.active || showInactive()"
                        v-bind:value="graduationDate.id"
                        :disabled="graduationDate.disabled"
                        :selected="graduationDate.selected">
                    {{ labelFor(graduationDate.label, graduationDate.active) }}
                </option>
            </template>
        </select>
    </div>
</template>

<script>
import axios from "axios"
import { formStore } from './formStore'
import {labelFor, showInactive} from './lib/formHelpers'
import _ from 'lodash'
export default {
  data() {
    return {
      sharedState: formStore,
      selected: '',
      graduationDatesEndpoint: "/authorities/terms/local/graduation_dates",
      graduationDates: {}
    }
  },
  methods: {
    labelFor,
    showInactive,
    fetchData() {
      axios.get(this.graduationDatesEndpoint).then(response => {
        this.graduationDates = this.getSelected(response.data)
      }).catch(e => {
        console.log(e)
      })
    },
    getSelected(data){
      const selected = this.sharedState.getGraduationDate()
      if (selected !== undefined) {
        _.forEach(data, function(o){
          if (o.id === selected){
            o.selected = 'selected'
            o.active = true
          }
        })
      } else {
        data.unshift({ "value": "", "active": true, "label": "Select a Graduation Date", "disabled":"disabled", "selected":"selected" })
      }
      return data
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
