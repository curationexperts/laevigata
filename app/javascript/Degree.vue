<template>
    <div>
        <label for="degree">Degree</label>
        <select id="degree" name="etd[degree]" class="form-control">
            <option v-for="degree in degrees" v-bind:value="degree.id" v-bind:key='degree.id' :selected='degree.selected' :disabled='degree.disabled'>
                {{ degree.label }}
            </option>
        </select>
    </div>
</template>

<script>
import axios from "axios"
export default {
  data() {
    return {
      degreeEndpoint: "/authorities/terms/local/degree",
      degrees: {}
    }
  },
  methods: {
    fetchData() {
      axios.get(this.degreeEndpoint).then(response => {
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