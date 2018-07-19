<template>
  <div>
    <label for="subfield">Subfield</label>
    <select id="subfield" name="etd[subfield]" class="form-control">
      <option v-for="option in sharedState.subfields"  v-bind:value="option.value" v-bind:key='option.value' 
      :selected='option.selected' :disabled='option.disabled'>
        {{ option.id }}
      </option>
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
      sharedState: formStore
    }
  }
}
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
