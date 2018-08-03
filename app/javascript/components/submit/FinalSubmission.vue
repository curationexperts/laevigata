<template>
  <div>
    <div v-if="sharedState.getUserAgreement()">   
      <input v-if="!sharedState.submitted" type="button" class="btn btn-primary" value="Submit Your Thesis or Dissertation" @click="sharedState.submit()"/>
    </div>
    <div v-if="sharedState.submitted">
      <div class="alert alert-info">
        <span class="glyphicon glyphicon-info-sign"></span>
        <span aria-live="polite"> Submitting Your Thesis or Dissertation </span><span class="glyphicon glyphicon-refresh spinning"></span>
      </div>
    </div>  
  </div>
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
<style>
.glyphicon.spinning {
    animation: spin 1s infinite linear;
    -webkit-animation: spin 1s infinite linear;
}

@keyframes spin {
    from { transform: scale(1) rotate(0deg); }
    to { transform: scale(1) rotate(360deg); }
}

@-webkit-keyframes spin {
    from { -webkit-transform: rotate(0deg); }
    to { -webkit-transform: rotate(360deg); }
}
</style>