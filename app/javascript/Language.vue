<template>
    <div>
        <label for="language">Language</label>
        <select id="language" v-model="selected" name="etd[language]" aria-required="true" class="form-control" v-on:change="sharedState.setValid('My Etd', false)">
            <option v-for="language in languages" v-bind:value="language.id"
            v-bind:key='language.id' v-if="language.active"
            :selected="language.selected" :disabled="language.disabled">
                {{ language.label }}
            </option>
        </select>
    </div>
</template>

<script>
import axios from "axios"
import { formStore } from './formStore'
import _ from 'lodash'
export default {
  data() {
    return {
      languagesEndpoint: formStore.languagesEndpoint,
      languages: {},
      sharedState: formStore,
      selected: ''
    }
  },
  methods: {
    fetchData() {
      axios.get(this.languagesEndpoint).then(response => {
        this.languages = this.getSelected(response.data)
      })
    },
    getSelected(data){
      var selected = this.sharedState.getSavedLanguage()
      if (selected !== undefined) {
        if (this.sharedState.allowTabSave() === false){
          data.unshift({ "value": selected, "active": true, "label": selected, "selected": "selected"})
        }
        this.selected = selected
      } else {
        this.selected = 'Select a Language'
        data.unshift({ "value": "Select a Language", "active": true, "label": "Select a Language", "disabled":"disabled" ,"selected": "selected"})
      }
      return data
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
