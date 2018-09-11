<template>
    <div aria-labelledby="chair-label">
        <h3 id="chair-label">Chair and Commitee Members</h3>
        <div role="alert" v-if="sharedState.committeeChairs.length === 0">
            You have not selected a chair or committee members. Please
            use the buttons below to add them to your submission.
        </div>
        <div class="member-container well" v-for="chair in sharedState.committeeChairs.chairs()" v-bind:value="chair.name">
            <div class="member-box">
            <div>
              <label>Committee Chairs' Affiliation</label>
                    <select v-model="chair.affiliationType" class="form-control" :name="chairAffiliationTypeAttr(chair)" v-on:change="sharedState.setValid('My Advisor', false)">
                      <option disabled selected>
                          Select an affiliation
                      </option>
                      <option>Emory University</option>
                      <option>Non-Emory</option>
                  </select>
              </div>
            <div>
              <label>Committee Chairs' Name</label>
              <input :name="chairNameAttr(chair)" type="text" class="form-control" 
              v-model="chair.name" 
              v-on:change="sharedState.setValid('My Advisor', false)"/>
            </div>
            <div v-if="chair.affiliationType === 'Non-Emory'">
                {{ chair.affliation }}
            <label>Affiliation</label>
                <input :name="chairAffiliationAttr(chair)" type="text" class="form-control" v-model="chair.affiliation" v-on:change="sharedState.setValid('My Advisor', false)"/>
            </div>
              
        </div>
        <button type="button" class="btn btn-danger" @click="sharedState.committeeChairs.remove(chair), sharedState.setValid('My Advisor', false)"><span class="glyphicon glyphicon-trash"></span> Remove Committee Chair</button>
        </div>
         <div class="member-container well" v-for="member in sharedState.committeeMembers.members()" v-bind:value="member.name">
            <div class="member-box">
           <div>
            <label>Committee Member's Affiliation</label>
                  <select v-model="member.affiliationType" class="form-control" :name="memberAffiliationTypeAttr(member)" v-on:change="sharedState.setValid('My Advisor', false)">
                    <option disabled selected>
                        Select an affiliation
                    </option>
                    <option>Emory University</option>
                    <option>Non-Emory</option>
                </select>
           </div>
           <div>
              <label>Committee Member's Name</label>
              <input :name="memberNameAttr(member)" type="text" class="form-control" v-model="member.name" v-on:change="sharedState.setValid('My Advisor', false)"/>
          </div>  
            <div v-if="member.affiliationType === 'Non-Emory'">
                {{ member.affliation }}
            <label>Affiliation</label>
                <input :name="memberAffiliationAttr(member)" type="text" class="form-control" v-model="member.affiliation" v-on:change="sharedState.setValid('My Advisor', false)"/>
            </div>
        </div>
        <button type="button" class="btn btn-danger" @click="sharedState.committeeMembers.remove(member), sharedState.setValid('My Advisor', false)"><span class="glyphicon glyphicon-trash"></span> Remove Committee Member</button>
        </div>
          <button type="button" class="add-member btn btn-default add-member-buttons" @click="sharedState.committeeChairs.addEmpty(), sharedState.setValid('My Advisor', false)"><span class="glyphicon glyphicon-plus"></span> Add a Committee Chair</button>
          <button type="button" class="btn btn-default add-member add-member-buttons" @click="sharedState.committeeMembers.addEmpty(), sharedState.setValid('My Advisor', false)"><span class="glyphicon glyphicon-plus"></span> Add a Committee Member</button>
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
      this.sharedState.committeeChairs.load(
        this.sharedState.savedData["committee_chair_attributes"]
      )

      this.sharedState.committeeMembers.load(
        this.sharedState.savedData["committee_members_attributes"]
      )
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
.member-box {
  min-width: 400px;
}
.member-container label {
  display: inline;
}

.member-container {
  display: flex;
  align-items: center;
}

.member-container .btn {
  margin-left: 1em;
}

.member-box {
  display: inline-flex;
}

.member-box > * {
  margin-left: 1em;
}

.member-box h4 {
  margin-left: initial;
}
.add-member {
  margin-top: 0.5em;
  margin-bottom: 0.5em;
}

.add-member-buttons {
  min-width:200px;
  text-align:left;
  display: block;
}

</style>
