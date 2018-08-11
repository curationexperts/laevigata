/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import MyEtd from '../../../components/submit/MyEtd'
import { formStore } from '../../../formStore'

formStore.savedData.abstract = 'this is my abstract'
formStore.savedData['table_of_contents'] = 'this is my toc'
describe('MyEtd.vue', () => {
  it('has the correct values for abstract and toc', () => {
    const wrapper = shallowMount(MyEtd, {
    })
    expect(wrapper.html()).toContain('this is my abstract')
    expect(wrapper.html()).toContain('this is my toc')
  })
})
