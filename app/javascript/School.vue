<template>
  <div>
    <label for="school">School</label>
    <select id="school" class="form-control" v-model="selected" aria-required="true" v-on:change="sharedState.setValid('About Me', false, ['My Program', 'Embargo'])">
      <option v-for="school in this.sharedState.schools.options" v-bind:value="school.value" v-bind:key='school.value' :selected='school.selected' :disabled='school.disabled'>
        {{ school.text }}
      </option>
    </select>
  </div>
</template>

<script>
import axios from "axios"
import { formStore } from './formStore'

export default {
  data() {
    return {
      sharedState: formStore,
      selected: ''
    }
  },
  methods: {
    fetchData () {
      var selectedSchool = this.sharedState.schools[this.selected]
      this.sharedState.setSelectedSchool(this.selected)
      this.sharedState.getDepartments(selectedSchool)
    },
  },
  mounted: function(){
    this.$nextTick(function () {
      var selected = this.sharedState.getSelectedSchool()
      this.selected = selected
    })
  },
  watch: {
    selected() {
      //this executes when the component is rendered the first time and when the change event fires (user selects something)
      this.fetchData()
      this.sharedState.clearDepartment()
      this.sharedState.clearSubfields()
    }
  }
};
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
