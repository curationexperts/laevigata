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
      if (this.sharedState.getSavedDepartment() !== undefined) {
        this.sharedState.loadDepartments()
        this.sharedState.setSelectedDepartment(this.selected)
        this.sharedState.getSubfields()
      } else {
        this.sharedState.clearDepartment()
        this.sharedState.clearSubfields()
      }
    }
  },
  beforeMount: function(){
    if (!this.sharedState.savedAndSelectedSchoolsMatch()){
      this.sharedState.clearDepartments()
      this.sharedState.clearDepartment()
      this.sharedState.clearSubfields()
    }
  },
  mounted: function (){
    this.$nextTick(function () {
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
