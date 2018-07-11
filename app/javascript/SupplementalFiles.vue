<template>
    <div>
        <input name="supplemental_files[]" type="file" ref="fileInput" @change="onFileChange" accept="application/pdf"/>
        <br>
        <div class="progress">
          <div class="progress-bar" :style="'width:' + progress + '%'" role="progressbar" :aria-valuenow="progress" aria-valuemin="0" aria-valuemax="100"></div>
        </div>
        <div v-for="files in sharedState.deletableSupplementalFiles" v-bind:key="files[0].deleteUrl">
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
      progress: 0,
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
          this.sharedState.addDeleteableSupplementalFile(
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
      this.progress = percent
    },
    getFormData() {
      var form = document.getElementById("vue_form")
      var formData = new FormData(form)
      return formData
    },
    deleteFile(deleteUrl) {
     this.sharedState.deleteSupplementalFile(deleteUrl, token)
    }
  }
}
</script>
