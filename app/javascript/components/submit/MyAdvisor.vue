<template>
  <section>   
    <h4>My Advisor</h4>
    <ul>
      <li v-for="(chair, index) in sharedState.savedData.committee_chair_attributes">
      Chair/Advisor: {{ chair.name[0] }}, {{ chair.affiliation[0] }}
      </li>
    </ul>
    <ul>
      <li v-for="(member, index) in sharedState.savedData.committee_members_attributes">
      Committee Member: {{ member.name[0] }}, {{ member.affiliation[0] }}
      </li>
    </ul>
  </section>
</template>

<script>
import Vue from 'vue'
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
ul {
  padding-left: 1em;
}
</style>
