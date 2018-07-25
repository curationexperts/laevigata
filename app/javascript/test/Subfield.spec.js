/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Subfield from 'Subfield'

// This needs to check for both cases: visible / not-present
// now it tests that it isn't present
describe('Subfield.vue', () => {
  it('renders a select element', () => {
    const wrapper = shallowMount(Subfield, {
    })
    expect(wrapper.findAll('select')).toHaveLength(0)
  })

  it('has a label that contains Subfield', () => {
    const wrapper = shallowMount(Subfield, {
    })
    expect(wrapper.findAll('label')).toHaveLength(0)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(Subfield, {
    })
    expect(wrapper.html()).toEqual(`<div><!----></div>`)
  })
})
