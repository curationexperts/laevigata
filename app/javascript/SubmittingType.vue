<template>
    <div>
        <label>Submission Type</label>
        <select name="etd[submitting_type]" class="form-control">
            <option v-for="submittingType in submittingTypes" v-bind:value="submittingType.id" v-bind:key='submittingType.id' v-if="submittingType.active">
                {{ submittingType.label }}
            </option>
        </select>
    </div>
</template>

<script>
import Axios from "axios"
export default {
  data() {
    return {
      submittingTypeEndpoint: "/authorities/terms/local/submitting_type",
      submittingTypes: {}
    }
  },
  methods: {
    fetchData() {
      Axios.get(this.submittingTypeEndpoint).then(response => {
        this.submittingTypes = response.data
      });
    }
  },
  created() {
    this.fetchData()
  }
}
</script>