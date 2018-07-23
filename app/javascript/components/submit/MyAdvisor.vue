<template>
  <section>   
    <h4>My Advisor</h4>
    <div v-for="(chair, index) in sharedState.savedData.committee_chair_attributes">
      <ul>
        <li>
        Chair name: {{ chair.name[0] }}
        </li>
        <li> 
        Affiliation: {{ chair.affiliation_type }}
        </li>
      </ul>
    </div>
       <div v-for="(member, index) in sharedState.savedData.committee_members_attributes">
      <ul>
        <li>
        Member Name: {{ member.name[0] }}
        </li>
        <li> 
        Affiliation: {{ member.affiliation_type }}
        </li>
      </ul>
    </div>
  </section>
</template>

<script>
import Vue from "vue"
import { formStore } from "../../formStore"

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