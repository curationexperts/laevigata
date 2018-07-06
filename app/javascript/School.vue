<template>
  <div>
    <label>School</label>
    <select class="form-control" v-model="selected" id="school">
      <option v-for="option in options" v-bind:value="option.value" v-bind:key='option.value' :selected='option.selected' :disabled='option.disabled'>
        {{ option.text }}
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
      schools: {
        candler:
          "/authorities/terms/local/candler_programs",
        emory: "/authorities/terms/local/emory_programs",
        laney: "/authorities/terms/local/laney_programs",
        rollins:
          "/authorities/terms/local/rollins_programs"
      },
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
      var selectedSchool = this.schools[this.selected];
      formStore.getDepartments(selectedSchool)
    }
  },
  watch: {
    selected() {
      this.fetchData();
      formStore.clearSubfields() 
    }
  }
};
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
