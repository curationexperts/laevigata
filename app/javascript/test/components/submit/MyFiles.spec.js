/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import MyFiles from '../../../components/submit/MyFiles'
import { formStore } from '../../../formStore'

formStore.savedData.files = '{"id":85,"name":"c4611_sample_explain.pdf","size":88226,"deleteUrl":"/uploads/85?locale=en","deleteType":"DELETE"}'
describe('MyFiles.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(MyFiles, {
    })
    expect(wrapper.html()).toContain('My Files')
  })
})
