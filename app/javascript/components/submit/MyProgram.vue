<template>
  <section>
    <h4>My Program</h4>
    <h5>Department</h5>
    <div> {{ sharedState.getDepartmentLabelFromId(sharedState.getSavedOrSelectedDepartment()) }} </div>
    <div v-if="sharedState.getSavedOrSelectedSubfield() && sharedState.getSavedOrSelectedSubfield().length > 0">
          <h5>Subfield</h5>
      <div> {{ sharedState.getSubfieldLabelFromId(sharedState.getSelectedSubfield()) }} </div>
    </div>
    <div v-if="sharedState.getSavedOrSelectedSchool() === 'Rollins School of Public Health'">
      <h5>Partnering Agencies</h5>
      <div> {{ managePartneringAgency() }} </div>
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
      sharedState: formStore,
      subfields:  formStore.getSubfields(),
      departments: formStore.loadDepartments()
    }
  },
  methods: {
    managePartneringAgency: function(){
      // if there is anything besides 'does not apply', remove 'does not apply'
      let agencies = ''
      if (this.sharedState.savedData['partnering_agency'].length >= 2) {

        const validPartneringAgency =   this.sharedState.savedData['partnering_agency'].filter(
          item => item != "Does not apply (no collaborating organization)")

        if (validPartneringAgency) {
          agencies = validPartneringAgency.join(', ')
        }
      } else {
        agencies = this.sharedState.savedData['partnering_agency'].join(', ')
      }
      return agencies
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
