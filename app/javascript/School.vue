<template>
  <div>
    <label for="school">School</label>
    <select id="school" class="form-control" v-model="selected" aria-required="true">
      <option v-for="school in this.sharedState.schools.options" v-bind:value="school.value" v-bind:key='school.value' :selected='school.selected' :disabled='school.disabled'>
        {{ school.text }}
      </option>
    </select>
  </div>
</template>

<script>
import Vue from "vue"
import axios from "axios"
import VueAxios from "vue-axios"
import App from "./App"
import { formStore } from './formStore'

export default {
  data() {
    return {
      sharedState: formStore,
      selected: ''
    }
  },
  methods: {
    fetchData() {
      var selectedSchool = this.sharedState.schools[this.selected];
      this.sharedState.setSelectedSchool(this.selected)
      this.sharedState.getDepartments(selectedSchool)
    }
  },
  mounted: function(){
    //This is the right hook in the dom loading sequence to get the saved data
    this.$nextTick(function () {
      var selected = this.sharedState.getSchoolOptionValue()

      if(selected === undefined){
        selected = ''
      }
      this.selected = selected
    })
  },
  watch: {
    selected() {
      this.fetchData();
      this.sharedState.clearSubfields()
    }
  }
};
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
