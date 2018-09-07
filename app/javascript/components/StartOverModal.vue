<template>
  <div v-if="sharedState.showStartOver" class="m">
    <div class="m-content">
      <div class="panel panel-danger">
        <div class="panel-heading m-header">
          <div class="panel-title">
            WARNING
          </div>
        </div>
        <div class="panel-body m-content">
          <p aria-live="polite">
            Starting over your submission will erase any previously saved data and allow you to choose a new school for your submission if needed.
          </p>
          <div v-if="removeSpinner">
            <div class="alert alert-danger">
              <span class="glyphicon glyphicon-info-sign">Removing your Submission </span>
              <span class="glyphicon glyphicon-refresh spinning"></span>
            </div>
          </div>
          <div>
            <button @click="changeFormMethod()" type="button" class="btn btn-danger">Start Over With a New Submission</button>
            <button @click="sharedState.showStartOver = false" type="button" class="btn btn-primary">Go Back to my Current Submission</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios"
import { formStore } from "../formStore"

export default {
  data() {
    return {
      sharedState: formStore,
      removeSpinner: false
    }
  },
  methods: {
    changeFormMethod() {
      this.sharedState.submitted = true
      this.removeSpinner = true
      axios
        .delete(this.sharedState.getUpdateRoute())
        .then(response => {
          localStorage.clear()
          window.location = "/"
        })
        .catch(() => {
          localStorage.clear()
          window.location = "/"
        })
    }
  }
}
</script>

<style scoped>
.panel {
  margin-bottom: 0;
}
.m {
  border-radius: 5px;
  left: 50%;
  margin: -250px 0 0 -32%;
  position: absolute;
  top: 60%;
  width: 65%;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.25);
  box-sizing: border-box;
  z-index: 99999;
}
</style>
