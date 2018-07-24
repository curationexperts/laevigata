<template>
  <section>   
    <aboutMe></aboutMe>
    <myProgram></myProgram>
    <myAdvisor></myAdvisor>
    <myEtd></myEtd>
    <keywords></keywords>
    <myFiles></myFiles>
    <embargo></embargo>
    <userAgreement></userAgreement>
  </section>
</template>

<script>
import Vue from "vue"
import { formStore } from './formStore'
import AboutMe from './components/submit/AboutMe'
import MyProgram from './components/submit/MyProgram'
import MyAdvisor from './components/submit/MyAdvisor'
import MyEtd from './components/submit/MyEtd'
import Keywords from './components/submit/Keywords'
import MyFiles from './components/submit/MyFiles'
import Embargo from './components/submit/Embargo'
import UserAgreement from './components/submit/UserAgreement'
export default {
  data() {
    return {
      sharedState: formStore
    }
  },
  components: {
    aboutMe: AboutMe,
    myProgram: MyProgram,
    myAdvisor: MyAdvisor,
    myEtd: MyEtd,
    Keywords: Keywords,
    myFiles: MyFiles,
    embargo: Embargo,
    userAgreement: UserAgreement
  }
}
</script>

<style scoped>
 section > section {
  box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
  border-radius: 1px;
  transition: all 0.3s cubic-bezier(.25,.8,.25,1);
  padding: 2em;
  margin-bottom: 1.5em;
 }
</style>
