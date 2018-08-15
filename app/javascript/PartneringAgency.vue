<template>
<div>
  <div v-if="sharedState.getSavedOrSelectedSchool() === 'Rollins School of Public Health'">
    <label>Partnering Agency
    <div v-for="partneringAgency in sharedState.partneringAgencies.partneringAgencies()">
    <select name="etd[partnering_agency][]" class="form-control" v-model="partneringAgency.value">
      <option>{{ partneringAgency.value }}</option>
      <option v-for="agency in sharedState.partneringAgencyChoices">
        {{ agency.id }}
      </option>
    </select>
    <button type="button" class="btn btn-danger remove-partner" @click="sharedState.partneringAgencies.remove(partneringAgency)">
      <span class="glyphicon glyphicon-trash"></span> Remove This Partnering Agency</button>
    </div>
    </label>
    <div>
      <button type="button" class="btn btn-default add-partner" @click="sharedState.partneringAgencies.addEmpty()">
      <span class="glyphicon glyphicon-plus"></span> Add Another Partnering Agency</button>
    </div>
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
.add-partner {
  margin-top: 1em;
}
.remove-partner {
  margin-bottom: 1em;
}
select {
  margin-bottom: 1em;
}
</style>