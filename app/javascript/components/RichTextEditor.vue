  <template>
    <div> 
        <div v-if="typeof parentValue != 'object'">
          <quill-editor :options="editorOptions" ref="myTextEditor" v-model="inputValue" v-on:change="sharedState.setValid('My Etd', false)">
          </quill-editor>
          <input type="hidden" class="quill-hidden-field" :name="parentName" v-model="inputValue" />
        </div>
        <div v-if="typeof parentValue === 'object'">
          <quill-editor :options="editorOptions" ref="myTextEditor" v-model="inputValue[0]" v-on:change="sharedState.setValid('My Etd', false)">
          </quill-editor>
        <input type="hidden" class="quill-hidden-field" :name="parentName" v-model="inputValue[0]" />
        <section class='errorMessage alert alert-danger' v-if="sharedState.hasError(parentIndex)">
           <p><span class="glyphicon glyphicon-exclamation-sign"></span> {{parentLabel}} is required</p>
        </section>
        </div>
    </div>
  </template>

  <script>
  import { formStore } from '../formStore'
  import { quillEditor } from 'vue-quill-editor'
  import 'quill/dist/quill.core.css'
  import 'quill/dist/quill.snow.css'
  import 'quill/dist/quill.bubble.css'
  import quillToolbarOptions  from '../quillToolbarOptions'
  import quillKeyboardBindings from '../quillKeyboardBindings' 

  export default {
    data() {
      return {
        inputValue: this.parentValue,
        sharedState: formStore,
        editorOptions: {
        modules: {
        toolbar: quillToolbarOptions(),
        keyboard: {
          bindings: quillKeyboardBindings()
          }
        }
      },
      }
    },
    props: ['parentValue','parentName', 'parentLabel', 'parentIndex'],
    components: {
      quillEditor: quillEditor
    }
  }
  </script>
<style>
  .quill-editor {
   height: 10em;
   margin-bottom: 7em;
  }
</style>  
