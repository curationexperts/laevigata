<template>
  <section>   
    <h4>Keywords</h4>
    <h5>Research Fields</h5>
    <div v-for="(researchField, index) in sharedState.savedData.research_field" v-bind:key="index">
      <div> {{ researchField }} </div>
    </div>
    <h5>Keywords</h5>
    <div v-for="(keyword, index) in sharedState.savedData.keyword" v-bind:key="index">
      <div> {{ keyword }} </div>
    </div>
   <h5>Copyright Questions</h5>
    <ul>
      <li>Additional copyrights: {{ sharedState.savedData.additional_copyrights }}</li>
      <li>Requires Permission: {{ sharedState.savedData.requires_permission }} </li>
      <li>Patents: {{ sharedState.savedData.patents }}</li>
    </ul>
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

ul {
  padding-left: 1em;
}
</style>