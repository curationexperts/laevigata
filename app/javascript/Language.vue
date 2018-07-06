<template>
    <div>
        <label>Language</label>
        <select name="etd[language]" class="form-control">
            <option v-for="language in languages" v-bind:value="language.id"
            v-bind:key='language.id' v-if="language.active" :disabled="language.disabled"
            :selected="language.selected">
                {{ language.label }}
            </option>
        </select>
    </div>
</template>

<script>
import Axios from "axios"
export default {
  data() {
    return {
      languagesEndpoint: "/authorities/terms/local/languages_list",
      languages: {}
    }
  },
  methods: {
    fetchData() {
      Axios.get(this.languagesEndpoint).then(response => {
        this.languages = response.data
        this.languages.unshift({ "value": "", "active": true, "label": "Select a Language", "disabled":"disabled" ,"selected": "selected"})

      })
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
