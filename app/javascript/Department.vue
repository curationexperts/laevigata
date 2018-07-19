<template>
  <div>
    <label for="department">Department</label>
    <select class="form-control" id="department" v-model="selected">
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
    };
  },
  watch: {
    selected() {
      formStore.setSelectedDepartment(this.selected)
      formStore.getSubfields()
    }
  }
};
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
