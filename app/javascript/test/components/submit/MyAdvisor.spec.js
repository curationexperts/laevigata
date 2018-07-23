/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import MyAdvisor from '../../../components/submit/MyAdvisor'

describe('MyAdvisor.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(MyAdvisor, {
    })
    expect(wrapper.html()).toContain('My Advisor')
  })
})
