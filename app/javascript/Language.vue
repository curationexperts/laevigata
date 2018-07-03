<template>
    <div>
        <label>Language</label>
        <select name="etd[language]" class="form-control">
            <option v-for="langauge in langauges" v-bind:value="langauge.id" 
            v-bind:key='langauge.id' v-if="langauge.active" :disabled="researchField.disabled"  
            :selected="researchField.selected">
                {{ langauge.label }}
            </option>
        </select>
    </div>
</template>

<script>
import Axios from "axios"
export default {
  data() {
    return {
      langaugesEndpoint: "/authorities/terms/local/languages_list",
      langauges: {}
    }
  },
  methods: {
    fetchData() {
      Axios.get(this.languagesEndpoint).then(response => {
        this.langauges = response.data
        this.langauges.unshift({ "value": "", "active": true, "label": "Select a Language", "disabled":"disabled" ,"selected": "selected"})

      })
    }
  },
  created() {
    this.fetchData()
  }
}
</script>