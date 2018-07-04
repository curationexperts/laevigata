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
export default {
  data() {
    return {
      graduationDatesEndpoint: "/authorities/terms/local/graduation_dates",
      graduationDates: {}
    }
  },
  methods: {
    fetchData() {
      Axios.get(this.graduationDatesEndpoint).then(response => {
        this.graduationDates = response.data
        this.graduationDates.unshift({ "value": "", "active": true, "label": "Select a Graduation Date", "disabled":"disabled" ,"selected": "selected"})
      });
    }
  },
  created() {
    this.fetchData()
  }
}
</script>