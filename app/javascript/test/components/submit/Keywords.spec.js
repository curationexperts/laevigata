/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Keywords from '../../../components/submit/Keywords'

describe('Embargo.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(Keywords, {
    })
    expect(wrapper.html()).toContain('Keywords')
  })
})
