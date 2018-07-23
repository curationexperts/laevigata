<template>
  <section>   
    <h4>Embargoes</h4>
    <h5>Embargo Length</h5>
    <div>{{ sharedState.savedData.embargo_length }}</div>
  </section>
</template>

<script>
import Vue from "vue"
import { formStore } from '../../formStore'

export default {
  data() {
    return {
      sharedState: formStore
    }
  }
}
</script>
<style scoped>
h4 {
  margin-bottom: 2em;
}
h5 {
  font-weight: 700;
  font-family: sans-serif;
}
</style>