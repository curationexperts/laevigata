<template>
    <div>
        <input name="primary_files[]" type="file" ref="fileInput" @change="onFileChange">
        <div v-for="files in sharedState.deletablePrimaryFiles" v-bind:key="files[0].deleteUrl">
            <div v-for="file in files" v-bind:key="file.deleteUrl">
                {{ file.name }}
                <a href="#" data-turbolinks="false" @click="deleteFile(file.deleteUrl)">Remove this file</a>
            </div>
        </div>
    </div>
</template>

<script>
import { formStore } from "./formStore"

let token = document
  .querySelector('meta[name="csrf-token"]')
  .getAttribute("content")

export default {
  data() {
    return {
      sharedState: formStore
    }
  },
  methods: {
    onFileChange(e) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length) return
      var xhr = new XMLHttpRequest()
      xhr.upload.addEventListener("progress", this.onprogressHandler, false)
      xhr.open("POST", "/uploads/", true)
      xhr.setRequestHeader("X-CSRF-Token", token)
      xhr.onreadystatechange = () => {
        if (xhr.readyState == XMLHttpRequest.DONE) {
          formStore.deletablePrimaryFiles.push(
            JSON.parse(xhr.responseText).files
          )
          const input = this.$refs.fileInput
          input.type = "text"
          input.type = "file"
        }
      }
      xhr.send(this.getFormData())
    },
    onprogressHandler(evt) {
      var percent = evt.loaded / evt.total * 100
      console.log("Upload progress: " + percent + "%")
    },
    getFormData() {
      var form = document.getElementById("vue_form")
      var formData = new FormData(form)
      return formData
    },
    deleteFile(deleteUrl) {
      var xhr = new XMLHttpRequest()
      xhr.open("DELETE", deleteUrl, true)
      xhr.setRequestHeader("X-CSRF-Token", token)
      xhr.send(null)
      console.log(deleteUrl)
      const filteredFiles = this.sharedState.deletablePrimaryFiles.filter(
        file => file[0].deleteUrl !== deleteUrl
      )
      this.sharedState.deletablePrimaryFiles = filteredFiles
    }
  }
}
</script>