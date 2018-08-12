<template>
  <section>   
    <h4>My Files</h4>
    <table class="table table-striped metadata">
      <thead>
        <tr>
          <th>
           Your Thesis or Dissertation
          </th>
          </tr>
      </thead>
      <tbody>
        <tr>
        <td>{{ primaryFile.name }}</td>
        </tr>
      </tbody>
    </table>
  <div v-if="Object.keys(supplementalFiles).length > 0">
    <h5>Supplemental Files</h5>
    <table class="table table-striped metadata">
      <thead>
        <tr>
          <th>
            Filename
          </th>
          <th>
            Title
          </th>
          <th>
            Description
          </th>
          <th>
            Type
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="supplementalFile in supplementalFiles">
          <td>{{ supplementalFile.filename }}</td>
          <td>{{ supplementalFile.title }}</td>
          <td>{{ supplementalFile.description }}</td>
          <td>{{ supplementalFile.file_type }}</td>
        </tr>
      </tbody>
    </table>
  </div>
  </section>
</template>

<script>
import Vue from "vue"
import { formStore } from '../../formStore'

export default {
  data() {
    return {
      supplementalFiles: formStore.savedData.supplemental_file_metadata,
      primaryFile: JSON.parse(formStore.savedData.files)
    }
  }
}
</script>
<style scoped>
h4 {
  margin-bottom: 2em;
}
h5 {
  font-weight: 700;
  font-family: sans-serif;
}
</style>