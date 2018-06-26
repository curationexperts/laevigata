<template>
  <div>
    <ul>
      <li v-for="value in tabs" v-bind:key="value.label">
        <a href="#" data-turbolinks="false" class="tab" v-on:click="value.selected = !value.selected">{{ value.label }}</a>
      </li>
    </ul>
    <form role="form" action="/concern/etds/new" method="post">
      <div v-for="value in tabs" v-bind:key="value.label">

        <div class="tab-content form-group" v-if="value.selected">
          <h1> {{ value.label }} </h1>
          <div v-for="input in value.inputs" v-bind:key="input.label">
            <label>{{ input.label }}</label>
            <input class="form-control" v-model="input.value">
          </div>
          <button type="submit" class="btn btn-default">Submit</button>
        </div>
      </div>
    </form>
  </div>
</template>

<script>
import { formSchema } from './form_schema'

export default {
  data() {
    return {
      tabs: formSchema.tabs
    }
  }
}
</script>

<style scoped>
ul {
  clear: left;
  float: left;
  list-style: none;
  position: relative;
  margin: 0;
  padding: 0;
}
li {
  margin: 1em;
  display: block;
  float: left;
  list-style: none;
  position: relative;
}
ul li a {
  display: block;
  line-height: 1.3em;
  font-family: "PT Sans", sans;
}

.tab-content {
  clear: left;
}

input {
  margin-bottom: 1em;
}
</style>
