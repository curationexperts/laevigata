<template>
  <div>
    <label>School</label>
    <select class="form-control" v-model="selected" id="school">
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
      formStore.setSelectedSchool(this.selected)
      formStore.getDepartments(selectedSchool)
    }
  },
  mounted: function(){
    //This is the right hook in the dom loading sequence to get the saved data
    this.$nextTick(function () {
      this.selected = formStore.getSchoolOptionValue()
    })
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
