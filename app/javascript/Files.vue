<template>
  <div>
    <section class="thesis-file">
    <h2>Add Your Thesis or Dissertation File</h2>
    <div v-if="accessToken">
      <link rel="stylesheet" href="https://cdn01.boxcdn.net/platform/elements/4.4.0/en-US/picker.css" />
    </div>
    <span class="form-instructions">Upload the version of your thesis or dissertation approved by your advisor or committee.
    You can only upload one file to represent your thesis or dissertation. This file should not contain any signatures or other personally identifying
    information. PDF/A is a better version for preservation and for that reason we recommend you upload a PDF/A file, but it is not required.
    For help converting your manuscript to PDF/A, please contact <a href="http://it.emory.edu/studentdigitallife/">Student Digital Life</a>.</span>
    <div class="alert alert-info"><span class="glyphicon glyphicon-info-sign"></span> Please be patient, it might take a while for the system to process your files. While that is happening, it is safe to continue working on your submission.</div>
    <div class="file-details" v-for="(files, key) in sharedState.files" v-bind:key="key">
      <div class="file-row form-inline" v-for="file in files" v-bind:key="file.deleteUrl">
        <h3>Your File</h3>
        <div v-if="uploadSuccess" class="alert alert-success">
          <span class="glyphicon glyphicon-saved"></span> Your thesis or dissertation has been successfully uploaded.
        </div>
        <div class="alert alert-info"><span class="glyphicon glyphicon-info-sign"/> You can save and continue or optionally add supplemental files below.</div>
        <div>
          <h4>Information About Your File</h4>
          <table class="table table-striped metadata">
            <thead>
              <tr>
                <th>Filename</th>
                <th>Size</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                  {{ file.name }}
                </td>
                <td>
                  {{ file.size }}
                </td>
                <td>
                  <button type="button" class="btn btn-danger delete" @click="deleteFile(file.deleteUrl)">
                  <span class="glyphicon glyphicon-trash"></span> Remove this file</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div v-if="sharedState.files.length === 0" class="form-inline">
      <input class="input-file" id="add-file" name="primary_files[]" type="file" accept=".pdf, application/pdf" aria-required="true" ref="fileInput" @change="onFileChange"/>
      <label class="btn btn-primary" for="add-file"><span class='glyphicon glyphicon-plus'></span>
      Add your thesis or dissertation file from your computer
      </label>
    </div>

    <div v-if="isUploadedFile(getPrimaryFile())">
      <input type="hidden" name="uploaded_files[]" :value="sharedState.files[0][0].id" />
    </div>
    <div v-for="(suppFiles, key) in sharedState.supplementalFiles">
      <div v-if="isUploadedFile(sharedState.supplementalFiles[key])">
        <input type="hidden" name="uploaded_files[]" :value="sharedState.supplementalFiles[key].id" />
      </div>
    </div>
    <section class='errorMessage alert alert-danger' v-if="sharedState.hasError('files')">
        <p><span class="glyphicon glyphicon-exclamation-sign"></span> {{ sharedState.getErrorMessage('files').files[0] }}</p>
    </section>
    </section>
    <section class="optional-files">
    <h2>Add Optional Supplemental Files</h2>
    <div class="form-instructions">
      Uploading supplemental files is not required, but it gives you a way to share more of your research.
      These files could be video, research data, securely zipped software, or other materials. Please group your supplemental files
      so you can select and upload them all at once. Once uploaded, <strong>you are required to add additional metadata for each</strong>.
      You may upload as many supplemental files as you like.
    </div>
    <div id="box-picker"></div>
    <div v-if="sharedState.supplementalFiles.length > 0" class="file-row form-inline">
      <table class="table table-striped metadata">
        <thead>
          <tr>
            <td>Filename</td>
            <td>Title</td>
            <td>Description</td>
            <td>Type</td>
            <td></td>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(files, key) in sharedState.supplementalFiles" v-bind:key="key">
            <td><input type="text" :value="files.name" class="form-control" disabled />
            <input type='hidden' :value="files.name" :name="supplementalFileName(key)"></td>

            <td><input :name="supplementalFileTitleName(key)" type="text" class="form-control" :value="getSavedTitle(key)" :disabled="!isUploadedFile(sharedState.supplementalFiles[key])" @change="onMetadataChange(key, $event)" /></td>

            <td><input :name="supplementalFileDescriptionName(key)" type="text" class="form-control" :value="getSavedDescription(key)" :disabled="!isUploadedFile(sharedState.supplementalFiles[key])" @change="onMetadataChange(key, $event)" /></td>

            <td>
              <select :name="supplementalFileTypeName(key)" class="form-control file-type" @change="onMetadataChange(key, $event)" :disabled="!isUploadedFile(sharedState.supplementalFiles[key])">
                <option v-if="getSavedFileType(key)" selected="selected" :value="getSavedFileType(key)">{{getSavedFileType(key)}}</option>
                <option v-else selected="selected" disabled="disabled">Please select a file type</option>
                <option>Text</option>
                <option>Dataset</option>
                <option>Image</option>
                <option>Sound</option>
                <option>Video</option>
                <option>Software</option>
              </select>
            </td>
            <td>
              <button type="button" class="btn btn-danger remove-btn" @click="deleteSupplementalFile(files.deleteUrl, key)">
              <span class="glyphicon glyphicon-trash"></span> Remove this file</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="alert alert-info"><span class="glyphicon glyphicon-info-sign"></span> Please contact <a href="https://libraries.emory.edu/research/open-access-publishing/emory-repositories-policy/etd/help-form">Emory’s Scholarly Communications Office</a> if you have a supplemental file over 100 MB for assistance with uploading your file(s).</div>
    <div v-if="sharedState.preventBoxSupplementalUpload" class="alert alert-warning" id="box-warning"><span class="glyphicon glyphicon-warning-sign"></span> Save and Continue before uploading any (more) files from Box.</div>
    <div class="form-inline">
      <input class="input-file btn-primary" id="add-supplemental-file" name="supplemental_files[]" type="file" ref="fileInput" @change="onSupplementalFileChange"/>
      <label class="btn btn-primary" for="add-supplemental-file"><span class='glyphicon glyphicon-plus'></span>
      Add a supplemental file from your computer
      </label>
    </div>
    <section class='errorMessage alert alert-danger' v-if="sharedState.hasError('supplementalFiles')">
        <p><span class="glyphicon glyphicon-exclamation-sign"></span> {{ sharedState.getErrorMessage('supplementalFiles').supplementalFiles[0] }}</p>
    </section>
    </section>
  </div>
</template>

<script>
import { formStore } from './formStore'
import FileUploader from './FileUploader'
import FileDelete from './FileDelete'
import SupplementalFileDelete from './SupplementalFileDelete'
import SupplementalFileUploader from './SupplementalFileUploader'
import axios from 'axios'
import _ from 'lodash'

export default {
  data() {
    return {
      uploadSuccess: false,
      sharedState: formStore,
      uploadError: false,
      progress: 0,
      accessToken: window.location.search.split('&access_token=')[1]
    }
  },
  created() {
     if (formStore.allowTabSave()) {
       if (localStorage.getItem('files')) {
          this.sharedState.files = [[JSON.parse(localStorage.getItem('files')).files[0]]]
        }
     }
  },
  methods: {
    // Determine if the file is a Hyrax::UploadedFile
    // or a ::FileSet that has already been saved.
    // They will have different paths in the deleteURL
    isUploadedFile(file) {
      if (file) {
        return _.includes(file.deleteUrl, 'uploads')
      } else {
        return false
      }
    },
    getPrimaryFile() {
      if (this.sharedState.files[0] && this.sharedState.files[0][0]) {
        return this.sharedState.files[0][0]
      }
    },
    onFileChange(e) {
      var fileUploader = new FileUploader({
        formStore: this.sharedState,
        token: this.sharedState.token,
        event: e,
        formData: this.getFormData()
      })
      fileUploader.uploadFile()
      formStore.setValid('My Files', false)
    },
    onSupplementalFileChange(e) {
        var supplementalFileUploader = new SupplementalFileUploader({
        formStore: this.sharedState,
        token: this.sharedState.token,
        event: e,
        formData: this.getFormData()
      })
      supplementalFileUploader.uploadFile()
    },
    onMetadataChange(key, e) {
      var fieldName = e.target.name.replace(`etd[supplemental_file_metadata][${key}]`, '')
      this.sharedState.setSupplementalFileMetadata(key, fieldName, e.target.value)
    },
    getFormData() {
      var form = document.getElementById('vue_form')
      var formData = new FormData(form)
      return formData
    },
    deleteFile(deleteUrl) {
      var fileDelete = new FileDelete({
        deleteUrl: deleteUrl,
        token: this.sharedState.token,
        formStore: this.sharedState
      })
      fileDelete.deleteFile()
      this.sharedState.setValid('My Files', false)
    },
    deleteSupplementalFile(deleteUrl, key) {
     var supplementalFileDelete = new SupplementalFileDelete({
        deleteUrl: deleteUrl,
        token: this.sharedState.token,
        formStore: this.sharedState
      })
      supplementalFileDelete.deleteFile(key)
      this.sharedState.setValid('My Files', false)
  },
  boxOAuth () {
    window.location = this.boxOAuthUrl()
  },
  supplementalFileTitleName (key) {
    return `etd[supplemental_file_metadata][${key}]title`
  },
  supplementalFileDescriptionName (key) {
    return `etd[supplemental_file_metadata][${key}]description`
  },
  supplementalFileTypeName (key) {
    return `etd[supplemental_file_metadata][${key}]file_type`
  },
  supplementalFileName (key) {
    return `etd[supplemental_file_metadata][${key}]filename`
  },
  getSavedTitle(key){
    if (this.sharedState.supplementalFilesMetadata[key] !== undefined) {
      return this.sharedState.supplementalFilesMetadata[key].title
    }
  },
  getSavedDescription(key){
    if (this.sharedState.supplementalFilesMetadata[key] !== undefined) {
      return this.sharedState.supplementalFilesMetadata[key].description
    }
  },
  getSavedFileType(key){
    if (this.sharedState.supplementalFilesMetadata[key] !== undefined) {
      return this.sharedState.supplementalFilesMetadata[key].file_type
    }
  },
  getSavedFileName(key){
    if (this.sharedState.supplementalFilesMetadata[key] !== undefined) {
      return this.sharedState.supplementalFilesMetadata[key].filename
    }
  }
  }
}
</script>

<style scoped>
.input-file {
  width: 0.1px;
	height: 0.1px;
	opacity: 0;
	overflow: hidden;
	position: absolute;
	z-index: -1;
}

.input-file:focus + label {
	outline: 1px dotted #000;
	outline: -webkit-focus-ring-color auto 5px;
}

.btn:focus {
	outline: 1px dotted #000;
	outline: -webkit-focus-ring-color auto 5px;
}

.file-row {
  margin-bottom: 1em;
}
.file-details select {
    margin-bottom: 0;
}

.file-type {
  margin-bottom: 0;
}

.remove-sup-file {
  margin: 0;
}

.file-info {
  list-style-type: none;
  margin:0;
  padding-left:0;
}

.file-info li {
  display: inline-block;
}

.file-info-well {
  margin-bottom: 0;

}

.remove-btn {
  margin-top: 0;
  margin-left: 0;
}

.primary-remove-btn {
  margin-top: 0.5em;
  color: #fff;
  background-color: #d9534f;
  border-color: #d43f3a;
}

.metadata td {
  vertical-align: middle;
}
</style>
