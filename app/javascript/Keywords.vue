<template>
  <div>
    <label for="keywords">Keywords</label>
    <div id="keywords">
      <div class="form-inline keyword" v-for="keyword in sharedState.keywords.keywords()">
        <input type="text" class="form-control" name="etd[keyword][]" v-model="keyword.value"/>
        <button type="button" class="btn btn-default" @click="sharedState.keywords.remove(keyword)">
          <span class="glyphicon glyphicon-trash"></span>  Remove This Keyword</button>
        <br/>
      </div>
    </div>
    <br/>
    <button type="button" class="btn btn-default" @click="sharedState.keywords.addEmpty()"><span class="glyphicon glyphicon-plus"></span> Add a Keyword</button>
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
</style>
