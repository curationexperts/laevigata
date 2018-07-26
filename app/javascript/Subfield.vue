<template>
  <div v-if="this.sharedState.subfields.length > 0">
    <label for="subfield">Subfield</label>
    <select id="subfield" name="etd[subfield]" class="form-control" v-model="selected">
      <option v-for="option in this.sharedState.subfields"  v-bind:value="option.label" v-bind:key='option.label'
      :selected='option.selected' :disabled='option.disabled'>{{ option.id }}</option>
    </select>
  </div>
</template>

<script>
import Vue from "vue"
import App from "./App"
import { formStore } from './formStore'

export default {
  data() {
    return {
      selected: "",
      sharedState: formStore
    }
  },
  mounted: function(){
    this.$nextTick(function () {
      this.selected = this.sharedState.getSelectedSubfield()
    })
  },
  watch: {
    selected() {
      this.sharedState.setSelectedSubfield(this.selected)
    }
  }
}
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
