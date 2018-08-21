<template>
  <section>
    <h4>My Program</h4>
    <h5>Department</h5>
    <div> {{ sharedState.getSavedOrSelectedDepartment() }} </div>
    <div v-if="sharedState.getSelectedSubfield() && sharedState.getSelectedSubfield().length > 0">
          <h5>Subfield</h5>
      <div> {{ sharedState.getSelectedSubfield () }} </div>
    </div>
    <div v-if="sharedState.getSavedOrSelectedSchool() === 'Rollins School of Public Health'">
      <h5>Partnering Agencies</h5>
      <div> {{ sharedState.savedData['partnering_agency'].join(', ') }} </div>
    </div>
    <h5>Degree</h5>
    <div> {{ sharedState.getSavedDegree() }} </div>
    <h5>Submission Type</h5>
    <div> {{ sharedState.getSubmittingType() }} </div>
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
