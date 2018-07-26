<template>
  <div>
    <label for="department">Department</label>
    <select class="form-control" id="department" v-model="selected" aria-required="true">
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
    selected() {
      this.sharedState.clearDepartment()
      this.sharedState.clearSubfields()
      this.sharedState.setSelectedDepartment(this.selected)
      this.sharedState.getSubfields()
    }
  },
  mounted: function(){
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
