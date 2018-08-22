<template>
  <section>
    <h4>Keywords</h4>
    <h5>Research Fields</h5>
    <div v-for="(researchField, index) in sharedState.savedData.research_field">
      <div> {{ researchField }} </div>
    </div>
    <h5>Keywords</h5>
    <div v-for="(keyword, index) in sharedState.savedData.keyword">
      <div> {{ keyword }} </div>
    </div>
   <h5>Copyright Questions</h5>
    <ul>
      <li><b>Additional copyrights:</b>
        <p v-if="sharedState.savedData.other_copyrights === 'true'">
          Yes, my thesis or dissertation contains copyrighted material.
        </p>
        <p v-else>
          No, my thesis or dissertation does not contain copyrighted material.
        </p>
      </li>
      <li><b>Requires Permission:</b>
        <p v-if="sharedState.savedData.requires_permissions === 'true'">
         Yes, my thesis or dissertation requires additional permissions.
        </p>
        <p v-else>
          No, my thesis or dissertation does not require additional permissions.
        </p>
      </li>
      <li><b>Patents:</b>
        <p v-if="sharedState.savedData.patents === 'true'">
          Yes, my thesis or dissertation contains patentable material.
        </p>
        <p v-else>
          No, my thesis or dissertation does not contain patentable material.
        </p>
      </li>
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
  },
  methods: {
    onToYes(string) {
      if (string === 'on') {
        return 'Yes'
      }
      if (string === 'off') {
        return 'No'
      }
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
