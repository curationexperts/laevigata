<template>
    <div aria-labelledby="chair-label">
        <h3 id="chair-label">Chair and Commitee Members</h3>
        <div role="alert" v-if="sharedState.committeeChairs.length === 0">
            You have not selected a chair or committee members. Please
            use the buttons below to add them to your submission.
        </div>
        <div v-for="chair in sharedState.committeeChairs.chairs()" v-bind:value="chair.name">
            <div class="well">
            <h4>Committee Chair</h4>
            <label>Committee Chairs's Affiliation
                  <select v-model="chair.affiliationType" class="form-control" :name="chairAffiliationTypeAttr(chair)" v-on:change="sharedState.setValid('My Advisor', false)">
                    <option disabled selected>
                        Select an affiliation
                    </option>
                    <option>Emory University</option>
                    <option>Non-Emory</option>
                </select>
            </label>

            <label>Committee Chairs's Name
            <input :name="chairNameAttr(chair)" type="text" class="form-control" v-model="chair.name" v-on:change="sharedState.setValid('My Advisor', false)"/>
            </label>

            <div v-if="chair.affiliationType === 'Non-Emory'">
                {{ chair.affliation }}
            <label>Affiliation
                <input :name="chairAffiliationAttr(chair)" type="text" class="form-control" v-model="chair.affiliation" v-on:change="sharedState.setValid('My Advisor', false)"/>
            </label>
            </div>
            <button type="button" class="btn btn-default" @click="sharedState.committeeChairs.remove(chair), sharedState.setValid('My Advisor', false)"><span class="glyphicon glyphicon-trash"></span> Remove Committee Chair</button>
        </div>
        </div>
        <button type="button" class="btn btn-default" @click="sharedState.committeeChairs.addEmpty(), sharedState.setValid('My Advisor', false)"><span class="glyphicon glyphicon-plus"></span> Add a Committee Chair</button>

         <div v-for="member in sharedState.committeeMembers.members()" v-bind:value="member.name">
            <div class="well">
            <h4>Committee Member</h4>
            <label>Committee Member's Affiliation
                  <select v-model="member.affiliationType" class="form-control" :name="memberAffiliationTypeAttr(member)" v-on:change="sharedState.setValid('My Advisor', false)">
                    <option disabled selected>
                        Select an affiliation
                    </option>
                    <option>Emory University</option>
                    <option>Non-Emory</option>
                </select>
            </label>

            <label>Committee Member's Name
            <input :name="memberNameAttr(member)" type="text" class="form-control" v-model="member.name" v-on:change="sharedState.setValid('My Advisor', false)"/>
            </label>

            <div v-if="member.affiliationType === 'Non-Emory'">
                {{ member.affliation }}
            <label>Affiliation
                <input :name="memberAffiliationAttr(member)" type="text" class="form-control" v-model="member.affiliation" v-on:change="sharedState.setValid('My Advisor', false)"/>
            </label>
            </div>
            <button type="button" class="btn btn-default" @click="sharedState.committeeMembers.remove(member), sharedState.setValid('My Advisor', false)"><span class="glyphicon glyphicon-trash"></span> Remove Committee Member</button>
        </div>
        </div>
        <button type="button" class="btn btn-default" @click="sharedState.committeeMembers.addEmpty(), sharedState.setValid('My Advisor', false)"><span class="glyphicon glyphicon-plus"></span> Add a Committee Member</button>
    </div>
</template>

<script>
import Vue from "vue"
import App from "./App"
import { formStore } from "./formStore"

export default {
  data() {
    return {
      sharedState: formStore
    };
  },
  mounted() {
    this.$nextTick(() => {
      this.sharedState.committeeMembers.load(
        this.sharedState.savedData["committee_members_attributes"]
      );
    });
  },
  methods: {
    chairNameAttr(chair) {
      return `etd[committee_chair_attributes][${this.sharedState.committeeChairs.chairs().indexOf(chair)}][name][]`
    },
    chairAffiliationAttr(chair) {
      return `etd[committee_chair_attributes][${this.sharedState.committeeChairs.chairs().indexOf(chair)}][affiliation][]`
    },
     chairAffiliationTypeAttr(chair) {
      return `etd[committee_chair_attributes][${this.sharedState.committeeChairs.chairs().indexOf(chair)}][affiliation_type]`
    },
    memberNameAttr(member) {
      return `etd[committee_members_attributes][${this.sharedState.committeeMembers
        .members()
        .indexOf(member)}][name][]`
    },
    memberAffiliationAttr(member) {
      return `etd[committee_members_attributes][${this.sharedState.committeeMembers
        .members()
        .indexOf(member)}][affiliation][]`
    },
    memberAffiliationTypeAttr(member) {
      return `etd[committee_members_attributes][${this.sharedState.committeeMembers
        .members()
        .indexOf(member)}][affiliation_type]`
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
