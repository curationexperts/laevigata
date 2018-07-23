<template>
<div>
  <div v-if="sharedState.getSelectedSchool() === 'rollins'">
    <label for="partneringAgency">Partnering Agency</label>
    <select name="etd[partnering_agency][]" id="partneringAgency" class="form-control" @change="showSelected" v-model="selected">
      <option v-for="partneringAgency in this.sharedState.partneringAgencies" v-bind:key="partneringAgency.id">
        {{ partneringAgency.id }}
      </option>
    </select>
  </div>
  <div v-else>
    <input name="etd[partnering_agency][]" type="hidden" value="No partnering agency." />
  </div>
  </div>
</template>

<script>
import { formStore } from './formStore'

export default {
  data() {
    return {
      sharedState: formStore,
      selected: ''
    }
  },
  mounted: function () {
 
  this.sharedState.getPartneringAgencies()
  this.$nextTick(() => {
           if (this.sharedState.getPartneringAgenciesOptionValue()) {
          this.selected = this.sharedState.getPartneringAgenciesOptionValue()[0]
      }
      this.sharedState.getPartneringAgenciesOptionValue()
  })
},
methods: {
    showSelected: (e) => {
        //console.log(this.sharedState.getPartneringAgenciesOptionValue())
    }
}
}
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>