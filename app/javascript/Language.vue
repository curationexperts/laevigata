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
        //TODO: the model should return strings not arrays 
        if(_.has(this.sharedState.savedData, 'etd_id')){
          selected = selected[0]
        }
        this.selected = selected
      } else {
        data.unshift({ "value": "", "active": true, "label": "Select a Language", "disabled":"disabled" ,"selected": "selected"})
      }
      return data
    }
  },
  created() {
    this.fetchData()
  }
}
</script>
