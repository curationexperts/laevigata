/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import MyProgram from '../../../components/submit/MyProgram'

describe('MyProgram.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(MyProgram, {
    })
    expect(wrapper.html()).toContain('My Program')
  })
})
