<template>
<div>
  <div v-if="sharedState.getSelectedSchool() === 'rollins'">
    <label>Partnering Agency
    <div v-for="parnterningAgency in sharedState.partneringAgencies.partneringAgencies()">
    <select name="etd[partnering_agency][]" class="form-control" v-model="parnterningAgency.value">
      <option v-for="agency in sharedState.partneringAgencyChoices">
        {{ agency.id }}
      </option>
    </select>
    <button type="button" class="btn btn-default" @click="sharedState.partneringAgencies.remove(parnterningAgency)">
      <span class="glyphicon glyphicon-trash"></span> Remove This Partnering Agency</button>
    </div>
    </label>
    <button type="button" class="btn btn-default" @click="sharedState.partneringAgencies.addEmpty()">
      <span class="glyphicon glyphicon-plus"></span> Add Another Partnering Agency</button>
  </div>
  <div v-else>
    <input name="etd[partnering_agency][]" type="hidden" value="No partnering agency." />
  </div>
  </div>
</template>

<script>
import { formStore } from './formStore'
import PartneringAgencyList from './lib/PartneringAgencyList'
import PartneringAgency from './lib/PartneringAgency'

export default {
  data() {
    return {
      sharedState: formStore
    }
  },
 mounted() {
    this.$nextTick(() => {
      this.sharedState.getPartneringChoices()
      this.sharedState.partneringAgencies.load(
        this.sharedState.savedData['partnering_agency']
      )
    })
  }
}
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>