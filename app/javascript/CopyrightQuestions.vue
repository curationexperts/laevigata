<template>
    <div>
        <div v-for="question in sharedState.copyrightQuestions" v-bind:key="question.name">
            <label :for="question.name">{{ question.label }}</label>
            <p>{{ question.text }}</p>
          <input :id="question.name" class="checkbox copyright-checkbox" :name="question.name" type="checkbox" v-model="question.choice"
          true-value="yes" false-value="no">
        </div>
    </div>
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
    margin-bottom: 3em;
}
</style>
