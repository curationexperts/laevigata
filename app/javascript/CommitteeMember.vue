<template>
    <div>
        <div v-for="(index, committeeChair) in committeeChairs" v-bind:value="committeeChair.name" v-bind:key='index.id'>
            <label>Committee Chair/Thesis Advisor's Affliation</label>
            <select :name="chairAffiliationTypeAttr(index)" class="form-control">
                <option disabled selected>
                    Select an affliation
                </option>
                <option>Emory University</option>
                <option>Non-Emory</option>
            </select>
            <label>Committee Chair/Thesis Advisor's Name</label>
            <input :name="chairNameAttr(index)" type="text" class="form-control" />

            <label>Affiliation</label> 
            <input :name="chairAffiliationAttr(index)" type="text" class="form-control" />
             <a data-turbolinks="false" @click="removeChair(index)">Remove Chair or Advisor</a>
        </div>
        <p>
        <a data-turbolinks="false" @click="addChair">Add Another Chair or Advisor</a>
        </p>
         <div v-for="(index, member) in committeeMembers" v-bind:value="member.name" v-bind:key='member.id'>
            <label>Committee Member's Affiliation</label>
            <select :name="memberAffiliationTypeAttr(index)" class="form-control">
                <option disabled selected>
                    Select an affliation
                </option>
                <option>Emory University</option>
                <option>Non-Emory</option>
            </select>
            <label>Committee Member's Name</label>
            <input :name="memberNameAttr(index)" type="text" class="form-control" />
            <label>Affiliation</label> 
            <input :name="memberAffiliationAttr(index)" type="text" class="form-control" />
            <a data-turbolinks="false" @click="removeMember(index)">Remove Committee Member</a>
        </div>
        <p>
        <a data-turbolinks="false" @click="addMember">Add Another Committee Member</a>
        </p>
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
      sharedState: formStore,
    };
  },
  methods: {
      addMember () {
          this.committeeMembers.push({id: this.committeeMembers.length + 1, affliation: '', name: ''})
      },
      removeMember(index) {
          const filteredMembers = this.committeeMembers.filter((member) => member.id !== index.id)
          this.committeeMembers = filteredMembers
      },
      addChair () {
          this.committeeChairs.push({id: this.committeeChairs.length + 1, affliation: '', name: ''})
      },
      removeChair(index) {
          const filteredChairs = this.committeeChairs.filter((chair) => chair.id !== index.id)
          this.committeeChairs = filteredChairs
      },
      chairNameAttr(index) {
          return `etd[committee_chair_attributes][${index}][name][]`
      },
      chairAffiliationAttr(index) {
          return `etd[committee_chair_attributes][${index}][affiliation][]`
      },
      chairAffiliationTypeAttr(index) {
        return `etd[committee_chair_attributes][${index}][affiliation_type]`
      },
      memberNameAttr(index) {
          return `etd[committee_member_attributes][${index}][name][]`
      },
      memberAffiliationAttr(index) {
          return `etd[committee_member_attributes][${index}][affiliation][]`
      },
      memberAffiliationTypeAttr(index) {
        return `etd[committee_member_attributes][${index}][affiliation_type]`
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
