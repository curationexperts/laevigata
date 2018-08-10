<template>
    <section aria-labelledby="copyright-questions">
    <h4 id="copyright-questions">Please review the following copyright questions.</h4>
      <div>
        <div class="well" v-for="question in sharedState.copyrightQuestions" v-bind:key="question.name">
            <label :for="question.name">{{ question.label }}</label>
            <p>{{ question.text }}</p>
           <div class="form-inline">
            <label>Yes <input :id="question.name" class="checkbox copyright-checkbox" :name="question.name" type="checkbox" v-model="question.choice"
            true-value="yes" false-value="no">
            </label>
            </div>
        </div>
      </div>
    </section>
</template>

<script>
import Vue from "vue"
import App from "./App"
import { formStore } from './formStore'
export default {
 data() {
     return {
         sharedState: formStore
     }
 }
}
</script>

<style scoped>
.copyright-checkbox {
    margin-left: 1em;
}

input[type=checkbox]
{
  -ms-transform: scale(2); 
  -moz-transform: scale(2);
  -webkit-transform: scale(2);
  -o-transform: scale(2);
}
</style>
