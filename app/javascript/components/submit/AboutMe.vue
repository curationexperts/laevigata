<template>
  <section>   
    <h4>About Me</h4>
    <h5 class="submit-heading">Student Name</h5>
    <div> {{ sharedState.savedData.creator }} </div>
    <h5>School</h5>
    <div> {{ sharedState.savedData.school }} </div>
    <h5>Graduation Date</h5>
    <div> {{ sharedState.savedData.graduation_date }} </div>
    <h5>Post-Graduation Email</h5>
    <div> {{ sharedState.savedData.post_graduation_email }} </div>
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