/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Subfield from 'Subfield'

describe('Subfield.vue', () => {
  it('renders a select element', () => {
    const wrapper = shallowMount(Subfield, {
    })
    expect(wrapper.findAll('select')).toHaveLength(1)
  })

  it('has a label that contains Subfield', () => {
    const wrapper = shallowMount(Subfield, {
    })
    expect(wrapper.findAll('label')).toHaveLength(1)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(Subfield, {
    })
    expect(wrapper.html()).toEqual(`<div><label for="subfield">Subfield</label> <select id="subfield" name="etd[subfield]" class="form-control"></select></div>`)
  })
})
