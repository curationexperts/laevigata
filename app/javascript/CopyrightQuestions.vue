<template>
    <section aria-labelledby="copyright-questions">
    <h4 id="copyright-questions">Please review the following copyright questions.</h4>
      <div class="well">
        <div v-for="question in sharedState.copyrightQuestions" v-bind:key="question.name">
            <label :for="question.name">{{ question.label }}</label>
            <p>{{ question.text }}</p>
            <select v-if="question.name == 'etd[other_copyrights]'" class="form-control" v-model="sharedState.other_copyrights" :id="question.name" :name="question.name">
                <option value="false">No, my thesis or dissertation does not contain copyrighted material.</option>
                <option value="true">Yes, my thesis or dissertation contains copyrighted material.</option>
            </select>
            <select v-if="question.name == 'etd[requires_permissions]'" class="form-control" v-model="sharedState.requires_permissions" :id="question.name" :name="question.name">
                <option value="false">No, my thesis or dissertation does not require additional permissions.</option>
                <option value="true">Yes, my thesis or dissertation requires additional permissions.</option>
            </select>
            <select v-if="question.name == 'etd[patents]'" class="form-control" v-model="sharedState.patents" :id="question.name" :name="question.name">
                <option value="false">No, my thesis or dissertation does not contain patentable material.</option>
                <option value="true">Yes, my thesis or dissertation contains patentable material.</option>
            </select>
        </div>
      </div>
    </section>
</template>

<script>
import Vue from "vue"
import App from "./App"
import { formStore } from './formStore'
export default {
 data () {
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
</style>
