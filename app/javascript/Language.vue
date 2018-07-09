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
import axios from "axios"
import { formStore } from './formStore'
export default {
  data() {
    return {
      languagesEndpoint: formStore.languagesEndpoint,
      languages: formStore.languages
    }
  },
  methods: {
    fetchData() {
      axios.get(this.languagesEndpoint).then(response => {
        this.languages.push(response.data)
      })
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
