<template>
  <div>
    <label for="school">School</label>
    <select id="school" class="form-control" v-model="selected" aria-required="true" v-on:change="clearDepartmentAndSubfields(), sharedState.setValid('About Me', false, ['My Program', 'Embargo'])">
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
    },
    // this only executes when the change event fires (user selects something)
    clearDepartmentAndSubfields(){
      this.sharedState.clearDepartment()
      this.sharedState.clearSubfields()
    }
  },
  mounted: function(){
    this.$nextTick(function () {
      //this needs to be saved or selected
      var selected = this.sharedState.getSavedOrSelectedSchool()
      if(selected === undefined){
        selected = ''
      }
      // TODO: fix model to return string not array
      if (_.has(this.sharedState.savedData, 'etd_id')){
        var schoolValue = this.sharedState.getSchoolValue(selected[0])
        selected = schoolValue
      }
      this.selected = selected
    })
  },
  watch: {
    selected() {
      //this executes when the component is rendered the first time and when the change event fires (user selects something)
      this.fetchData();
      if (this.sharedState.messySchoolState()){
        this.sharedState.errors.push({"schoolDeptMismatch": ''})
      }
    }
  }
};
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
