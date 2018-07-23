/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import MyEtd from '../../../components/submit/MyEtd'

describe('MyEtd.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(MyEtd, {
    })
    expect(wrapper.html()).toContain('My Thesis or Dissertation')
  })
})
