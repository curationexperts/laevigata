<template>
<div>
  <div v-if="sharedState.getSavedOrSelectedSchool() === 'Rollins School of Public Health'">
    <label>Partnering Agency</label>
    <div  v-if="sharedState.partneringAgencies.partneringAgencies()">
      <input name="etd[partnering_agency][]" type="hidden" value="" />
    </div>
    <div v-for="partneringAgency in sharedState.partneringAgencies.partneringAgencies()">
    <div class="agency-container" v-if="partneringAgency.value != 'Does not apply (no collaborating organization)'">
    <select name="etd[partnering_agency][]" class="form-control" v-model="partneringAgency.value">
      <option>{{ partneringAgency.value }}</option>
      <option v-for="agency in sharedState.partneringAgencyChoices">
        {{ agency.id }}
      </option>
    </select>
    <button type="button" class="btn btn-danger remove-partner agency-remove" @click="sharedState.partneringAgencies.remove(partneringAgency)">
      <span class="glyphicon glyphicon-trash"></span> Remove This Partnering Agency</button>
    </div>
    </div>
    <div>
      <button type="button" class="btn btn-default add-partner" @click="sharedState.partneringAgencies.addEmpty()">
      <span class="glyphicon glyphicon-plus"></span> Add Another Partnering Agency</button>
    </div>
  </div>
  <div v-else>
    <input name="etd[partnering_agency][]" type="hidden" value="" />
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

<style scoped>
.agency-container {
  display: inline-flex;
}
.add-partner {
  margin-top: 1em;
}
.remove-partner {
  margin-left: .5em;
  max-width: 300px;
  margin-bottom: 1em;
}
select {
  margin-bottom: 1em;
}
</style>
