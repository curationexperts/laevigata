<template>
  <div>
    <div v-if="sharedState.getUserAgreement() === true">   
      <input type="button" class="btn btn-primary" value="Submit Your Thesis or Dissertation" @click="sharedState.submit()"/>
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
