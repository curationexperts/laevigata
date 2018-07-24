<template>
  <section>   
    <h4 id="submission-agreement">Submission Agreement</h4>
    <section aria-labelledby="submission-agreement">
    <p>
      I hereby grant to Emory University and its agents the non-exclusive license to archive, make accessible, and display, subject to any embargo restrictions I have specified above, 
      my thesis or dissertation in whole or in part in all forms of media, now or hereafter known, including the display of the thesis or dissertation on the world wide web. 
      I retain all ownership rights to the copyright of the thesis or dissertation. I also retain the right to use in future works (such as articles or books) all or part of this thesis or dissertation. 
      I certify that my electronic submission is the version of my thesis/dissertation that was approved by my committee.
    </p>
    <div class="well">
      <label class="form-inline">
        <input type="checkbox" @change="sharedState.setUserAgreement()" />
         I HAVE READ AND AGREE TO THE SUBMISSION AGREEMENT
     </label>
    </div>

    <finalSubmission></finalSubmission>
    </section>
  </section>
</template>

<script>
import Vue from "vue"
import { formStore } from '../../formStore'
import FinalSubmission from './FinalSubmission'

export default {
  data() {
    return {
      sharedState: formStore
    }
  },
  components: { 
    finalSubmission: FinalSubmission
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