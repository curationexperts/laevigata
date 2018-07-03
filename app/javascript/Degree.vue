<template>
    <div>
        <label>Degree</label>
        <select name="etd[degree]" class="form-control">
            <option v-for="degree in degrees" v-bind:value="degree.id" v-bind:key='degree.label' :selected='degree.selected' :disabled='degree.disabled'>
                {{ degree.label }}
            </option>
        </select>
    </div>
</template>

<script>
import Axios from "axios"
export default {
  data() {
    return {
      degreeEndpoint: "/authorities/terms/local/degree",
      degrees: {}
    }
  },
  methods: {
    fetchData() {
      Axios.get(this.degreeEndpoint).then(response => {
        this.degrees = response.data
        this.degrees.unshift({ "value": "", "active": true, "label": "Select a Degree", "disabled":"disabled" ,"selected": "selected"})

      });
    }
  },
  created() {
    this.fetchData()
  }
}
</script>