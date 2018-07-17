<template>
    <div>
        <label>Research Fields</label>
        <select name="etd[research_field][]" class="form-control">
            <option v-for="researchField in researchFields" v-bind:value="researchField.id" v-bind:key='researchField.id' 
            v-if="researchField.active"  
            :selected="researchField.selected">
                {{ researchField.id }}
            </option>
        </select>
        <select name="etd[research_field][]" class="form-control">
            <option v-for="researchField in researchFields" v-bind:value="researchField.id" v-bind:key='researchField.id' 
            v-if="researchField.active" :selected="researchField.selected">
                {{ researchField.id }}
            </option>
        </select>
           <select name="etd[research_field][]" class="form-control">
            <option v-for="researchField in researchFields" v-bind:value="researchField.id" v-bind:key='researchField.id' 
            v-if="researchField.active" :selected="researchField.selected">
                {{ researchField.id }}
            </option>
        </select>
    </div>
</template>

<script>
import Axios from "axios"
export default {
  data() {
    return {
      researchFieldsEndpoint: "/authorities/terms/local/research_fields",
      researchFields: {}
    }
  },
  methods: {
    fetchData() {
      Axios.get(this.researchFieldsEndpoint).then(response => {
        this.researchFields = response.data
        this.researchFields.unshift({ "value": "", "active": true, "label": "Select a Submission Type", "disabled":"disabled" ,"selected": "selected"})
      })
    }
  },
  created() {
    this.fetchData()
  }
}
</script>