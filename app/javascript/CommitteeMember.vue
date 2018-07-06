<template>
    <div>
        <div v-for="chair in committeeChairs" v-bind:value="chair.name" v-bind:key='chair.id'>
            <label>Committee Chair/Thesis Advisor's Affliation</label>
            <select :name="chairAffiliationTypeAttr(chair)" class="form-control">
                <option disabled selected>
                    Select an affiliation
                </option>
                <option>Emory University</option>
                <option>Non-Emory</option>
            </select>
            <label>Committee Chair/Thesis Advisor's Name</label>
            <input :name="chairNameAttr(chair)" type="text" class="form-control" />

           
            <label>Affiliation</label> 
            <input :name="chairAffiliationAttr(chair)" type="text" class="form-control" />

             <a class="btn btn-default" href="#" data-turbolinks="false" @click="removeChair(chair)">Remove Chair or Advisor</a>
        </div>
        <p>
        <a href="#" class="btn btn-default" data-turbolinks="false" @click="addChair">Add Another Chair or Advisor</a>
        </p>
         <div v-for="member in committeeMembers" v-bind:value="member.name" v-bind:key='member.id'>
            <label>Committee Member's Affiliation</label>
            <select :name="memberAffiliationTypeAttr(member)" class="form-control">
                <option disabled selected>
                    Select an affiliation
                </option>
                <option>Emory University</option>
                <option>Non-Emory</option>
            </select>
            <label>Committee Member's Name</label>
            <input :name="memberNameAttr(member)" type="text" class="form-control" />
            <label>Affiliation</label> 
            <input :name="memberAffiliationAttr(member)" type="text" class="form-control" />
            <a href="#" class="btn btn-default" data-turbolinks="false" @click="removeMember(member)">Remove Committee Member</a>
            <br>
        </div>
        <br>
        <a href="#" class="btn btn-default" data-turbolinks="false" @click="addMember">Add Another Committee Member</a>
    </div>
</template>

<script>
import Vue from "vue";
import App from "./App";
import { formStore } from "./formStore";

export default {
  data() {
    return {
      committeeChairs: [],
      committeeMembers: [],
      selectedAffiliation: [],
      sharedState: formStore,
    };
  },
  methods: {
      addMember () {
          this.committeeMembers.push({id: this.committeeMembers.length + 1, affiliation: '', name: ''})
      },
      removeMember(member) {
          const filteredMembers = this.committeeMembers.filter((member) => member.id !== member.id)
          this.committeeMembers = filteredMembers
      },
      addChair () {
          this.committeeChairs.push({id: this.committeeChairs.length + 1, affiliation: '', name: ''})
      },
      removeChair(chair) {
          const filteredChairs = this.committeeChairs.filter((chair) => chair.id !== chair.id)
          this.committeeChairs = filteredChairs
      },
      chairNameAttr(chair) {
          return `etd[committee_chair_attributes][${chair.id}][name][]`
      },
      chairAffiliationAttr(chair) {
          return `etd[committee_chair_attributes][${chair.id}][affiliation][]`
      },
      chairAffiliationTypeAttr(chair) {
        return `etd[committee_chair_attributes][${chair.id}][affiliation_type]`
      },
      memberNameAttr(member) {
          return `etd[committee_member_attributes][${member.id}][name][]`
      },
      memberAffiliationAttr(member) {
          return `etd[committee_member_attributes][${member.id}][affiliation][]`
      },
      memberAffiliationTypeAttr(member) {
        return `etd[committee_member_attributes][${member.id}][affiliation_type]`
      }
  },
  watch: {
    selected() {}
  }
};
</script>

<style>
select {
  margin-bottom: 1em;
}
</style>
