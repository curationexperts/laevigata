/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import MyFiles from '../../../components/submit/MyFiles'

describe('MyFiles.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(MyFiles, {
    })
    expect(wrapper.html()).toContain('My Files')
  })
})
