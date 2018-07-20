<template>
    <div>
        <label for="submitting-type">Submission Type</label>
        <select id="submitting-type" name="etd[submitting_type]" aria-required="true" class="form-control">
            <option v-for="submittingType in submittingTypes" v-bind:value="submittingType.id" 
            v-bind:key='submittingType.id' v-if="submittingType.active" :disabled="submittingType.disabled"  
            :selected="submittingType.selected">
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
        this.submittingTypes.unshift({ "value": "", "active": true, "label": "Select a Submission Type", "disabled":"disabled" ,"selected": "selected"})

      });
    }
  },
  created() {
    this.fetchData()
  }
}
</script>