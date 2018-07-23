/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import AboutMe from '../../../components/submit/AboutMe'

describe('AboutMe.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(AboutMe, {
    })
    expect(wrapper.html()).toContain('About Me')
  })
})
