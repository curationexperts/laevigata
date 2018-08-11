/* global describe */
/* global it */
/* global expect */
import { shallowMount, mount } from '@vue/test-utils'
import MyFiles from '../../../components/submit/MyFiles'
import { formStore } from '../../../formStore'

formStore.savedData.supplemental_file_metadata = {"0":{"filename":"File Name","title":"Title","description":"Description","file_type":"Text"}}
formStore.savedData['files'] = '{"id":104,"name":"2016FEB10.pdf","size":1944456,"deleteUrl":"/uploads/104?locale=en","deleteType":"DELETE"}'
describe('MyFiles.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(MyFiles, {
    })
    expect(wrapper.html()).toContain('My Files')
  })

  it('displays the correct metadata', () => {
    const wrapper = mount(MyFiles, {
    })

    expect(wrapper.html()).toContain('File Name')
    expect(wrapper.html()).toContain('Title')
    expect(wrapper.html()).toContain('Description')
    expect(wrapper.html()).toContain('Text')
  })
})
