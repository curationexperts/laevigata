<template>
  <section>   
    <h4>Embargoes</h4>
    <h5>Embargo Length</h5>
    <div>{{ sharedState.savedData.embargo_length }}</div>
    <h5>Embargo Type</h5>
    <div>{{ humanReadableEmbargoContents(sharedState.savedData.embargo_type) }}</div>
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
  },
  methods: {
    humanReadableEmbargoContents(type) {
      try {
      var readableType = this.sharedState.embargoContents.filter((embargo) => { return embargo.value === type })[0].text
      } catch(error) {
        
      }
      if (readableType)
      return readableType
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