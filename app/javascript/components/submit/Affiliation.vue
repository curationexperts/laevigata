  <template>
  <div>
    <div v-if="member.affiliation">
      Affiliation: {{ member.affiliation[0] }}
    </div>
    <div v-else>
      Affiliation: {{ member.affiliation_type }}
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
    }
  },
  props: ["member"]
}
</script>

<style>
</style>
