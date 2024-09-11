<template>
    <div aria-labelledby="chair-label">
        <h3 id="chair-label">Chair and Commitee Members</h3>
        <div role="alert" v-if="sharedState.committeeChairs.length === 0">
            You have not selected a chair or committee members. Please
            use the buttons below to add them to your submission.
        </div>
        <div class="member-container well" v-for="(chair,index) in sharedState.committeeChairs.chairs()" v-bind:value="chair.name">
            <div class="member-box">
            <div>
              <label>Committee Chair's Affiliation</label>
                    <select v-model="chair.affiliationType" class="form-control" :name="chairAttr(index, '[affiliation_type]')" v-on:change="sharedState.setValid('My Advisor', false)">
                      <option disabled selected>
                          Select an affiliation
                      </option>
                      <option>Emory University</option>
                      <option>Non-Emory</option>
                  </select>
              </div>
            <div>
              <label>Committee Chair's Name</label>
              <input :name="chairAttr(index, '[name][]')"  type="text" class="form-control"
              v-model="chair.name" 
              v-on:change="sharedState.setValid('My Advisor', false)"/>
            </div>
            <div v-if="chair.affiliationType === 'Non-Emory'">
                {{ chair.affliation }}
            <label>Affiliation</label>
                <input :name="chairAttr(index, '[affiliation][]')" type="text" class="form-control" v-model="chair.affiliation" v-on:change="sharedState.setValid('My Advisor', false)"/>
            </div>
            <div v-else>
              <input :name="chairAttr(index, '[affiliation][]')" type="hidden" class="form-control" v-model="chair.affiliation" v-on:change="sharedState.setValid('My Advisor', false)"/>
            </div>
              
        </div>
        <button type="button" class="btn btn-danger" @click="sharedState.committeeChairs.remove(chair), sharedState.setValid('My Advisor', false)"><span class="glyphicon glyphicon-trash"></span> Remove Committee Chair</button>
        </div>
         <div class="member-container well" v-for="(member, index) in sharedState.committeeMembers.members()">
            <div class="member-box">
           <div>
            <label>Committee Member's Affiliation</label>
                  <select v-model="member.affiliationType" class="form-control" :name="memberAttr(index, '[affiliation_type]')" v-on:change="sharedState.setValid('My Advisor', false)">
                    <option disabled selected>
                        Select an affiliation
                    </option>
                    <option>Emory University</option>
                    <option>Non-Emory</option>
                </select>
           </div>
           <div>
              <label>Committee Member's Name</label>
              <input :name="memberAttr(index, '[name][]')" type="text" class="form-control" v-model="member.name" v-on:change="sharedState.setValid('My Advisor', false)"/>
          </div>  
          <div v-if="member.affiliationType === 'Non-Emory'">
              {{ member.affliation }}
          <label>Affiliation</label>
              <input :name="memberAttr(index, '[affiliation][]')" type="text" class="form-control" v-model="member.affiliation" v-on:change="sharedState.setValid('My Advisor', false)"/>
          </div>
          <div v-else>
            <input :name="memberAttr(index, '[affiliation][]')" type="hidden" class="form-control" v-model="member.affiliation" v-on:change="sharedState.setValid('My Advisor', false)"/>
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
    chairAttr(index, attr_name) {
      return `etd[committee_chair_attributes][${index}]${attr_name}`
    },
    memberAttr(index, attr_name) {
      return `etd[committee_members_attributes][${index}]${attr_name}`
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
