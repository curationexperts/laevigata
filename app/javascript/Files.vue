<template>
  <div>
    <section class="thesis-file">
    <h2>Add Your Thesis or Dissertation File</h2>
    <div id="box-picker"></div>
    <div v-if="accessToken">
      <link rel="stylesheet" href="https://cdn01.boxcdn.net/platform/elements/4.4.0/en-US/picker.css" />
    </div>
    <span class="form-instructions">Upload the version of your thesis or dissertation approved by your advisor or committee.
    You can only upload one file to represent your thesis or dissertation. This file should not contain any signatures or other personally identifying
    information. PDF/A is a better version for preservation and for that reason we recommend you upload a PDF/A file, but it is not required.
    For help converting your manuscript to PDF/A, please contact <a href="http://it.emory.edu/studentdigitallife/">Student Digital Life</a>.</span>
    <div class="alert alert-info"><span class="glyphicon glyphicon-info-sign"></span> Please add files larger than 100MB with Box.</div>
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
      <a class="btn btn-primary" :href="boxOAuthUrl()"><span class="glyphicon glyphicon-plus"></span> Add your thesis or dissertation file from Box</a>
    </div>

    <div v-if="sharedState.files[0]">
      <input type="hidden" name="uploaded_files[]" :value="sharedState.files[0][0].id" />
    </div>

    <div v-if="sharedState.supplementalFiles[0]">
      <input type="hidden" name="uploaded_files[]" :value="sharedState.supplementalFiles[0].id" />
    </div>

    </section>
    <section class="optional-files">
    <h2>Add Optional Supplemental Files</h2>
    <div class="form-instructions">
      Uploading supplemental files is not required, but it gives you a way to share more of your research.
      These files could be video, research data, securely zipped software, or other materials. Please group your supplemental files
      so you can select and upload them all at once. Once uploaded, <strong>you are required to add additional metadata for each</strong>.
      You may upload as many supplemental files as you like. No single file should exceed 2.5 GB.
      If you have a file larger than 2.5 GB, contact the ETD team at <a href="mailto:etd-help@LISTSERV.CC.EMORY.EDU">etd-help@LISTSERV.CC.EMORY.EDU</a> for help.
    </div>
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
            <td><input :name="supplementalFileTitleName(key)" type="text" class="form-control" v-on:change="sharedState.setValid('My Files', false)"/></td>
            <td><input :name="supplementalFileDescriptionName(key)" type="text" class="form-control" v-on:change="sharedState.setValid('My Files', false)"/></td>
            <td>
              <select :name="supplementalFileTypeName(key)" class="form-control file-type" v-on:change="sharedState.setValid('My Files', false)">
                <option selected="selected" disabled="disabled">Please select a file type</option>
                <option>Text</option>
                <option>Sound</option>
                <option>Video</option>
                <option>Software</option>
              </select>
            </td>
            <td>
              {{ files.deleteUrl }}
              <button type="button" class="btn btn-danger remove-btn" @click="deleteSupplementalFile(files.deleteUrl)">
              <span class="glyphicon glyphicon-trash"></span> Remove this file</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="form-inline">
      <input class="input-file btn-primary" id="add-supplemental-file" name="supplemental_files[]" type="file" ref="fileInput" @change="onSupplementalFileChange"/>
      <label class="btn btn-primary" for="add-supplemental-file"><span class='glyphicon glyphicon-plus'></span>
      Add a supplemental file from your computer
      </label>
      <button type="button" class="btn btn-primary"><span class="glyphicon glyphicon-plus"></span> Add a supplemental file from Box</button>
    </div>
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
  mounted () {
    var folderId = '0'
    var accessToken = window.location.search.split('&access_token=')[1]
    var filePicker = new Box.FilePicker()
    if (accessToken) {
    filePicker.show(folderId, accessToken, {
      container: '#box-picker',
      maxSelectable: 1,
      canUpload: false,
      logoUrl: 'box',
      canCreateNewFolder: false
    })

    filePicker.addListener('choose', (event) => {
      console.log(event)
      var boxRedirect = `/file/box`
      axios({
        method: 'post',
        url: boxRedirect,
        data: {
          id: event[0].id,
          token: accessToken
        }
      }).then((response) => {
        // TO-DO: do something with the URL
        console.log(response.data.location)
      })
    })
    }
  },
  methods: {
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
      formStore.setValid('My Files', false)
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
    deleteSupplementalFile(deleteUrl) {
      console.log(deleteUrl)
     var supplementalFileDelete = new SupplementalFileDelete({
        deleteUrl: deleteUrl,
        token: this.sharedState.token,
        formStore: this.sharedState
      })
      supplementalFileDelete.deleteFile()
      this.sharedState.setValid('My Files', false)
  },
  boxOAuthUrl () {
    return `https://account.box.com/api/oauth2/authorize?response_type=code&client_id=${boxClientId()}&redirect_uri=http://localhost:3000/auth/box&state=${this.sharedState.ipeId}`
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
