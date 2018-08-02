<template>
  <div>
    <label for="department">Department</label>
    <select class="form-control" id="department" v-model="selected" aria-required="true" v-on:change="sharedState.setValid('My Program', false)">
      <option v-for="department in sharedState.departments" v-bind:value="department.label" v-bind:key="department.label">
        {{ department.label }}
      </option>
    </select>
  </div>
</template>

<script>
import Vue from "vue";
import App from "./App";
import { formStore } from "./formStore";

export default {
  data() {
    return {
      selected: "",
      sharedState: formStore
    }
  },

  watch: {
    selected () {
      this.sharedState.clearDepartment()
      this.sharedState.clearSubfields()
      this.sharedState.setSelectedDepartment(this.selected)
      this.sharedState.getSubfields()
    }
  },
  // this keeps track of whether the user has a saved school, and can use it to load departments, or whether the user has a mismatch between a newly selected school and a saved one, in which case the user is told of the problem.
  beforeMount: function(){
    if (this.sharedState.messySchoolState()){
      this.sharedState.clearDepartments()
      this.sharedState.clearDepartment()
      this.sharedState.clearSubfields()
    } else if (this.sharedState.getSavedSchool()) {
      this.sharedState.loadDepartments()
    } else {
      // console.log('beforeMount else')
    }
  },
  mounted: function (){
    this.$nextTick(function () {
      //this is to handle the case of a saved department
      // console.log('mounted', this.sharedState.getSavedDepartment())
      this.selected = this.sharedState.getSavedDepartment()
    })
  }
};
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
