<template>
  <div>
    <label>Keywords</label>
    <div class="form-inline keyword" v-for="(keyword, index) in sharedState.keywords" v-bind:key="index">
      <input class="form-control" name="etd[keyword][]" />
      <a data-turbolinks="false" class="btn btn-default" href="#" @click="sharedState.removeKeyword(index)">Remove This Keyword</a>
      <br/>
    </div>
    <br/>
    <a data-turbolinks="false" class="btn btn-default" @click="sharedState.addKeyword('')" href="#"><span class="glyphicon glyphicon-plus"></span> Add a Keyword</a>
  </div>
</template>

<script>
import { formStore } from "./formStore";

export default {
  data() {
    return {
      sharedState: formStore
    }
  }
}
</script>

<style scoped>
.keyword {
  margin-bottom: 1em;
}
</style>
