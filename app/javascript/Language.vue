<template>
    <div>
        <label for="language">Language</label>
        <select id="language" name="etd[language]" class="form-control">
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
        this.languages = response.data
        this.degrees.unshift({ 'value': '', 'active': true, 'label': 'Select a Language', 'disabled': 'disabled', 'selected': 'selected' })
      })
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
