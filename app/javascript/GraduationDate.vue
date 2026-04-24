<template>
    <div>
        <label for="graduation-date">Graduation Date</label>
        <select id="graduation-date" name="etd[graduation_date]" class="form-control" aria-required="true">
            <template v-for="graduationDate in graduationDates">
                <option v-bind:value="graduationDate.id"
                        v-bind:disabled="graduationDate.disabled"
                        v-bind:selected="graduationDate.selected">
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
    fetchData() {
      axios.get(this.graduationDatesEndpoint).then(response => {
        this.graduationDates = this.getSelected(response.data)
      }).catch(e => {
        console.log(e)
      })
    },
    getSelected(data){
      // Add a placeholder option at the top of the list
      data.unshift({ "value": "", "active": true, "label": "Select a Graduation Date", "disabled":"disabled" })

      // If a previously saved option exists, set it as active and selected
      // even if the saved option was inactive
      this.selected = this.sharedState.getGraduationDate()
      const selected_index = Math.max(0, data.findIndex((option) => option.id === this.selected))
      data[selected_index].active = true
      data[selected_index].selected = true

      // Filter out inactive options when appropriate
      return showInactive() ? data : data.filter((option) => option.active)
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
