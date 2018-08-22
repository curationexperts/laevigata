<template>
  <section>   
    <h4>My Thesis or Dissertation</h4>
    <h5>Title</h5>
    <div>{{ sharedState.savedData.title }}</div>
    <h5>Language</h5>
    <div>{{ sharedState.savedData.language }}</div>
    <h5>Abstract</h5>
    <div v-html="sharedState.savedData.abstract"></div>
    <h5>Table of Contents</h5>
    <div v-html="sharedState.savedData['table_of_contents']"></div>
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
  
}
</style>
<style scoped>
h4 {
  margin-bottom: 2em;
}
h5 {
  font-weight: 700;
  
}
</style>
