<template>
  <div v-if="sharedState.allowTabSave()">
    <!-- TODO: adding v-model='selected' enables the selected value to appear in the case of an ipe_etd, but it will not without it, with a hyrax etd. But we should refactor for a better solution. -->
    <label for="department">Department</label>
    <select name="etd[department]" class="form-control" id="department" aria-required="true" v-model="selected" v-on:change="sharedState.clearSubfields(), sharedState.setSelectedDepartment(selected), sharedState.setValid('My Program', false)">
      <option v-for="department in sharedState.departments" v-bind:value="department.label" v-bind:key="department.label" :disabled="department.disabled">
        {{ department.label }}
      </option>
    </select>
  </div>
  <div v-else>
    <label for="department">Department</label>
    <select name="etd[department]" class="form-control" id="department" aria-required="true" v-on:change="sharedState.clearSubfields(), sharedState.setSelectedDepartment(selected), sharedState.setValid('My Program', false)">
      <option v-for="department in sharedState.departments" v-bind:value="department.label" v-bind:key="department.label" :disabled="department.disabled">
        {{ department.label }}
      </option>
    </select>
  </div>
</template>

<script>
import { formStore } from "./formStore";
import _ from 'lodash'

export default {
  data() {
    return {
      selected: "",
      sharedState: formStore
    }
  },

  watch: {
    selected () {
      this.sharedState.getSavedOrSelectedDepartment()
      this.sharedState.getSubfields()
    }
  },
  beforeMount: function(){
      this.sharedState.loadDepartments()
      this.selected = this.sharedState.getSavedOrSelectedDepartment()
  },
  mounted: function (){
    this.$nextTick(function () {
      //this is to handle the case of a saved department
      if (_.has(this.sharedState.savedData, 'etd_id')){
        var selectedArray = this.sharedState.getSavedOrSelectedDepartment()
        this.selected = selectedArray[0]
      } else {
        this.selected = this.sharedState.getSavedOrSelectedDepartment()
        if (!this.selected) {
          this.selected = 'Select a Department'
        }
      }
    })
  }
};
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
