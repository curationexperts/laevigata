<template>
    <div>
        <label for="language">Language</label>
        <select id="language" name="etd[language]" aria-required="true" class="form-control">
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
        _.forEach(data, function(o){
          if (o.id === selected){
            o.selected = 'selected'
          }
        })
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
