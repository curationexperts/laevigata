<template>
  <div>
    <label>School</label>
    <select class="form-control" v-model="selected" id="school">
      <option v-for="option in options" v-bind:value="option.value" v-bind:key='option.value' :selected='option.selected' :disabled='option.disabled'>
        {{ option.text }}
      </option>
    </select>
    <label>Department</label>
    <select class="form-control" id="department">
      <option v-for="department in departments" v-bind:value="department.label" v-bind:key="department.label">
        {{ department.label }}
      </option>
    </select>
  </div>
</template>

<script>
import Vue from "vue";
import axios from "axios";
import VueAxios from "vue-axios";
import App from "./App";

export default {
  data() {
    return {
      schools: {
        candler:
          "/authorities/terms/local/candler_programs",
        emory: "/authorities/terms/local/emory_programs",
        laney: "/authorities/terms/local/laney_programs",
        rollins:
          "/authorities/terms/local/rollins_programs"
      },
      departments: [],
      selected_department: [],
      selected: "",
      options: [
        {
          text: "Select a School",
          value: "",
          disabled: "disabled",
          selected: "selected"
        },
        { text: "Candler School of Theology", value: "candler" },
        { text: "Emory College", value: "emory" },
        { text: "Laney Graduate School", value: "laney" },
        { text: "Rollins School of Public Health", value: "rollins" }
      ]
    };
  },
  methods: {
    fetchData() {
      var selectecdSchool = this.schools[this.selected];
      axios.get(selectecdSchool).then(response => {
        this.departments = response.data;
      });
    }
  },
  watch: {
    selected() {
      this.fetchData();
    }
  }
};
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
