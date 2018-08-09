<template>
    <section aria-labelledby="copyright-questions">
    <h4 id="copyright-questions">Please review the following copyright questions.</h4>
      <div>
        <div class="well" v-for="question in sharedState.copyrightQuestions" v-bind:key="question.name">
            <label :for="question.name">{{ question.label }}</label>
            <p>{{ question.text }}</p>
            <select v-if="question.name == 'etd[additional_copyrights]'" @change="sharedState.setCopyrights()" class="form-control" v-model="copyrights" :id="question.name" :name="question.name">
                <option value="0">No, my thesis or dissertation does not contain copyrighted material.</option>
                <option value="1">Yes, my thesis or dissertation contains copyrighted material.</option>
            </select>
            <select v-if="question.name == 'etd[requires_permissions]'" @change="sharedState.setPermissions()" class="form-control" v-model="permissions" :id="question.name" :name="question.name">
                <option value="0">No, my thesis or dissertation does not require additional permissions.</option>
                <option value="1">Yes, my thesis or dissertation requires additional permissions.</option>
            </select>
            <select v-if="question.name == 'etd[patents]'" class="form-control" @change="sharedState.setPatents()" v-model="patents" :id="question.name" :name="question.name">
                <option value="0">No, my thesis or disseration does not contain patentable material.</option>
                <option value="1">Yes, my thesis or disseration contains patentable material.</option>
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
 data() {
     return {
         permissions: formStore.getPermissions() || formStore.savedData.requires_permissions || '0',
         copyrights: formStore.getCopyrights() || formStore.savedData.additional_copyrights || '0',
         patents: formStore.getPatents() ||formStore.savedData.patents || '0',
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
