<template>
  <div>
    <label for="keywords">Keywords</label>
    <div id="keywords">
      <div class="form-inline keyword" v-for="keyword in sharedState.keywords.keywords()">
        <input type="text" class="form-control" name="etd[keyword][]" v-model="keyword.value" v-on:change="sharedState.setValid('Keywords', false)"/>
        <button type="button" class="btn btn-danger remove-btn" @click="sharedState.keywords.remove(keyword), sharedState.setValid('Keywords', false)">
          <span class="glyphicon glyphicon-trash"></span>  Remove This Keyword</button>
        <br/>
      </div>
    </div>
    <br/>
    <button type="button" class="btn btn-default" @click="sharedState.keywords.addEmpty(), sharedState.setValid('Keywords', false)"><span class="glyphicon glyphicon-plus"></span> Add a Keyword</button>
  </div>
</template>

<script>
import { formStore } from "./formStore";
import _ from "lodash"

export default {
  data() {
    return {
      sharedState: formStore
    }
  },
   mounted() {
    this.$nextTick(() => {
      this.sharedState.keywords.load(
        this.sharedState.savedData["keyword"]
      )
    })
  },
}
</script>

<style scoped>
.keyword {
  margin-bottom: 1em;
}

.remove-btn { 
  margin-top: 0;
}
</style>
