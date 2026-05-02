<template>
    <div>
      <label for="department"> {{ formStore.getDepartmentHeading() }} </label>
        <select id="department" name="etd[department]" class="form-control" aria-required="true" v-model="selected">
            <option v-for="department in formStore.departments"
                    v-bind:value="department.id"
                    v-bind:disabled="department.disabled">
                    {{ department.label }}
            </option>
        </select>
    </div>
</template>

<script>
import {formStore} from './formStore'

export default {
  computed: {
    formStore() {
      return formStore
    }
  },
  data() {
    return {
      selected: formStore.getDepartment(),
    }
  },
  beforeCreate() {
    formStore.loadDepartments()
  },
  watch: {
    selected(newDepartment) {
      formStore.setDepartment(newDepartment)
      formStore.getSubfields()
      formStore.setValid('My Program', false)
    }
  }
}
</script>
