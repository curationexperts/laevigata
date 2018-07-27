<template>
    <div aria-labelledby="chair-label">
        <h3 id="chair-label">Chair & Commitee Members</h3>
        <div role="alert" v-if="sharedState.committeeChairs.length === 0">
            You have not selected a chair or committee members. Please
            use the buttons below to add them to your submission.
        </div>
        <div v-for="chair in sharedState.committeeChairs" v-bind:value="chair.name" v-bind:key="chairId(chair)">
            <div class="well" aria-live="polite">
            <h4>Committee Chair/Thesis Advisor</h4>
            <label :for="chairId(chair)">Committee Chair/Thesis Advisor's Affliation</label>
            <select v-model="chair.affiliation" :id="chairId(chair)"  class="form-control">
                <option disabled selected>
                    Select an affiliation
                </option>
                <option>Emory University</option>
                <option>Non-Emory</option>
            </select>
            <label :for="chairNameId(chair)">Committee Chair/Thesis Advisor's Name</label>
            <input :id="chairNameId(chair)" :name="chairNameAttr(chair)" type="text" class="form-control" />

           <div v-show="chair.affiliation === 'Non-Emory'">
            <label :for="chairAffiliationId(chair)">Affiliation</label>
            <input :id="chairAffiliationId(chair)" value='Emory University' :name="chairAffiliationAttr(chair)" type="text" class="form-control" autofocus/>
           </div>
             <button type="button" class="btn btn-default" @click="removeChair(chair)"><span class="glyphicon glyphicon-trash"></span> Remove This Chair or Advisor</button>
             </div>
        </div>
        <button type="button" class="btn btn-default" @click="addChair"><span class="glyphicon glyphicon-plus"></span> Add a Chair or Advisor</button>
         <div v-for="member in sharedState.committeeMembers" v-bind:value="member.name" v-bind:key="memberId(member)">
            <div class="well">
            <h4>Committee Member</h4>
            <label :for="memberId(member)">Committee Member's Affiliation</label>
            <select :id="memberId(member)" v-model="member.affiliation" :name="memberAffiliationTypeAttr(member)" class="form-control">
                <option disabled selected>
                    Select an affiliation
                </option>
                <option>Emory University</option>
                <option>Non-Emory</option>
            </select>
            <label :for="memberNameId(member)">Committee Member's Name</label>
            <input :id="memberNameId(member)" :name="memberNameAttr(member)" type="text" class="form-control" />
            <div v-if="member.affiliation === 'Non-Emory'">
                {{ member.affiliation }}
            <label :for="memberAffiliationId(member)">Affiliation</label>
            <input :id="memberAffiliationId(member)" :name="memberAffiliationAttr(member)" type="text" class="form-control" />
            </div>
            <button type="button" class="btn btn-default" @click="removeMember(member)"><span class="glyphicon glyphicon-trash"></span> Remove Committee Member</button>
        </div>
        </div>
        <button type="button" class="btn btn-default" @click="addMember"><span class="glyphicon glyphicon-plus"></span> Add a Committee Member</button>
    </div>
</template>

<script>
import Vue from "vue";
import App from "./App";
import { formStore } from "./formStore";

export default {
  data() {
    return {
      sharedState: formStore,
      options:'',
      selected: ''
    }
  },
  methods: {
      addMember () {
          this.sharedState.committeeMembers.push({id: this.sharedState.committeeMembers.length + 1, affiliation: '', name: ''})
      },
      removeMember(member) {
          const filteredMembers = this.sharedState.committeeMembers.filter((member) => member.id !== member.id)
          this.sharedState.committeeMembers = filteredMembers
      },
      addChair () {
          this.sharedState.committeeChairs.push({id: this.sharedState.committeeChairs.length + 1, affiliation: [''], name: ['']})
      },
      removeChair(chair) {
          const filteredChairs = this.sharedState.committeeChairs.filter((chair) => chair.id !== chair.id)
          this.sharedState.committeeChairs = filteredChairs
      },
      changeAffiliation(chair) {
          chair.affiliation = this.selectedAffiliation
      },
      chairId (chair) {
          return `chair-${chair.id}`
      },
      memberId (member) {
          return `member-${member.id}`
      },
      chairAffiliationId (chair) {
          return `chair-affiliation-${chair.id}`
      },
      memberAffiliationId (member) {
          return `member-affiliation-${member.id}`
      },
      chairNameId (chair) {
          return `chair-name-${chair.id}`
      },
      memberNameId (member) {
          return `member-name-${member.id}`
      },
      chairNameAttr(chair) {
          return `etd[committee_chair_attributes][${chair.id}][name][]`
      },
      chairAffiliationAttr (chair) {
          return `etd[committee_chair_attributes][${chair.id}][affiliation][]`
      },
      chairAffiliationTypeAttr(chair) {
        return `etd[committee_chair_attributes][${chair.id}][affiliation_type]`
      },
      memberNameAttr(member) {
          return `etd[committee_members_attributes][${member.id}][name][]`
      },
      memberAffiliationAttr(member) {
          return `etd[committee_members_attributes][${member.id}][affiliation][]`
      },
      memberAffiliationTypeAttr(member) {
        return `etd[committee_members_attributes][${member.id}][affiliation_type]`
      }
  },
  watch: {
    selected() {}
  }
};
</script>

<style scoped>

.btn {
    margin: 0;
    margin-top: 1em;
    margin-bottom: 1em;
}

select {
  margin-bottom: 1em;
}
</style>
