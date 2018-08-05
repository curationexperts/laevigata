<template>
  <div>
    <label for="department">Department</label>
    <select class="form-control" id="department" v-model="selected" aria-required="true">
      <option v-for="department in sharedState.departments" v-bind:value="department.label" v-bind:key="department.label" :disabled="department.disabled">
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
      selected: 'Select a Department',
      sharedState: formStore
    }
  },
  watch: {
    selected () {
      if (this.sharedState.getSelectedDepartment() !== undefined) {
        this.sharedState.loadDepartments()
        this.sharedState.setSelectedDepartment(this.selected)
        this.sharedState.getSubfields()
      } else {
        this.sharedState.clearDepartment()
        this.sharedState.clearSubfields()
        
      }
    }
  },
  mounted: function (){
    this.$nextTick(function () {
      this.sharedState.setValid('My Program', false)
      if (this.sharedState.getSelectedDepartment()) {
        this.selected = this.sharedState.getSelectedDepartment()  
      } else {
        this.selected = 'Select a Department'
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
