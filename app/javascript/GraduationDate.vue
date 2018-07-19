<template>
    <div>
        <label>Graduation Date</label>
        <select name="etd[graduation_date]" class="form-control">
            <option v-for="graduationDate in graduationDates" v-bind:value="graduationDate.id"
            v-bind:key='graduationDate.id' v-if="graduationDate.active" :disabled="graduationDate.disabled"
            :selected="graduationDate.selected">
                {{ graduationDate.label }}
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
      graduationDatesEndpoint: "/authorities/terms/local/graduation_dates",
      graduationDates: {}
    }
  },
  methods: {
    fetchData() {
      Axios.get(this.graduationDatesEndpoint).then(response => {
        this.graduationDates = this.getSelected(response.data)
      });
    },
    getSelected(data){
      var selected = this.sharedState.getGraduationDate()
      if (selected !== undefined) {
        _.forEach(data, function(o){
          if (o.id == selected){
            o.selected = 'selected'
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
