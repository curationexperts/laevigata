<template>
  <div>
    <label for="keywords">Keywords</label>
    <div id="keywords">
      <div class="form-inline keyword" v-for="(keyword, index) in sharedState.keywords" v-bind:key="index">
        <input class="form-control" :value="getVal(keyword)" name="etd[keyword][]" />
        <a data-turbolinks="false" class="btn btn-default"  href="#" @click="sharedState.removeKeyword(index)">Remove This Keyword</a>
        <br/>
      </div>
    </div>
    <br/>
    <button type="button" class="btn btn-default" @click="sharedState.addKeyword('')"><span class="glyphicon glyphicon-plus"></span> Add a Keyword</button>
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
  methods:{
    getVal(keyword){
      var val = ''
      if (_.isString(keyword)){
        val = keyword
      }
      return val
    }
  }
}
</script>

<style scoped>
.keyword {
  margin-bottom: 1em;
}
</style>
