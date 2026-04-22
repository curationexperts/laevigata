<template>
    <div>
      <label for="department"> {{ sharedState.getDepartmentHeading() }} </label>
        <select id="department" name="etd[department]" class="form-control" aria-required="true" v-model="selected"
                v-on:change="this.sharedState.getSubfields(), sharedState.setSelectedDepartment(selected), sharedState.setValid('My Program', false)">
            <option v-for="department in departments"
                    v-bind:value="department.id"
                    v-bind:disabled="department.disabled">
                    {{ labelFor(department.label, department.active) }}
            </option>
        </select>
    </div>
</template>

<script>
import axios from "axios"
import {formStore} from './formStore'
import {labelFor, showInactive} from './lib/formHelpers'

export default {
  data() {
    return {
      sharedState: formStore,
      selected: '',
      departmentsEndpoint: '',
      departments: {}
    }
  },
  created() {
    this.selected = this.sharedState.getSavedDepartment()
    this.fetchData()
    this.sharedState.getSubfields()
  },
  methods: {
    labelFor,
    fetchData() {
      // We need to choose a department list based on the selected school
      this.departmentsEndpoint = this.sharedState.schools[this.sharedState.getSavedOrSelectedSchool()]
      axios.get(this.departmentsEndpoint).then(response => {
        this.departments = this.getSelected(response.data)
      }).catch(e => {
        console.log(e)
      })
    },
    getSelected(data){
      // Add a placeholder option at the top of the options list
      data.unshift({ "label": `Select a ${this.sharedState.getDepartmentHeading()}`, "disabled":"disabled","active": true, "id": "" })

      // If a previously saved option exists, ensure it's active
      // If no match is found, we use the placeholder index
      const selected_index = Math.max(data.findIndex((option) => option.id === this.selected),0)
      data[selected_index].active = true

      // Filter out inactive options when appropriate
      return showInactive() ? data : data.filter((option) => option.active)
    }
  }
}
</script>
