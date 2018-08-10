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
    <div>
      <div class="well">
        Fair Use: <b>{{ onToYes(sharedState.savedData.additional_copyrights) }}</b>
      </div>
      <div class="well">
        Additional Copyrights: <b>{{ onToYes(sharedState.savedData.requires_permissions) }}</b>
      </div>
      <div class="well">
        Patents: <b>{{ onToYes(sharedState.savedData.patents) }}</b>
      </div>
    </div>
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
  font-family: sans-serif;
}

ul {
  padding-left: 1em;
}
</style>